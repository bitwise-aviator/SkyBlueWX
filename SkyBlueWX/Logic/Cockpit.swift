//
//  AppRepo.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import Foundation

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
    var homeAirport : String {
        get {
            UserDefaults.standard.string(forKey: "homeAirport") ?? ""
        }
    }
}


class Cockpit {
    /// This class is a common interface to store data across the app and handle cross-app integration.
    // Settings variables:
    var settings : SettingsStruct
    // END SETTINGS VARIABLES...
    
    let dbConnection : DataBaseHandler
    // var activeView : Views = Views.list // keep track of what the active view is, to be efficient with observers/closures.
    var queryCodes : Set<String> = [] // Codes sent to server as part of query. Use set to avoid repeated codes.
    var activeReport: String?
    
    init() {
        /// Interface with sqlite database.
        self.dbConnection = DataBaseHandler()
        /// App settings -> to be transferred to env
        self.settings = SettingsStruct()
        ///
        self.activeReport = nil
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
    
    func editQueryList(_ icao: String) {
        if queryCodes.contains(icao) {
            queryCodes.remove(icao)
        } else {
            queryCodes.insert(icao)
        }
    }
    
}
