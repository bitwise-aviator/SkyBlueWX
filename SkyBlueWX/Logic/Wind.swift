//
//  Wind.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/12/23.
//

import Foundation

enum CardinalDirections {
    case north
    case northeast
    case east
    case southeast
    case south
    case southwest
    case west
    case northwest
}

struct Wind {
    var direction: Int? // If left to nil, wind direction is variable.
    var cardinal: String?
    var isVariable: Bool { // True: VRB in a METAR.
        direction == nil || direction == 0 // FAA returns VRB as direction 0.
    }
    var speed: Int
    // Gusts: Leave as nil if no gusts are recorded.
    var gusts: Int? {
        didSet {
            if gusts != nil {
                // If gusts are reported as below the wind speed, this is likely an error -> Report no gusts.
                if gusts! < speed {
                    gusts = nil
                }
            }
        }
    }
    var hasGusts: Bool {
        gusts != nil
    }
    // Initializer for winds.
    init(direction: Int?, speed: Int, gusts: Int?) {
        self.direction = direction // API reports in degrees true.
        self.speed = speed // API reports in knots.
        self.gusts = gusts // API reports in knots.
    }
}
