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
    var temperatureUnit : TemperatureUnit {
        get {
            switch UserDefaults.standard.integer(forKey: "temperatureUnit") {
            case 1: return .F
            default: return .C
            }
        }
    }
    var speedUnit : SpeedUnit  {
        get {
            switch UserDefaults.standard.integer(forKey: "speedUnit") {
            case 1: return .mph
            case 2: return .kmh
            default: return .knot
            }
        }
    }
    var visibilityUnit : VisUnit  {
        get {
            switch UserDefaults.standard.integer(forKey: "visibilityUnit") {
            case 1: return .km
            default: return .mile
            }
        }
    }
    // F
    var homeAirport : String {
        get {
            UserDefaults.standard.string(forKey: "homeAirport") ?? ""
        }
    }
}

enum Device : String {
    case pad = "iPad"
    case phone = "iPhone"
    case other = "other"
}

class Cockpit {
    /// This class is a common interface to store data across the app and handle cross-app integration.
    // Settings variables:
    var settings : SettingsStruct
    // END SETTINGS VARIABLES...
    
    let dbConnection : DataBaseHandler
    // var activeView : Views = Views.list // keep track of what the active view is, to be efficient with observers/closures.
    var queryCodes : Set<String> = [] // Codes sent to server as part of query. Use set to avoid repeated codes.
    var reports : [String : WeatherReport] = [:]
    var activeReport: String?
    let locationTracker : LocationManager
    let refreshLock = DispatchSemaphore(value: 1)
    let deviceType : Device
    
    
    init() {
        /// Interface with sqlite database.
        self.dbConnection = DataBaseHandler()
        /// App settings -> to be transferred to env
        self.settings = SettingsStruct()
        if settings.homeAirport.count == 4 {
            self.queryCodes.insert(settings.homeAirport)
        }
        ///
        self.activeReport = nil
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
    }
    
    func getWeather() throws {
        // Only handle the backend weather-fetching here. Renders are kept in their respective views.
        refreshLock.wait() // Locks/queues further executions
        Task {
            do {
                reports = await loadMe(icao: queryCodes, cockpit: self) // Call getter & parser
                
            }
        }
        
    }
    
    func setTemperatureUnit(_ target: TemperatureUnit? = nil) -> TemperatureUnit {
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
        // Return the new unit as a state var, if called by a view.
        return newTempUnit
    }
    
    func setSpeedUnit(_ target: SpeedUnit? = nil) -> SpeedUnit {
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
        // Return the new unit as a state var, if called by a view.
        return newSpeedUnit
    }
    
    func getSpeedUnitText(_ unit: SpeedUnit? = nil) -> String {
        let sourceUnit = unit ?? settings.speedUnit
        switch sourceUnit {
        case .knot: return "kt"
        case .mph: return "mph"
        case .kmh: return "km/h"
        }
    }
    
    func setVisibilityUnit(_ target: VisUnit? = nil) -> VisUnit {
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
        // Return the new unit as a state var, if called by a view.
        return newVisUnit
    }
    
    func setHomeAirport(_ icao: String) {
        
        UserDefaults.standard.set(icao, forKey: "homeAirport")
        print(settings.homeAirport)
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
