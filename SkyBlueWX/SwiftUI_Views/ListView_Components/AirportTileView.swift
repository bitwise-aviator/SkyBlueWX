//
//  AirportTileView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/5/23.
//

import SwiftUI

struct AirportTileView: View {
    @EnvironmentObject var cockpit: Cockpit
    @Binding var selectedTab: Views
    let icao: String
    @Binding var now: Date
    var boundReport: WeatherReport? {
        guard let report = cockpit.reports[icao] else {return nil}
        guard cockpit.reports[icao]!.hasData else {return nil}
        return report
    }
    var frameColor: Color {
        boundReport?.flightConditionColor ?? .gray
    }
    var reportAge: (hours: Int, minutes: Int)? {
        return boundReport?.timeSinceReport
    }
    var reportAgeText: String {
        guard let age = reportAge else { return "--h--m"}
        return "\(String(age.hours))h\(String(format: "%02d", age.minutes))m"
    }
    var reportAgeColor: Color {
        guard let age = reportAge else { return .bicolor}
        return age.hours >= 1 ? Color.bicolorCaution: Color.bicolor
    }
    var separator: String {
        cockpit.deviceInfo.deviceType == .pad ? " ": "\n"
    }
    var body: some View {
        AnyView(
            VStack {
                HStack {
                    Spacer()
                    AirportTileFlightRuleView(icao: icao)
                    (Text(icao).fontWeight(.bold) +
                     Text(separator + reportAgeText).foregroundColor(reportAgeColor)).padding(20)
                    Spacer()
                }
                HStack {
                    Spacer()
                    AirportTileWindView(icao: icao)
                    Spacer()
                }
            }
        ).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(frameColor, lineWidth: 5)).onTapGesture {
            if cockpit.moveToReport(icao: icao) {
                selectedTab = .weather
            }
        }
    }
}

#if !TESTING
struct AirportTileView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        AirportTileView(selectedTab: .constant(.list), icao: "TEST", now: .constant(Date.now))
            .environmentObject(cockpit)
    }
}
#endif
