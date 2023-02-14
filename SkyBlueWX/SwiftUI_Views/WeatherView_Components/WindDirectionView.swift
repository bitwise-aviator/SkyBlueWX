//
//  WindDirectionView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/2/23.
//

import SwiftUI

struct WindDirectionView: View {
    @EnvironmentObject var cockpit: Cockpit
    var windDirString: String {
        return cockpit.activeReportStruct?.windDirToString ?? "---° --"
    }
    var windDirRotate: Int {
        return cockpit.activeReportStruct?.wind.direction ?? 0
    }
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var body: some View {
        VStack {
            Image(systemName: "location.north.fill").resizable()
                .frame(width: maxDimension * 0.03, height: maxDimension * 0.03)
                .rotationEffect(Angle(degrees: Double(windDirRotate + 180))).foregroundColor(.white)
            Text(windDirString).fixedSize().foregroundColor(.white).fontWeight(.bold)
        }
    }
}

#if !TESTING
struct WindDirectionView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WindDirectionView().environmentObject(cockpit)
    }
}
#endif
