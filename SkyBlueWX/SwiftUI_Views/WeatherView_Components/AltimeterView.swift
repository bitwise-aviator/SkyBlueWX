//
//  AltimeterView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/8/23.
//

import SwiftUI

struct AltimeterView: View {
    @EnvironmentObject var cockpit: Cockpit
    var altimeterIcon: Image {
        Image(systemName: "barometer")
    }
    var altimeterString: String {
        return cockpit.activeReportStruct?.altimeterToString(unit: cockpit.settings.pressureUnit) ?? "----"
    }
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var body: some View {
        VStack {
            altimeterIcon.resizable().frame(width: maxDimension * 0.03, height: maxDimension * 0.03)
                .foregroundColor(.white)
            Text(altimeterString).foregroundColor(.white).fontWeight(.bold)
        }.onTapGesture {
            cockpit.setPressureUnit()
        }
    }
}

#if !TESTING
struct AltimeterView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        AltimeterView().environmentObject(cockpit)
    }
}
#endif
