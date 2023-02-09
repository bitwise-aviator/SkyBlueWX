//
//  Logic.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

import Foundation
import SwiftUI
import CoreLocation

let thousandsNumber = NumberFormatter()

typealias CloudLayer = (cover: CloudCover, height: Int, specialCloud: SpecialClouds?)

enum CloudCover : String {
    case few = "FEW"
    case scattered = "SCT"
    case broken = "BKN"
    case overcast = "OVC"
    case obscured = "VV"
}

enum SpecialClouds {
    case cumulonimbus, toweringCumulus
}

enum CardinalDirections: String {
    case N = "north"
    case NE = "northeast"
    case E = "east"
    case SE = "southeast"
    case S = "south"
    case SW = "southwest"
    case W = "west"
    case NW = "northwest"
}

enum Precipitation: String {
    case light = "light"
    case moderate = "moderate"
    case heavy = "heavy"
}

struct WeatherDetails {
    var rain : Precipitation?
    var snow : Precipitation?
    var drizzle : Precipitation?
    var showers : Precipitation?
    
    var isRaining : Bool {
        rain != nil
    }
    
    var isSnowing : Bool {
        snow != nil
    }
    
    var thunderStormsReported : Bool
    
    init(text txt: String) {
        rain = nil
        snow = nil
        drizzle = nil
        showers = nil
        thunderStormsReported = txt.contains("TS")
        
        if txt.contains("RA") {
            if txt.contains("-RA") {rain = Precipitation.light}
            else if txt.contains("+RA") {rain = Precipitation.heavy}
            else {rain = Precipitation.moderate}
        }
        
        if txt.contains("SN") {
            if txt.contains("-SN") {snow = Precipitation.light}
            else if txt.contains("+SN") {snow = Precipitation.heavy}
            else {snow = Precipitation.moderate}
        }
    }
}

struct Wind {
    var direction : Int? // If left to nil, wind direction is variable.
    var cardinal: String?
    var isVariable : Bool { // True: VRB in a METAR.
        get {
            direction == nil || direction == 0 // FAA returns VRB as direction 0.
        }
    }
    var speed : Int
    // Gusts: Leave as nil if no gusts are recorded.
    var gusts : Int? {
        didSet {
            if let _ = gusts {
                // If gusts are reported as below the wind speed, this is likely an error -> Report no gusts.
                if gusts! < speed {
                    gusts = nil
                }
            }
        }
    }
    var hasGusts : Bool {
        get {
            gusts != nil
        }
    }
    
    // Initializer for winds.
    init(direction _direction: Int?, speed _speed: Int, gusts _gusts: Int?) {
        self.direction = _direction // API reports in degrees true.
        self.speed = _speed // API reports in knots.
        self.gusts = _gusts // API reports in knots.
    }
    
    func toText() -> String {
        var desc : String = ""
        if speed == 0 {
            return "The wind is calm."
        } else {
            if isVariable {
                desc += "The wind has variable direction "
            } else {
                desc += "The wind is blowing from the \(getCardinalDirection(degrees: direction)!) "
            }
            desc += "at a speed of \(speed) knots"
            if hasGusts {
                desc += " gusting to \(gusts!) knots."
            } else {
                desc += "."
            }
        }
        return desc
    }
    
    
}

struct WeatherReport {
    var hasData : Bool
    var icao : String
    var coords : CLLocation
    
    var clouds : [CloudLayer]
    
    
    var ceilingLayer : CloudLayer? {
        get {
            findCeiling(cloudList: clouds)
        }
    }
    var hasCeiling : Bool {
        get {
            ceilingLayer != nil
        }
    }
    var ceilingHeight : Int? {
        get {
            hasCeiling ? (ceilingLayer)!.height : nil
        }
    }
    
