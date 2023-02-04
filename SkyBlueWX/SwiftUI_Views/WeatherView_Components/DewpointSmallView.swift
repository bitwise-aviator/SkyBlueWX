//
//  DewpointSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct DewpointSmallView: View {
    @EnvironmentObject var cockpit : Cockpit
    
    var dewpointString : String {
        return cockpit.activeReportStruct?.dewpointToString(unit: cockpit.settings.temperatureUnit) ?? "----"
    }
    
    var humidColor : Color {
        guard let _ = cockpit.activeReportStruct else { return .white }
        return cockpit.activeReportStruct!.relativeHumidity >= 80 ? .yellow : .white
    }
    
    var body: some View {
        HStack {
            Image(systemName: "thermometer.and.liquid.waves").foregroundColor(humidColor)
            Text(dewpointString).foregroundColor(humidColor)
        }
    }
}

struct DewpointSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        DewpointSmallView().environmentObject(cockpit)
    }
}
