//
//  FlightRulesIconSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI

struct FlightRulesIconSmallView: View {
    @EnvironmentObject var cockpit: Cockpit
    var flightRulesIconPath: String {
        guard let report = cockpit.activeReportStruct else { return "x.circle.fill" }
        switch report.flightCondition {
        case .vfr: return "v.circle.fill"
        case .mvfr: return "m.circle.fill"
        case .ifr: return "i.circle.fill"
        case .lifr: return "l.circle.fill"
        case .unknown: return "x.circle.fill"
        }
    }
    var flightRulesColor: Color {
        guard let report =  cockpit.activeReportStruct else { return .bicolor }
        return report.flightConditionColor
    }
    var body: some View {
        Image(systemName: flightRulesIconPath).foregroundColor(flightRulesColor)
    }
}

#if !TESTING
struct FlightRulesIconSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        FlightRulesIconSmallView().environmentObject(cockpit)
    }
}
#endif
