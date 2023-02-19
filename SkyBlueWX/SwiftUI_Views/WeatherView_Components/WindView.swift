//
//  WindReadout.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/2/23.
//

import SwiftUI

struct WindView: View {
    @EnvironmentObject var cockpit: Cockpit
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var body: some View {
        HStack(spacing: cockpit.deviceInfo.deviceType == .pad ? 30 : 20) {
            WindDirectionView()
            WindSpeedView()
            WindSockView()
        }
    }
}

#if !TESTING
struct WindView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WindView().environmentObject(cockpit)
    }
}
#endif
