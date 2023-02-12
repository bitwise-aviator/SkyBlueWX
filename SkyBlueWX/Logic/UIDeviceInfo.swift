//
//  UIDeviceInfo.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import Foundation
import UIKit

enum Device: String {
    case pad = "iPad"
    case phone = "iPhone"
    case other = "other"
}

struct UIDeviceInfo {
    let deviceType: Device
    var iOS15available: Bool {
        if #available(iOS 15, *) {return true}
        return false
    }
    init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: self.deviceType = .phone
        case .pad: self.deviceType = .pad
        default: self.deviceType = .other
        }
    }
}
