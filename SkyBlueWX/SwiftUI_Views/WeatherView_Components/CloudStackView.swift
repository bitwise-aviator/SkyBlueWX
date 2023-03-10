//
//  CloudStackView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/5/23.
//

import SwiftUI

struct CloudStackView: View {
    @EnvironmentObject var cockpit: Cockpit
    var cloudStack: AnyView? {
        guard let report = cockpit.activeReportStruct else {
            return nil
        }
        let count = report.clouds.count
        if count > 0 {
            return AnyView(VStack {
                ForEach((0..<count).reversed(), id: \.self) {
                    CloudLayerView(layerIndex: $0)
                }
            })
        } else {
            return nil
        }
    }
    var body: some View {
        cloudStack ?? AnyView(EmptyView())
    }
}

#if !TESTING
struct CloudStackView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        CloudStackView().environmentObject(cockpit)
    }
}
#endif