    var visibility : Double
    func visibilityToString(unit: VisUnit) -> String {
        guard hasData else {return "----"}
        if unit == .mile {
            if visibility.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(String(Int(visibility))) mi"
            } else {
                return "\(String(format: "%.2f", visibility)) mi"
            }
        } else {
            if 1.609 * visibility >= 1.0 {
                return "\(String(format: "%.2f", 1.609 * visibility)) km"
            } else {
                print(1609 * visibility)
                return "\(String(Int(1609 * visibility))) m"
            }
        }
    }
    
    var flightCondition : FlightConditions {
        get {
            guard hasData else {return .unknown}
            let ceiling = ceilingHeight ?? Int.max
            if ceiling < 500 || visibility < 1 {return .lifr}
            else if ceiling < 1000 || visibility < 3 {return .ifr}
            else if ceiling <= 3000 || visibility <= 5 {return .mvfr}
            else {return .vfr}
        }
    }
    
    var flightConditionColor : Color {
        switch flightCondition {
        case .vfr: return .darkGreen
        case .mvfr: return .blue
        case .ifr: return .darkRed
        case .lifr: return .magenta
        case .unknown: return .bicolor
        }
        
    }
    
    var temperature : Double
    
    func temperatureToString(unit: TemperatureUnit) -> String {
        guard hasData else {return "----"}
        switch unit {
        case .C : return "\(Int(round(temperature)))°C"
        case .F : return "\(Int(round((1.8 * temperature) + 32)))°F"
        }
    }
    
    var dewPoint : Double
    
    func dewpointToString(unit: TemperatureUnit) -> String {
        guard hasData else {return "----"}
        switch unit {
        case .C : return "\(Int(round(dewPoint)))°C"
        case .F : return "\(Int(round((1.8 * dewPoint) + 32)))°F"
        }
    }
    var relativeHumidity : Double {
        get {
            guard hasData else {return 0.0}
            return relHumidity(temperature: temperature, dewpoint: dewPoint)
        }
    }
    var wind : Wind
    func windSpeedToString(unit: SpeedUnit) -> String {
        if !hasData {return "--"}
        switch unit {
        case .knot: return String(wind.speed)
        case .kmh: return String(Int((Double(wind.speed) * 1.852).rounded()))
        case .mph: return String(Int((Double(wind.speed) * 1.15078).rounded()))
        }
    }
    
    func altimeterToString(unit: PressureUnit) -> String {
        if !hasData {return "----"}
        switch unit {
        case .inHg: return "\(String(format: "%.2f", altimeter))\""
        case .mbar: return "Q\(String(format: "%.0f", altimeter * 33.8639))"
        }
    }
    
    func windGustsToString(unit: SpeedUnit) -> String {
        if !hasData {return "--"}
        guard let gusts = wind.gusts else {return "--"}
        switch unit {
        case .knot: return String(gusts)
        case .kmh: return String(Int((Double(gusts) * 1.852).rounded()))
        case .mph: return String(Int((Double(gusts) * 1.15078).rounded()))
        }
    }
    
    var windDirToString : String {
        get {
            guard hasData else {return "---° --"}
            if wind.isVariable && wind.speed == 0 {return "CALM"}
            else if wind.isVariable {return "VRB"}
            let windDir : String
            switch (wind.direction!) {
            case 338...360, 0..<23: windDir = "N"
            case 23..<68: windDir = "NE"
            case 68..<113: windDir = "E"
            case 113..<158: windDir = "SE"
            case 158..<203: windDir = "S"
            case 203..<248: windDir = "SW"
            case 248..<293: windDir = "W"
            case 293..<338: windDir = "NW"
            default: windDir = "--"
            }
            return "\(String(format: "%03d", wind.direction!))° \(windDir)"
        }
    }
    
    var details : WeatherDetails

    var altimeter : Double
    
    var elevation : Double
    
    var stationPressure : Double {
        get {
         /* Weather reports return sea level atmospheric pressure. Need to convert to local pressure
          */
            // Station elevation is returned in meters and altimeter settings is returned in inHg, no need to redeclare anything.
            return altimeter * pow((288-0.0065*elevation)/288, 5.2561)
            
        }
    }
    
    var densityAltitude : Double {
        /* Density altitude is an important concept for pilots because it represents the equivalent airfield altitude if standard atmosphere conditions existed. Hot temperature, low pressure, and high humidity all affect aircraft performance negatively and increase the density altitude.
         */
        get {
            /* Using density altitude formula as available in
             https://www.weather.gov/media/epz/wxcalc/densityAltitude.pdf */
            let stnPressure = stationPressure
            // Dewpoint required in Celsius, no need to redeclare.
            let airTemperature = temperature + 273.16 // Air temperature in Kelvin
            // Station pressure is available in inHg, no need to redeclare.
            let stationPressureMB = stnPressure * 33.8639 // Also need a version in millibars (mb)
            let e = 6.11 * pow(10, ((7.5 * dewPoint)/(237.7 + dewPoint))) // vapor pressure
            let tv = airTemperature / (1 - (e/stationPressureMB) * (1-0.622)) // virtual temperature in Kelvin
            let tvRankine = (1.8 * (tv - 273.16) + 32) + 459.69// need virtual temperature in Rankine
            return 145366 * (1 - pow(17.326 * stnPressure / tvRankine, 0.235))
        }
    }
    
    func densityAltitudeToString(unit: AltitudeUnit) -> String {
        guard hasData else {return "-----"}
        if unit == .m {
            return "\(String(format: "%.0f", densityAltitude * 0.3048)) m"
        } else {
            return "\(String(format: "%.0f", densityAltitude)) ft"
        }
    }
    
    var wxIcon : String {
        get {
            guard hasData else {return "questionmark.square.dashed"}
            if details.thunderStormsReported {
                if details.isRaining || details.isSnowing {
                    return "cloud.bolt.rain.fill"
                }
                else if hasCeiling {
                    return "cloud.bolt.fill"
                }
                else {
                    return "cloud.sun.bolt.fill"
                }
            }
            if details.isRaining {
                return details.rain! == Precipitation.heavy ? "cloud.heavyrain.fill" : "cloud.rain.fill"
            }
            else if details.isSnowing {
                return "cloud.snow.fill"
            }
            else if hasCeiling {
                return "cloud.fill"
            }
            else {
                return "sun.max.fill"
            }
            
        }
    }
    
    var wxColor : Color {
        get {
            guard hasData else {return .bicolor}
            if details.thunderStormsReported {
                return Color.bicolorCaution // Use this color for critical weather, such as thunderstorms.
            }
            if details.isRaining {
                return Color.blue
            }
            else if details.isSnowing {
                return Color.cyan
            }
            else if hasCeiling {
                return Color.gray
            }
            else {
                return Color.yellow
            }
            
        }
    }
    
    init(location _icao : String) {
        // Outline initializer. It is not considered a working struct until updated.
        self.icao = _icao
        self.hasData = false
        self.coords = CLLocation(latitude: 0.0, longitude: 0.0)
        self.clouds = []
        self.visibility = 0.0
        self.temperature = 0.0
        self.dewPoint = 0.0
        self.wind = Wind(direction: 0, speed: 0, gusts: nil)
        self.details = WeatherDetails(text: "")
        self.altimeter = 0.0
        self.elevation = 0.0
    }
        
    init(location _icao : String, coordinates _coords : CLLocation, clouds _clouds: [CloudLayer], visibility _visibility: Double, temperature _temperature: Double = 0.0, dewPoint _dewPoint: Double = 0.0, wind _wind: Wind, details _details : String, altimeter _altimeter : Double, elevation _elevation : Double) {
        self.icao = _icao
        self.hasData = true
        self.coords = _coords
        self.clouds = _clouds
        self.visibility = _visibility
        self.temperature = _temperature
        self.dewPoint = _dewPoint
        self.wind = _wind
        self.details = WeatherDetails(text: _details)
        self.altimeter = _altimeter
        self.elevation = _elevation
    }
    
    mutating func update(location _icao : String, coordinates _coords : CLLocation, clouds _clouds: [CloudLayer],  visibility _visibility: Double, temperature _temperature: Double = 0.0, dewPoint _dewPoint: Double = 0.0, wind _wind: Wind, details _details : String, altimeter _altimeter : Double, elevation _elevation : Double) {
        icao = _icao
        hasData = true
        coords = _coords
        clouds = _clouds
        visibility = _visibility
        temperature = _temperature
        dewPoint = _dewPoint
        wind = _wind
        details = WeatherDetails(text: _details)
        altimeter = _altimeter
        elevation = _elevation
        
    }
    
}

