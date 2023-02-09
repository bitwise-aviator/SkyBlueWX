//
//  WeatherLabelSmallVIew.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI

struct WeatherLabelSmallVIew: View {
    @EnvironmentObject var cockpit : Cockpit
    
    var text : String {
        cockpit.activeReport ?? "----"
    }
    
    var subText : String {
        guard let active = cockpit.activeReport else {
            return ("---------")
        }
        return cockpit.storedAirports[active]?.name ?? "---------"
    }
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading) {
            Text(text).foregroundColor(.bicolor).font(.system(size: 16)).fontWeight(.bold)
            if cockpit.deviceInfo.deviceType == .pad {
                Text(subText).foregroundColor(.bicolor)
            }
        }
    }
}

struct WeatherLabelSmallVIew_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherLabelSmallVIew().environmentObject(cockpit)
    }
}
