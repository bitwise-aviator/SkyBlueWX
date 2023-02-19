//
//  DropdownList.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/8/23.
//

import SwiftUI

struct DropdownList: View {
    @EnvironmentObject var cockpit: Cockpit
    @ViewBuilder
    var body: some View {
        if cockpit.dbQueryResults != nil {
            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(cockpit.dbQueryResults!.keys).sorted(by: <), id: \.self) { key in
                            DropdownItem(id: key)
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4)
                Spacer()
            }.frame(maxHeight: .infinity)
        } else {
            EmptyView()
        }
    }
}

#if !TESTING
struct DropdownList_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        DropdownList().environmentObject(cockpit)
    }
}
#endif
