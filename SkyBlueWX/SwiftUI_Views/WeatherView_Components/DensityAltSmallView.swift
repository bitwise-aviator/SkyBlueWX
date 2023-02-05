//
//  DensityAltSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI

struct DensityAltSmallView: View {
    @EnvironmentObject var cockpit : Cockpit
    var densityAltitudeString : String {
        get {
            cockpit.activeReportStruct?.densityAltitudeToString() ?? "-----"
        }
    }
    
    var body: some View {
        Text("Density altitude: \(densityAltitudeString)").foregroundColor(.bicolor).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct DensityAltSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        DensityAltSmallView().environmentObject(cockpit)
    }
}
