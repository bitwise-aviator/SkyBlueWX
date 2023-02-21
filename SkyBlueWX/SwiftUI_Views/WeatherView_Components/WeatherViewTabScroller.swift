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
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                HStack {
                    if cockpit.reportKeys.count > 0 {
                        ForEach(cockpit.reportKeys, id: \.self) {code in
                            WeatherViewTab(isPlaceholder: false, airportCode: code).id(code)
                        }
                    } else {
                        WeatherViewTab(isPlaceholder: true, airportCode: "")
                    }
                }
            }.onChange(of: cockpit.activeReport, perform: { newValue in
                value.scrollTo(newValue)
            })
        }
    }
}

#if !TESTING
struct WeatherViewTabScroller_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherViewTabScroller().environmentObject(cockpit)
    }
}
#endif
