//
//  WeatherReport.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

import Foundation
import SwiftUI
import CoreLocation

let thousandsNumber = NumberFormatter()

enum Precipitation {
    case light
    case moderate
    case heavy
}

enum Obscuration {
    case mist
    case fog
    case smoke
    case ash
    case dust
    case sand
    case haze
}

struct WeatherDetails {
    var rain: Precipitation?
    var snow: Precipitation?
    var drizzle: Precipitation?
    var showers: Precipitation?
    var isRaining: Bool {
        rain != nil
    }
    var isSnowing: Bool {
        snow != nil
    }
    var thunderStormsReported: Bool
    var obscurations: [Obscuration] = []
    init(text txt: String) {
        rain = nil
        snow = nil
        drizzle = nil
        showers = nil
        thunderStormsReported = txt.contains("TS")
        if txt.contains("RA") {
            let rainRegex = /([+-])?[A-Z]*(RA)/
            let rainExtract = txt.firstMatch(of: rainRegex)
            if let rainResult = rainExtract {
                if rainResult.1 == nil {rain = Precipitation.moderate} else
                if rainResult.1! == "+" {rain = Precipitation.heavy} else {
                    rain = Precipitation.light
                }
            }
        }
        if txt.contains("SN") {
            let snowRegex = /([+-])?[A-Z]*(SN)/
            let snowExtract = txt.firstMatch(of: snowRegex)
            if let snowResult = snowExtract {
                if snowResult.1 == nil {snow = Precipitation.moderate} else
                if snowResult.1! == "+" {snow = Precipitation.heavy} else {
                    snow = Precipitation.light
                }
            }
        }
        self.parseObscurations(txt)
    }
    mutating func parseObscurations(_ txt: String) {
        if txt.contains("BR") {obscurations.append(.mist)}
        if txt.contains("FG") {obscurations.append(.fog)}
        if txt.contains("FU") {obscurations.append(.smoke)}
        if txt.contains("VA") {obscurations.append(.ash)}
        if txt.contains("DU") {obscurations.append(.dust)}
        if txt.contains("SA") {obscurations.append(.sand)}
        if txt.contains("HZ") {obscurations.append(.haze)}
    }
}

