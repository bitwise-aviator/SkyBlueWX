//
//  AirportTileWindView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/5/23.
//

import SwiftUI

struct AirportTileWindView: View {
    @EnvironmentObject var cockpit: Cockpit
    let icao: String
    var boundReport: WeatherReport? {
        guard let report = cockpit.reports[icao] else {return nil}
        guard cockpit.reports[icao]!.hasData else {return nil}
        return report
    }
    var windIsCalm: Bool {
        boundReport!.wind.speed == 0
    }
    var windDirectionString: String {
        if boundReport!.wind.isVariable { return "VRB" }
        return String(format: "%03d", boundReport!.wind.direction!)
    }
    var windInfoString: String {
        guard let report = boundReport else {return "-----"}
        if windIsCalm { return "Calm" }
        var stringBuilder: String =
        "\(windDirectionString) @ \(report.windSpeedToString(unit: cockpit.settings.speedUnit))"
        if report.wind.hasGusts {
            stringBuilder +=
            " G \(report.windGustsToString(unit: cockpit.settings.speedUnit))\(cockpit.settings.speedUnitString)"
        } else {
            stringBuilder += "\(cockpit.settings.speedUnitString)"
        }
        return stringBuilder
    }
    @ViewBuilder
    var body: some View {
        HStack {
            Image(systemName: "wind")
            Text(windInfoString)
        }
    }
}

struct AirportTileWindView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        AirportTileWindView(icao: "TEST").environmentObject(cockpit)
    }
}
