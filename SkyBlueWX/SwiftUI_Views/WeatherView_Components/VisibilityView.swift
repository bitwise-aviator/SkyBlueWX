//
//  VisibilityView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct VisibilityView: View {
    @EnvironmentObject var cockpit : Cockpit
    var visibilityIcon : Image {
        guard let _ = cockpit.activeReportStruct else { return Image(systemName: "eye.fill") }
        guard cockpit.activeReportStruct!.hasData else {return Image(systemName: "eye.fill") }
        return Image(systemName: cockpit.activeReportStruct!.visibility >= 3.0 ? "eye.fill": "eye.slash.fill")
    }
    
    var visibilityColor : Color {
        guard let _ = cockpit.activeReportStruct else { return .white }
        guard cockpit.activeReportStruct!.hasData else {return .white }
        return cockpit.activeReportStruct!.visibility >= 3.0 ? .white : .yellow
    }
    
    var visibilityString : String {
        return cockpit.activeReportStruct?.visibilityToString(unit: cockpit.settings.visibilityUnit) ?? "----"
    }
    
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    
    var body: some View {
        VStack {
            visibilityIcon.resizable().frame(width: maxDimension * 0.03, height: maxDimension * 0.03).foregroundColor(visibilityColor)
            Text(visibilityString).foregroundColor(visibilityColor).fontWeight(.bold)
        }.onTapGesture {
            cockpit.setVisibilityUnit()
        }
    }
}

struct VisibilityView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        VisibilityView().environmentObject(cockpit)
    }
}
