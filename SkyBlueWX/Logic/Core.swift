//
//  Core.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/26/22.
//

import Foundation
import SwiftUI


// Loads custom colors from assets folder and assigns them as properties to the Color struct.
extension Color {
    static let bicolor = Color("Bicolor")
    static let bicolorInv = Color("BicolorInv")
    static let bicolorCaution = Color("BicolorCaution")
    static let darkGreen = Color("DarkGreen")
    static let darkBlue = Color("DarkBlue")
    static let darkRed = Color("DarkRed")
    static let magenta = Color("Magenta")
}


// Enumeration for temperature units.
enum TemperatureUnit : Int {
    case C = 0 // degrees Celsius
    case F = 1// degrees Fahrenheit
}

// Enum for speed units
enum SpeedUnit : Int {
    case knot = 0 // knots
    case mph = 1 // miles per hour
    case kmh = 2 // kilometers per hour
}

// Enum for visibility units. Note: in the U.S., visibility is generally reported in statute miles, not nautical. Elsewhere, generally metric is used.
enum VisUnit : Int {
    case mile = 0 // statute miles
    case km = 1 // kilometers
}

// Enumeration for flight conditions. Color pallette follows SkyVector planning tools. These are a function of ceiling height & visibility, ordered from least to most restrictive. The governing condition is the most restrictive one for which criteria are met.
enum FlightConditions : String {
    // Visual Flight Rules (VFR): No ceiling OR ceiling > 3000ft AND visibility > 5mi
    case vfr = "VFR"
    // Marginal VFR (MVFR): 1000ft <= ceiling <= 3000ft OR 3mi <= visibility <= 5mi
    case mvfr = "MVFR"
    // Instrument Flight Rules (IFR): 500ft <= ceiling < 1000ft OR 1mi <= visibility < 3mi. Operations by visual reference are not allowed.
    case ifr = "IFR"
    // Low IFR (LIFR): ceiling < 500ft OR visibility < 1mi.
    case lifr = "LIFR"
}
