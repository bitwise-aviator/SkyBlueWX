//
//  WeatherViewTabScroller.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct WeatherViewTabScroller: View {
    @EnvironmentObject var cockpit: Cockpit
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                if cockpit.reportKeys.count > 0 {
                    ForEach(cockpit.reportKeys, id: \.self) {code in
                        WeatherViewTab(isPlaceholder: false, airportCode: code)
                    }
                } else {
                    WeatherViewTab(isPlaceholder: true, airportCode: "")
                }
            }
        }
    }
}

struct WeatherViewTabScroller_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherViewTabScroller().environmentObject(cockpit)
    }
}
