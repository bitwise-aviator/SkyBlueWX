//
//  AppRepo.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import Foundation

struct SettingsStruct {
    var temperatureUnit : TemperatureUnit = .C
    var speedUnit : SpeedUnit = .knot
    var visibilityUnit : VisUnit = .mile
}

// This class is a common interface to store data across the app and handle cross-app integration.
class Cockpit {
    // Settings variables:
    // Temporary: to be moved to .plist modifier on development.
    var settings : SettingsStruct
    // END SETTINGS VARIABLES...
    
    
    let dbConnection : DataBaseHandler
    // var activeView : Views = Views.list // keep track of what the active view is, to be efficient with observers/closures.
    var queryCodes : Set<String> = [] // Codes sent to server as part of query. Use set to avoid repeated codes.
    var activeReport: String?
    
    init() {
        self.dbConnection = DataBaseHandler()
        self.settings = SettingsStruct()
        self.activeReport = nil
    }
    
    func editQueryList(_ icao: String) {
        if queryCodes.contains(icao) {
            queryCodes.remove(icao)
        } else {
            queryCodes.insert(icao)
        }
    }
}
