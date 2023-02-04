//
//  TemperatureSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct TemperatureSmallView: View {
    @EnvironmentObject var cockpit : Cockpit
    
    var temperatureString : String {
        return cockpit.activeReportStruct?.temperatureToString(unit: cockpit.settings.temperatureUnit) ?? "----"
    }
    
    var body: some View {
        HStack {
            Image(systemName: "thermometer.medium").foregroundColor(.white)
            Text(temperatureString).foregroundColor(.white)
        }
    }
}

struct TemperatureSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        TemperatureSmallView().environmentObject(cockpit)
    }
}
