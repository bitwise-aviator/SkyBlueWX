//
//  AppRepo.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import Foundation
import SwiftUI

struct SettingsStruct {
    // default cases should have settings value of zero.
    var temperatureUnit : TemperatureUnit
    var speedUnit : SpeedUnit
    var visibilityUnit : VisUnit
    var homeAirport : String
    
    mutating func update() {
        let temperatureUnitKey = UserDefaults.standard.integer(forKey: "temperatureUnit")
        switch temperatureUnitKey {
        case 1: temperatureUnit = .F
        default: temperatureUnit = .C
        }
        let speedUnitKey = UserDefaults.standard.integer(forKey: "speedUnit")
        switch speedUnitKey {
        case 1: speedUnit = .mph
        case 2: speedUnit = .kmh
        default: speedUnit = .knot
        }
        let visibilityUnitKey = UserDefaults.standard.integer(forKey: "visibilityUnit")
        switch visibilityUnitKey {
        case 1: visibilityUnit = .km
        default: visibilityUnit = .mile
        }
        homeAirport = UserDefaults.standard.string(forKey: "homeAirport") ?? ""
    }
    
    init() {
        self.temperatureUnit = .C
        self.speedUnit = .knot
        self.visibilityUnit = .mile
        self.homeAirport = ""
        update()
    }
    
    var speedUnitString : String {
        get {
            switch (speedUnit) {
            case .knot: return "kt"
            case .mph: return "mph"
            case .kmh: return "km/h"
            }
        }
    }
}

enum Device : String {
    case pad = "iPad"
    case phone = "iPhone"
    case other = "other"
}

final class Cockpit : ObservableObject {
    /// This class is a common interface to store data across the app and handle cross-app integration.
    ///
    /// The @Published wrapper for ObservableObjects denotes properties that will trigger re-renders for all views that are observing it.
    // Settings variables:
    @Published var settings : SettingsStruct
    // END SETTINGS VARIABLES...
    
    let dbConnection : DataBaseHandler
    // var activeView : Views = Views.list // keep track of what the active view is, to be efficient with observers/closures.
    @Published var queryCodes : Set<String> = [] // Codes sent to server as part of query. Use set to avoid repeated codes.
    @Published var reports : [String : WeatherReport] = [:]
    var reportKeys : [String] {
        get {
            Array(reports.keys).sorted()
        }
    }
    @Published var activeReport: String?
    @Published var activeReportStruct : WeatherReport?

    let locationTracker : LocationManager
    let refreshLock = DispatchSemaphore(value: 1)
    let deviceType : Device
    
    
    init() {
        /// Interface with sqlite database.
        self.dbConnection = DataBaseHandler()
        /// App settings -> to be transferred to env
        self.settings = SettingsStruct()
        self.activeReport = nil
        self.activeReportStruct = nil
        self.locationTracker = LocationManager()
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            self.deviceType = .phone
        case .pad:
            self.deviceType = .pad
        default:
            self.deviceType = .other
        }
        print("Running app on \(self.deviceType.rawValue)")
        if settings.homeAirport.count == 4 {
            self.queryCodes.insert(settings.homeAirport)
        }
    }
    
    func refreshSettings() {
        settings.update()
    }
    
    func moveToNextReport(reverse: Bool = false) -> Bool {
        guard let _ = activeReport else {return false}
        guard let currentIndex = reportKeys.firstIndex(of: activeReport!) else {return false}
        let index : Int = reportKeys.distance(from: reportKeys.startIndex, to: currentIndex)
        if index < reportKeys.count - 1 && !reverse {
            activeReport = reportKeys[index + 1]
            activeReportStruct = reports[activeReport!]
            return true
        } else if index > 0 && reverse {
            activeReport = reportKeys[index - 1]
            activeReportStruct = reports[activeReport!]
            return true
        } else {
            return false
        }
    }
    
    func moveToReport(icao: String) -> Bool {
        guard let _ = reports[icao] else { return false }
        activeReport = icao
        activeReportStruct = reports[icao]
        return true
    }
    
    func removeReport(icao: String) {
        guard let _ = reports[icao] else {return}
        if icao == activeReport {
            // This makes the app move to the previous tab. If it was the
            if icao == reportKeys[0] && reportKeys.count > 1 { _ = moveToNextReport()
            } else {
                _ = moveToNextReport(reverse: true)
            }
            reports[icao] = nil
            queryCodes.remove(icao)
            if reportKeys.count == 0 {
                activeReport = nil
                activeReportStruct = nil
            }
            
        } else {
            reports[icao] = nil
            queryCodes.remove(icao)
        }
        
        
    }
    
    
    func getWeather() async throws {
        // Only handle the backend weather-fetching here. Renders are kept in their respective views.
        let lookup = Task {
            do {
                return await loadMe(icao: queryCodes, cockpit: self)
            }
        }
        let results : [String : WeatherReport] = await lookup.value
        DispatchQueue.main.async {
            self.reports = results
            if self.reportKeys.count > 0 {
                self.activeReportStruct = self.reports[self.reportKeys[0]]
                self.activeReport = self.reportKeys[0]
            } else {
                self.activeReportStruct = nil
                self.activeReport = nil
            }
        }
        
        
    }
    
    func setTemperatureUnit(_ target: TemperatureUnit? = nil) {
        let newTempUnit : TemperatureUnit
        if let _ = target {
            // Use if a specific unit has been selected - i.e. not toggler.
            newTempUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            newTempUnit = settings.temperatureUnit == TemperatureUnit.C ? TemperatureUnit.F : TemperatureUnit.C
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newTempUnit.rawValue, forKey: "temperatureUnit")
        settings.update()
    }
    
    func setSpeedUnit(_ target: SpeedUnit? = nil) {
        let newSpeedUnit : SpeedUnit
        if let _ = target {
            // Use if a specific unit has been selected - i.e. not toggler.
            newSpeedUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            switch settings.speedUnit {
            case .knot: newSpeedUnit = .mph
            case .mph: newSpeedUnit = .kmh
            case .kmh: newSpeedUnit = .knot
            }
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newSpeedUnit.rawValue, forKey: "speedUnit")
        settings.update()
    }
    
    func getSpeedUnitText(_ unit: SpeedUnit? = nil) -> String {
        let sourceUnit = unit ?? settings.speedUnit
        switch sourceUnit {
        case .knot: return "kt"
        case .mph: return "mph"
        case .kmh: return "km/h"
        }
    }
    
    func setVisibilityUnit(_ target: VisUnit? = nil) {
        let newVisUnit : VisUnit
        if let _ = target {
            // Use if a specific unit has been selected - i.e. not toggler.
            newVisUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            newVisUnit = settings.visibilityUnit == VisUnit.mile ? VisUnit.km : VisUnit.mile
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newVisUnit.rawValue, forKey: "visibilityUnit")
        settings.update()
    }
    
    func setHomeAirport(_ icao: String) {
        
        UserDefaults.standard.set(icao, forKey: "homeAirport")
        settings.update()
    }
    
    func editQueryList(_ icao: String, retain: Bool = false, exclude: Bool = false) {
        // Set retain to true to not remove airport code if already available.
        // Set exclude to true to not add airport code if not in set.
        // Do not set retain & exclude to true on the same call: it will do nothing.
        if queryCodes.contains(icao) && !retain {
            queryCodes.remove(icao)
        } else if !queryCodes.contains(icao) && !exclude {
            queryCodes.insert(icao)
        }
    }
    
}