func relHumidity (temperature temp: Double, dewpoint dewpt: Double) -> Double {
    return 100 * (exp((17.625*dewpt)/(243.04+dewpt))/exp((17.625*temp)/(243.04+temp)))
}

func findCeiling (cloudList : [CloudLayer]) -> CloudLayer? {
    var ceiling : Int? = nil
    var ceilingLayer : CloudLayer? = nil
    for layer in cloudList {
        var isCeiling = false;
        switch layer.cover {
            case .broken, .overcast, .obscured:
                isCeiling = true
            default:
                break
        }
        // 2nd condition is used to handle nil values. If nil, short-circuit occurs.
        // 3rd condition only triggers if ceiling is not nil. It is safe to force-unwrap (!) here, as nils have been already addressed.
        if isCeiling && (ceiling == nil || ceiling! > layer.height) {
            ceiling = layer.height
            ceilingLayer = layer
        }
    }
    return ceilingLayer
}

func getCardinalDirection(degrees: Int?) -> String? {
    guard let deg = degrees else {
        return nil
    }
    switch deg {
    case 0: return nil
    case 338...360, 0..<23: return CardinalDirections.N.rawValue
    case 23..<68: return CardinalDirections.NE.rawValue
    case 68..<113: return CardinalDirections.E.rawValue
    case 113..<158: return CardinalDirections.SE.rawValue
    case 158..<203: return CardinalDirections.S.rawValue
    case 203..<248: return CardinalDirections.SW.rawValue
    case 248..<293: return CardinalDirections.W.rawValue
    case 293..<338: return CardinalDirections.NW.rawValue
    default: return nil
    }
}


func updateWeather(airport icao: String = "KRDU") {
    
}
