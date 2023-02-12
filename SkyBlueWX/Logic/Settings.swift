//
//  Settings.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/12/23.
//

import Foundation

struct SettingsStruct {
    // default cases should have settings value of zero.
    var temperatureUnit: TemperatureUnit
    var speedUnit: SpeedUnit
    var visibilityUnit: VisUnit
    var altitudeUnit: AltitudeUnit
    var pressureUnit: PressureUnit
    var homeAirport: String
    //
    mutating func updateTemperature() {
        let temperatureUnitKey = UserDefaults.standard.integer(forKey: "temperatureUnit")
        switch temperatureUnitKey {
        case 1: temperatureUnit = .fahrenheit
        default: temperatureUnit = .celsius
        }
    }
    //
    mutating func updateSpeed() {
        let speedUnitKey = UserDefaults.standard.integer(forKey: "speedUnit")
        switch speedUnitKey {
        case 1: speedUnit = .mph
        case 2: speedUnit = .kmh
        default: speedUnit = .knot
        }
    }
    //
    mutating func updateVisibility() {
        let visibilityUnitKey = UserDefaults.standard.integer(forKey: "visibilityUnit")
        switch visibilityUnitKey {
        case 1: visibilityUnit = .kilometer
        default: visibilityUnit = .mile
        }
    }
    //
    mutating func updateAltitude() {
        let altitudeUnitKey = UserDefaults.standard.integer(forKey: "altitudeUnit")
        switch altitudeUnitKey {
        case 1: altitudeUnit = .meter
        default: altitudeUnit = .feet
        }
    }
    //
    mutating func updatePressure() {
        let pressureUnitKey = UserDefaults.standard.integer(forKey: "pressureUnit")
        switch pressureUnitKey {
        case 1: pressureUnit = .mbar
        default: pressureUnit = .inHg
        }
    }
    //
    mutating func updateHomeAirport() {
        homeAirport = UserDefaults.standard.string(forKey: "homeAirport") ?? ""
    }
    //
    mutating func update() {
        updateTemperature()
        updateSpeed()
        updateVisibility()
        updateAltitude()
        updatePressure()
        updateHomeAirport()
    }
    //
    init() {
        self.temperatureUnit = .celsius
        self.speedUnit = .knot
        self.visibilityUnit = .mile
        self.altitudeUnit = .feet
        self.pressureUnit = .inHg
        self.homeAirport = ""
        update()
    }
    var speedUnitString: String {
        switch speedUnit {
        case .knot: return "kt"
        case .mph: return "mph"
        case .kmh: return "km/h"
        }
    }
}
