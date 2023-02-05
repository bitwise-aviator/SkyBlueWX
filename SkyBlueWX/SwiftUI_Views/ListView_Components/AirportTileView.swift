//
//  AirportTileView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/5/23.
//

import SwiftUI

struct AirportTileView: View {
    @EnvironmentObject var cockpit : Cockpit
    @Binding var selectedTab : Views
    let icao: String
    
    var body: some View {
        AnyView(
            VStack {
                HStack {
                    Spacer()
                    AirportTileFlightRuleView(icao: icao)
                    Text(icao).fontWeight(.bold).padding(20)
                    Spacer()
                }
                HStack {
                    AirportTileWindView(icao: icao)
                    Spacer()
                }
            }
        ).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 5)).onTapGesture {
            if cockpit.moveToReport(icao: icao) {
                selectedTab = .weather
            }
            
        }
    }
}

struct AirportTileView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        AirportTileView(selectedTab: .constant(.list),icao: "TEST").environmentObject(cockpit)
    }
}
