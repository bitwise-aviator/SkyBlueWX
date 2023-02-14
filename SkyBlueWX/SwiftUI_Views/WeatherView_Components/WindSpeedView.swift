//
//  WindSpeedView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/2/23.
//

import SwiftUI

struct WindSpeedView: View {
    @EnvironmentObject var cockpit: Cockpit
    var windSpeedString: String {
        guard let report = cockpit.activeReportStruct else {return "--"}
        return report.windSpeedToString(unit: cockpit.settings.speedUnit)
    }
    var windGustString: String {
        guard cockpit.activeReportStruct?.wind.gusts != nil else {return "--"}
        return cockpit.activeReportStruct!.windGustsToString(unit: cockpit.settings.speedUnit)
    }
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var body: some View {
        VStack {
            Text(windSpeedString).fontWeight(.bold).font(.system(size: 32)).fixedSize().foregroundColor(.white)
            Text(cockpit.settings.speedUnitString).fixedSize().foregroundColor(.white)
            if windGustString != "--" {
                HStack {
                    if windGustString != "--" {
                        Image(systemName: "wind").foregroundColor(.yellow)
                        Text(windGustString).fixedSize().foregroundColor(.yellow).fontWeight(.bold)} else {
                            Text("")
                        }
                }.frame(height: 25)
            }
        }.onTapGesture {
            cockpit.setSpeedUnit()
        }
    }
}

#if !TESTING
struct WindSpeedView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WindSpeedView().environmentObject(cockpit)
    }
}
#endif
