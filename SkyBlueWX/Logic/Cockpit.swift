//
//  AppRepo.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import Foundation
import SwiftUI

/// This class is a common interface to store data across the app and handle cross-app integration.
final class Cockpit: ObservableObject {
    /* The @Published wrapper for ObservableObjects denotes properties that will trigger
     re-renders for all views that are observing it.*/
    // Settings variables:
    @Published var settings: SettingsStruct
    // END SETTINGS VARIABLES...
    private let dbConnection: DataBaseHandler
    // Codes sent to server as part of query. Use set to avoid repeated codes.
    @Published var queryCodes: Set<String> = []
    @Published var reports: [String: WeatherReport] = [:]
    var reportKeys: [String] {
        Array(reports.keys).sorted()
    }
    @Published var activeReport: String?
    @Published var activeReportStruct: WeatherReport?
    @Published var dbQueryResults: AirportDict? = [:]

    private let locationTracker: LocationManager
    private let refreshLock = DispatchSemaphore(value: 1)
    let deviceInfo: UIDeviceInfo
    var storedAirports: [String: Airport] = [:]
    var timer: Timer?
    init() {
        /// Interface with sqlite database.
        self.dbConnection = DataBaseHandler()
        /// App settings -> to be transferred to env
        self.settings = SettingsStruct()
        self.activeReport = nil
        self.activeReportStruct = nil
        self.locationTracker = LocationManager()
        self.deviceInfo = UIDeviceInfo()
        print("Running app on \(self.deviceInfo.deviceType.rawValue)")
        if settings.homeAirport.count == 4 {
            self.getAirportRecords(settings.homeAirport, onlyByIcao: true)
            let homeAirportResults = self.dbQueryResults
            if homeAirportResults != nil && homeAirportResults!.count == 1 {
                self.queryCodes.insert(settings.homeAirport)
            }
        }
        postInit()
    }
    func postInit() {
        self.timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(weatherFromTimer),
                                          userInfo: nil, repeats: true)
    }
    func getAirportRecords(_ term: String, onlyByIcao: Bool = false) {
        dbQueryResults = dbConnection.getAirports(searchTerm: term, onlyByIcao: onlyByIcao)
        if let dict = dbQueryResults {
            for (_, value) in dict {
                storedAirports[value.icao] = value
            }
        }
    }
    func refreshSettings() {
        settings.update()
    }
    func moveToNextReport(reverse: Bool = false) -> Bool {
        guard activeReport != nil else {return false}
        guard let currentIndex = reportKeys.firstIndex(of: activeReport!) else {return false}
        let index: Int = reportKeys.distance(from: reportKeys.startIndex, to: currentIndex)
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
        guard reports[icao] != nil else { return false }
        activeReport = icao
        activeReportStruct = reports[icao]
        return true
    }
    func removeReport(icao: String) {
        guard reports[icao] != nil else {return}
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
    @objc func weatherFromTimer() {
        print("Fired query from timer @\(Date.now)")
        Task {
            try await getWeather(useExisting: true)
        }
    }
    func getWeather(moveTo: String? = nil, useExisting: Bool = false) async throws {
        // Only handle the backend weather-fetching here. Renders are kept in their respective views.
        let queries: Set<String> = useExisting ? Set(reportKeys): queryCodes
        let lookup = Task {
            do {
                return await getData(icao: queries, cockpit: self)
            }
        }
        let results: [String: WeatherReport] = await lookup.value
        DispatchQueue.main.async {
            self.reports = results
            if self.reportKeys.count > 0 {
                var hasMoved = false
                if moveTo != nil {
                    hasMoved = self.moveToReport(icao: moveTo!)
                }
                if !hasMoved {
                    if self.activeReport != nil && self.reportKeys.contains(self.activeReport!) { } else {
                        self.activeReportStruct = self.reports[self.reportKeys[0]]
                        self.activeReport = self.reportKeys[0]
                    }
                }
            } else {
                self.activeReportStruct = nil
                self.activeReport = nil
            }
        }
    }
    func setTemperatureUnit(_ target: TemperatureUnit? = nil) {
        let newTempUnit: TemperatureUnit
        if target != nil {
            // Use if a specific unit has been selected - i.e. not toggler.
            newTempUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            newTempUnit = settings.temperatureUnit == TemperatureUnit.celsius ?
            TemperatureUnit.fahrenheit: TemperatureUnit.celsius
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newTempUnit.rawValue, forKey: "temperatureUnit")
        settings.update()
    }
    func setSpeedUnit(_ target: SpeedUnit? = nil) {
        let newSpeedUnit: SpeedUnit
        if target != nil {
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
        let newVisUnit: VisUnit
        if target != nil {
            // Use if a specific unit has been selected - i.e. not toggler.
            newVisUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            newVisUnit = settings.visibilityUnit == VisUnit.mile ? VisUnit.kilometer: VisUnit.mile
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newVisUnit.rawValue, forKey: "visibilityUnit")
        settings.update()
    }
    func setAltitudeUnit(_ target: AltitudeUnit? = nil) {
        let newAltitudeUnit: AltitudeUnit
        if target != nil {
            // Use if a specific unit has been selected - i.e. not toggler.
            newAltitudeUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            newAltitudeUnit = settings.altitudeUnit == .feet ? .meter: .feet
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newAltitudeUnit.rawValue, forKey: "altitudeUnit")
        settings.update()
    }
    func setPressureUnit(_ target: PressureUnit? = nil) {
        let newPressureUnit: PressureUnit
        if target != nil {
            // Use if a specific unit has been selected - i.e. not toggler.
            newPressureUnit = target!
        } else {
            // Use for toggler or for cycling, advance to next one.
            newPressureUnit = settings.pressureUnit == .inHg ? .mbar: .inHg
        }
        // Apply changes to user settings (SettingsStruct has computed units)
        UserDefaults.standard.set(newPressureUnit.rawValue, forKey: "pressureUnit")
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
