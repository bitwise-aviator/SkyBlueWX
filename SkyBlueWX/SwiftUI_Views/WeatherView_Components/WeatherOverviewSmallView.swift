//
//  WeatherOverviewSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI

struct WeatherOverviewSmallView: View {
    @EnvironmentObject var cockpit: Cockpit
    var body: some View {
        HStack {
            WeatherIconSmallView()
            FlightRulesIconSmallView()
            WeatherLabelSmallView()
        }
    }
}

struct WeatherOverviewSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherOverviewSmallView().environmentObject(cockpit)
    }
}
