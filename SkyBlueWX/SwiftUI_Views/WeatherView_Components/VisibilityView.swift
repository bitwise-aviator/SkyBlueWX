//
//  VisibilityView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct VisibilityView: View {
    @EnvironmentObject var cockpit: Cockpit
    var visibilityIcon: Image {
        guard let report = cockpit.activeReportStruct else { return Image(systemName: "eye.fill") }
        guard report.hasData else {return Image(systemName: "eye.fill") }
        return Image(systemName: report.visibility >= 3.0 ? "eye.fill": "eye.slash.fill")
    }
    var visibilityColor: Color {
        guard let report = cockpit.activeReportStruct else { return .white }
        guard report.hasData else {return .white }
        return report.visibility >= 3.0 ? .white : .yellow
    }
    var visibilityString: String {
        return cockpit.activeReportStruct?.visibilityToString(unit: cockpit.settings.visibilityUnit) ?? "----"
    }
    var visibilityObscuration: String? {
        guard let report = cockpit.activeReportStruct, report.hasData,
              !report.details.obscurations.isEmpty else { return nil }
        let obscurations = report.details.obscurations
        var obscurationString = "( "
        if obscurations.contains(.fog) {obscurationString += "FOG "}
        if obscurations.contains(.mist) {obscurationString += "MIST "}
        if obscurations.contains(.smoke) {obscurationString += "SMOKE "}
        if obscurations.contains(.ash) {obscurationString += "ASH "}
        if obscurations.contains(.dust) {obscurationString += "DUST "}
        if obscurations.contains(.sand) {obscurationString += "SAND "}
        if obscurations.contains(.haze) {obscurationString += "HAZE "}
        return obscurationString + ")"
    }
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)    
    @ViewBuilder
    var body: some View {
        VStack {
            visibilityIcon.resizable().frame(width: maxDimension * 0.03, height: maxDimension * 0.03)
                .foregroundColor(visibilityColor)
            Text(visibilityString).foregroundColor(visibilityColor).fontWeight(.bold)
            if visibilityObscuration != nil {
                Text(visibilityObscuration!).foregroundColor(visibilityColor).fontWeight(.bold)
            }
        }.onTapGesture {
            cockpit.setVisibilityUnit()
        }
    }
}

#if !TESTING
struct VisibilityView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        VisibilityView().environmentObject(cockpit)
    }
}
#endif
