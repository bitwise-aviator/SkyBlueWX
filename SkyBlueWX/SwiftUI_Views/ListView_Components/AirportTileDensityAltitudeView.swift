//
//  AirportTileDensityAltitudeView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/11/23.
//

import SwiftUI

struct AirportTileDensityAltitudeView: View {
    @EnvironmentObject var cockpit: Cockpit
    let icao: String
    var boundReport: WeatherReport? {
        guard let report = cockpit.reports[icao] else {return nil}
        guard cockpit.reports[icao]!.hasData else {return nil}
        return report
    }
    var densityAltitudeDeltaString: String {
        guard let report = boundReport else {return "-----"}
        return "\(report.densityAltitudeDeltaToString(unit: cockpit.settings.altitudeUnit))"
    }
    var densityAltitudeDeltaColor: Color {
        guard let report = boundReport else {return .bicolor}
        return report.densityAltitudeDelta >= 3000 ? .bicolorCaution : .bicolor
    }
    var body: some View {
        Text("Δ DA: \(densityAltitudeDeltaString)").foregroundColor(densityAltitudeDeltaColor)
    }
}

struct AirportTileDensityAltitudeView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        AirportTileDensityAltitudeView(icao: "").environmentObject(cockpit)
    }
}
