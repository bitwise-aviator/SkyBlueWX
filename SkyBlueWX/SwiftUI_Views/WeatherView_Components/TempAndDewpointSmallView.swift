//
//  TempAndDewpointSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct TempAndDewpointSmallView: View {
    @EnvironmentObject var cockpit: Cockpit
    var body: some View {
        HStack {
            Spacer().frame(maxWidth: .infinity)
            TemperatureSmallView()
            DewpointSmallView()
        }.onTapGesture {
            cockpit.setTemperatureUnit()
        }
    }
}

#if !TESTING
struct TempAndDewpointSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        TempAndDewpointSmallView().environmentObject(cockpit)
    }
}
#endif
