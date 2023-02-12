//
//  AirportTileFlightRuleView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/5/23.
//

import SwiftUI

struct AirportTileFlightRuleView: View {
    @EnvironmentObject var cockpit: Cockpit
    let icao: String
    var boundReport: WeatherReport? {
        guard let report = cockpit.reports[icao] else {return nil}
        guard cockpit.reports[icao]!.hasData else {return nil}
        return report
    }
    var textString: String {
        boundReport?.flightCondition.rawValue ?? "---"
    }
    var textBackground: Color {
        boundReport?.flightConditionColor ?? Color.grayBackground
    }
    var body: some View {
        Text(textString).padding([.horizontal], 10).padding([.vertical], 5).background(textBackground)
    }
}

struct AirportTileFlightRuleView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        AirportTileFlightRuleView(icao: "").environmentObject(cockpit)
    }
}
