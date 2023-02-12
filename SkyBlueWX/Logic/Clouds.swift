//
//  Clouds.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/12/23.
//

import Foundation

enum CloudCover: String {
    case few = "FEW"
    case scattered = "SCT"
    case broken = "BKN"
    case overcast = "OVC"
    case obscured = "VV"
}

enum SpecialClouds {
    case cumulonimbus, toweringCumulus
}

// Made as a constant struct, tuples should have max. 2 terms./
struct CloudLayer: Equatable {
    let cover: CloudCover
    let height: Int
    let specialCloud: SpecialClouds?
    static func == (lhs: CloudLayer, rhs: CloudLayer) -> Bool {
        return lhs.cover == rhs.cover &&
        lhs.height == rhs.height &&
        lhs.specialCloud == rhs.specialCloud
    }
    init(_ cover: CloudCover, _ height: Int, _ specialCloud: SpecialClouds?) {
        self.cover = cover
        self.height = height
        self.specialCloud = specialCloud
    }
    init(cover: CloudCover, height: Int, specialCloud: SpecialClouds?) {
        self.cover = cover
        self.height = height
        self.specialCloud = specialCloud
    }
}
