//
//  Core.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/26/22.
//

import Foundation
import SwiftUI

// Enumeration for errors. To be expanded.
enum Errors: Error {
    case noReportFound, noAirportCodes
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension Double {
    var metersToFeet: Double {self / 0.3048}
    var feetToMeters: Double {self * 0.3048}
    var kmToMile: Double {self / 1.609}
    var mileToKm: Double {self * 1.609}
    var meterToMile: Double {self / 1609}
    var mileToMeter: Double {self * 1609}
    var kmToNautMile: Double {self / 1.852}
    var nautMileToKm: Double {self * 1.852}
    var nautMileToStatute: Double {self * 1.15078}
}

extension Int {
    var metersToFeet: Int {Int(Double(self).metersToFeet.rounded())}
    var feetToMeters: Int {Int(Double(self).feetToMeters.rounded())}
    var kmToMile: Int {Int(Double(self).kmToMile.rounded())}
    var mileToKm: Int {Int(Double(self).mileToKm.rounded())}
    var meterToMile: Int {Int(Double(self).meterToMile.rounded())}
    var mileToMeter: Int {Int(Double(self).mileToMeter.rounded())}
    var kmToNautMile: Int {Int(Double(self).kmToNautMile.rounded())}
    var nautMileToKm: Int {Int(Double(self).nautMileToKm.rounded())}
    var nautMileToStatute: Int {Int(Double(self).nautMileToStatute.rounded())}
}

// Loads custom colors from assets folder and assigns them as properties to the Color struct.
extension Color {
    static let bicolor = Color("Bicolor")
    static let bicolorInv = Color("BicolorInv")
    static let bicolorCaution = Color("BicolorCaution")
    static let bicolorCautionInv = Color("BicolorCautionInv")
    static let darkGreen = Color("DarkGreen")
    static let darkBlue = Color("DarkBlue")
    static let darkRed = Color("DarkRed")
    static let magenta = Color("Magenta")
    static let groundBackground = Color("GroundBackground")
    static let skyBackground = Color("SkyBackground")
    static let grayBackground = Color("GrayBackground")
}

// Enumeration for temperature units.
enum TemperatureUnit: Int {
    case celsius = 0 // degrees Celsius
    case fahrenheit = 1// degrees Fahrenheit
}

// Enum for speed units
enum SpeedUnit: Int {
    case knot = 0 // knots
    case mph = 1 // miles per hour
    case kmh = 2 // kilometers per hour
}

/* Enum for visibility units. Note: in the U.S., visibility is generally reported in statute miles, not nautical.
 Elsewhere, generally metric is used.*/
enum VisUnit: Int {
    case mile = 0 // statute miles
    case kilometer = 1 // kilometers
}

enum AltitudeUnit: Int {
    case feet = 0 // feet
    case meter = 1 // meters
}

enum PressureUnit: Int {
    case inHg = 0 // inches of mercury
    case mbar = 1 // millibars
}

/* Enumeration for flight conditions. Color pallette follows SkyVector planning tools.
 These are a function of ceiling height & visibility, ordered from least to most restrictive.
 The governing condition is the most restrictive one for which criteria are met. */
enum FlightConditions: String {
    // Visual Flight Rules (VFR): No ceiling OR ceiling > 3000ft AND visibility > 5mi
    case vfr = "VFR"
    // Marginal VFR (MVFR): 1000ft <= ceiling <= 3000ft OR 3mi <= visibility <= 5mi
    case mvfr = "MVFR"
    /* Instrument Flight Rules (IFR): 500ft <= ceiling < 1000ft OR 1mi <= visibility < 3mi.
     Operations by visual reference are not allowed. */
    case ifr = "IFR"
    // Low IFR (LIFR): ceiling < 500ft OR visibility < 1mi.
    case lifr = "LIFR"
    // Unknown, for when there is no data.
    case unknown = "Unknown"
}

func formatNumber(_ input: NSNumber, decimals: Int = 0, atLeast minDecimals: Int = 0, showPlusSign: Bool = false) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = max(decimals, 0)
    if minDecimals > 0 {
        formatter.minimumFractionDigits = min(minDecimals, formatter.maximumFractionDigits)
    }
    if showPlusSign {
        formatter.positivePrefix = formatter.plusSign
    }
    return formatter.string(from: input)!
}
