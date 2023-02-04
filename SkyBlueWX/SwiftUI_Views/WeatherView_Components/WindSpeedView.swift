//
//  WindSpeedView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/2/23.
//

import SwiftUI

struct WindSpeedView: View {
    @EnvironmentObject var cockpit : Cockpit
    var windSpeedString : String {
        guard let _ = cockpit.activeReportStruct else {return "--"}
        return cockpit.activeReportStruct!.windSpeedToString(unit: cockpit.settings.speedUnit)
    }
    var windGustString : String {
        guard let _ = cockpit.activeReportStruct?.wind.gusts else {return "--"}
        return cockpit.activeReportStruct!.windGustsToString(unit: cockpit.settings.speedUnit)
    }
    
    
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    
    var body: some View {
        VStack {
            Text(windSpeedString).fontWeight(.bold).font(.system(size: 32)).foregroundColor(.white)
            Text(cockpit.settings.speedUnitString).foregroundColor(.white)
            if windGustString != "--" {
                HStack {
                    if windGustString != "--" {
                        Image(systemName: "wind").foregroundColor(.yellow)
                        Text(windGustString).foregroundColor(.yellow).fontWeight(.bold)} else {
                            Text("")
                        }
                }.frame(height: 25)
            }
        }.onTapGesture {
            cockpit.setSpeedUnit()
        }
    }
}

struct WindSpeedView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WindSpeedView().environmentObject(cockpit)
    }
}
