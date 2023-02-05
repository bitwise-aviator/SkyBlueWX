//
//  FlightRulesIconSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI

struct FlightRulesIconSmallView: View {
    @EnvironmentObject var cockpit : Cockpit
    
    var flightRulesIconPath : String {
        get {
            guard let _ = cockpit.activeReportStruct else { return "x.circle.fill" }
            switch cockpit.activeReportStruct!.flightCondition {
                case .vfr: return "v.circle.fill"
                case .mvfr: return "m.circle.fill"
                case .ifr: return "i.circle.fill"
                case .lifr: return "l.circle.fill"
            }
        }
    }
    
    var flightRulesColor : Color {
        get {
            guard let _ = cockpit.activeReportStruct else { return .white }
            return cockpit.activeReportStruct!.flightConditionColor
        }
    }
    
    var body: some View {
        Image(systemName: flightRulesIconPath).foregroundColor(flightRulesColor)
    }
}

struct FlightRulesIconSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        FlightRulesIconSmallView().environmentObject(cockpit)
    }
}