struct WeatherReport {
    // Stored
    var hasData: Bool
    var icao: String
    var airport: Airport?
    var coords = CLLocation(latitude: 0.0, longitude: 0.0)
    var reportTime: Date?
    var clouds: [CloudLayer] = []
    var visibility: Double = 0.0
    var temperature: Double = 0.0
    var dewPoint: Double = 0.0
    var wind = Wind(direction: 0, speed: 0, gusts: nil)
    var details = WeatherDetails(text: "")
    var altimeter: Double = 0.0
    var elevation: Double = 0.0
    //
    // Computed
    var ceilingLayer: CloudLayer? {
        findCeiling(cloudList: clouds)
    }
    var hasCeiling: Bool {
        ceilingLayer != nil
    }
    var ceilingHeight: Int? {
        hasCeiling ? (ceilingLayer)!.height: nil
    }
    var flightCondition: FlightConditions {
        guard hasData else {return .unknown}
        let ceiling = ceilingHeight ?? Int.max
        if ceiling < 500 || visibility < 1 {return .lifr} else
        if ceiling < 1000 || visibility < 3 {return .ifr} else
        if ceiling <= 3000 || visibility <= 5 {return .mvfr}
        return .vfr
    }
    var flightConditionColor: Color {
        switch flightCondition {
        case .vfr: return .darkGreen
        case .mvfr: return .blue
        case .ifr: return .darkRed
        case .lifr: return .magenta
        case .unknown: return .bicolor
        }
    }
    var relativeHumidity: Double {
        guard hasData else {return 0.0}
        return relHumidity(temperature: temperature, dewpoint: dewPoint)
    }
    var windDirToString: String {
        guard hasData else {return "---?? --"}
        if wind.isVariable && wind.speed == 0 {return "CALM"} else
        if wind.isVariable {return "VRB"}
        let windDir: String
        switch wind.direction! {
        case 338...360, 0..<23: windDir = "N"
        case 23..<68: windDir = "NE"
        case 68..<113: windDir = "E"
        case 113..<158: windDir = "SE"
        case 158..<203: windDir = "S"
        case 203..<248: windDir = "SW"
        case 248..<293: windDir = "W"
        case 293..<338: windDir = "NW"
        default: return "---?? --"
        }
        return "\(String(format: "%03d", wind.direction!))?? \(windDir)"
    }
    var timeSinceReport: (hours: Int, minutes: Int)? {
        guard hasData else {return nil}
        guard let timestamp = reportTime else {return nil}
        #if TESTING
        let timeDiff = 300 // Set a 5-minute age for testing.
        #else
        let timeDiff = Int(Date.now - timestamp)
        #endif
        // print(timeDiff)
        let hrs = timeDiff.quotientAndRemainder(dividingBy: 3600)
        let mins = hrs.remainder / 60
        // print(hrs.quotient, mins)
        return (hours: hrs.quotient, minutes: mins)
    }
    var stationPressure: Double {
        /* Weather reports return sea level atmospheric pressure. Need to convert to local pressure
        */
        // Station elevation is returned in meters and altimeter settings is returned in inHg.
        // No need to redeclare anything.
        return altimeter * pow((288-0.0065*elevation)/288, 5.2561)
    }
    var densityAltitude: Double {
        /* Density altitude is an important concept for pilots because it represents the equivalent airfield altitude if
         standard atmosphere conditions existed. Hot temperature, low pressure, and high humidity all affect
         aircraft performance negatively and increase the density altitude.
         */
        /* Using density altitude formula as available in
         https://www.weather.gov/media/epz/wxcalc/densityAltitude.pdf */
        let stnPressure = stationPressure
        // Dewpoint required in Celsius, no need to redeclare.
        let airTemperature = temperature + 273.16 // Air temperature in Kelvin
        // Station pressure is available in inHg, no need to redeclare.
        let stationPressureMB = stnPressure * 33.8639 // Also need a version in millibars (mb)
        let vaporPressure = 6.11 * pow(10, ((7.5 * dewPoint)/(237.7 + dewPoint))) // vapor pressure
        let virtualTemperature = airTemperature /
        (1 - (vaporPressure/stationPressureMB) * (1-0.622)) // virtual temperature in Kelvin
        let tvRankine = (1.8 * (virtualTemperature - 273.16) + 32) + 459.69// need virtual temperature in Rankine
        return 145366 * (1 - pow(17.326 * stnPressure / tvRankine, 0.235))
    }
    var densityAltitudeDelta: Double {
        // returns in feet.
        densityAltitude - elevation.metersToFeet
    }
    var wxIcon: String {
        guard hasData else {return "questionmark.square.dashed"}
        if details.thunderStormsReported {
            if details.isRaining || details.isSnowing {
                return "cloud.bolt.rain.fill"
            } else if hasCeiling {
                return "cloud.bolt.fill"
            } else {
                return "cloud.sun.bolt.fill"
            }
        }
        if details.isRaining {
            return details.rain! == Precipitation.heavy ? "cloud.heavyrain.fill": "cloud.rain.fill"
        } else if details.isSnowing {
            return "cloud.snow.fill"
        } else if hasCeiling {
            return "cloud.fill"
        } else {
            return "sun.max.fill"
        }
    }
    var wxColor: Color {
        guard hasData else {return .bicolor}
        if details.thunderStormsReported {
            return Color.bicolorCaution // Use this color for critical weather, such as thunderstorms.
        }
        if details.isRaining {
            return Color.blue
        } else if details.isSnowing {
            return Color.cyan
        } else if hasCeiling {
            return Color.gray
        } else {
            return Color.yellow
        }
    }
    //
    // Initializers
    init(location icao: String, airport: Airport? = nil) {
        // Outline initializer. It is not considered a working struct until updated.
        self.icao = icao
        self.airport = airport
        self.hasData = false
    }
    init(location icao: String, coordinates: CLLocation, reportTime: Date?, clouds: [CloudLayer], visibility: Double,
         temperature: Double = 0.0, dewPoint: Double = 0.0, wind: Wind, details: String, altimeter: Double,
         elevation: Double, airport: Airport? = nil) {
        self.icao = icao
        self.airport = airport
        self.hasData = true
        self.coords = coordinates
        self.reportTime = reportTime
        self.clouds = clouds
        self.visibility = visibility
        self.temperature = temperature
        self.dewPoint = dewPoint
        self.wind = wind
        self.details = WeatherDetails(text: details)
        self.altimeter = altimeter
        self.elevation = elevation
    }
    //
    // Functions
    //
    func visibilityToString(unit: VisUnit) -> String {
        guard hasData else {return "----"}
        if unit == .mile {
            if visibility.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(String(Int(visibility))) mi"
            } else if [0.25, 0.5, 0.75].contains(visibility.truncatingRemainder(dividingBy: 1)) {
                let remainder = visibility.truncatingRemainder(dividingBy: 1)
                let fraction: String
                switch remainder {
                case 0.25: fraction = "1/4"
                case 0.5: fraction = "1/2"
                case 0.75: fraction = "3/4"
                default: fraction = ""
                }
                if visibility >= 1 {
                    let visibilityInteger = formatNumber(NSNumber(value: Int(visibility)), decimals: 0)
                    return "\(visibilityInteger) \(fraction) mi"
                } else {
                    return "\(fraction) mi"
                }
            } else {
                let visibilityString = formatNumber(NSNumber(value: visibility), decimals: 2)
                return "\(visibilityString) mi"
            }
        } else {
            if visibility.mileToKm >= 1.0 {
                let visibilityString = formatNumber(NSNumber(value: visibility.mileToKm), decimals: 2)
                return "\(visibilityString) km"
            } else {
                let visibilityString = formatNumber(NSNumber(value: visibility.mileToMeter))
                return "\(visibilityString) m"
            }
        }
    }
    //
    func temperatureToString(unit: TemperatureUnit) -> String {
        guard hasData else {return "----"}
        switch unit {
        case .celsius: return "\(Int(round(temperature)))??C"
        case .fahrenheit: return "\(Int(round((1.8 * temperature) + 32)))??F"
        }
    }
    //
    func dewpointToString(unit: TemperatureUnit) -> String {
        guard hasData else {return "----"}
        switch unit {
        case .celsius: return "\(Int(round(dewPoint)))??C"
        case .fahrenheit: return "\(Int(round((1.8 * dewPoint) + 32)))??F"
        }
    }
    //
    func windSpeedToString(unit: SpeedUnit) -> String {
        if !hasData {return "--"}
        switch unit {
        case .knot: return String(wind.speed)
        case .kmh: return String(wind.speed.nautMileToKm)
        case .mph: return String(wind.speed.nautMileToStatute)
        }
    }
    //
    func altimeterToString(unit: PressureUnit) -> String {
        if !hasData {return "----"}
        switch unit {
        case .inHg:
            let altimeterString = formatNumber(NSNumber(value: altimeter), decimals: 2, atLeast: 2)
            return "\(altimeterString)\""
        case .mbar:
            return "Q\(String(format: "%.0f", altimeter * 33.8639))"
        }
    }
    //
    func windGustsToString(unit: SpeedUnit) -> String {
        if !hasData {return "--"}
        guard let gusts = wind.gusts else {return "--"}
        switch unit {
        case .knot: return String(gusts)
        case .kmh: return String(gusts.nautMileToKm)
        case .mph: return String(gusts.nautMileToStatute)
        }
    }
    func densityAltitudeToString(unit: AltitudeUnit) -> String {
        guard hasData else {return "-----"}
        if unit == .meter {
            let resultString = formatNumber(NSNumber(value: densityAltitude.feetToMeters))
            return "\(resultString) m"
        } else {
            let resultString = formatNumber(NSNumber(value: densityAltitude))
            return "\(resultString) ft"
        }
    }
    func densityAltitudeDeltaToString(unit: AltitudeUnit) -> String {
        guard hasData else {return "-----"}
        if unit == .meter {
            return "\(formatNumber(NSNumber(value: densityAltitudeDelta.feetToMeters), showPlusSign: true)) m"
        } else {
            return "\(formatNumber(NSNumber(value: densityAltitudeDelta), showPlusSign: true)) ft"
        }
    }
    //
}

func relHumidity (temperature temp: Double, dewpoint dewpt: Double) -> Double {
    return 100 * (exp((17.625*dewpt)/(243.04+dewpt))/exp((17.625*temp)/(243.04+temp)))
}

func findCeiling (cloudList: [CloudLayer]) -> CloudLayer? {
    var ceiling: Int?
    var ceilingLayer: CloudLayer?
    for layer in cloudList {
        var isCeiling = false
        switch layer.cover {
        case .broken, .overcast, .obscured: isCeiling = true
        default: break
        }
        // 2nd condition is used to handle nil values. If nil, short-circuit occurs.
        /* 3rd condition only triggers if ceiling is not nil.
         It is safe to force-unwrap (!) here, as nils have been already addressed.*/
        if isCeiling && (ceiling == nil || ceiling! > layer.height) {
            ceiling = layer.height
            ceilingLayer = layer
        }
    }
    return ceilingLayer
}
