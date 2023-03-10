//
//  WeatherIconSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI

struct WeatherIconSmallView: View {
    @EnvironmentObject var cockpit: Cockpit
    var weatherIconPath: String {
        return cockpit.activeReportStruct?.wxIcon ?? "questionmark.square.dashed"
    }
    var weatherIconColor: Color {
        return cockpit.activeReportStruct?.wxColor ?? .bicolor
    }
    var body: some View {
        Image(systemName: weatherIconPath).foregroundColor(weatherIconColor)
    }
}

#if !TESTING
struct WeatherIconSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherIconSmallView().environmentObject(cockpit)
    }
}
#endif
