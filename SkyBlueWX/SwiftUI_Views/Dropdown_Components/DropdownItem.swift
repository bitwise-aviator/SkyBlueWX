//
//  DropdownItem.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/7/23.
//

import SwiftUI

struct DropdownItem: View {
    @EnvironmentObject var cockpit: Cockpit
    let id: Int
    var entry: Airport? {
        return cockpit.dbQueryResults?[id]
    }
    @ViewBuilder
    var body: some View {
        if let validEntry = entry {
            HStack {
                Text(validEntry.icao).fontWeight(.bold).frame(width: UIScreen.main.bounds.width * 0.2)
                VStack {
                    Text(validEntry.name).lineLimit(1).truncationMode(.tail)
                    Spacer().frame(height: 0)
                    Text(validEntry.city).lineLimit(1).truncationMode(.tail)
                }.frame(width: UIScreen.main.bounds.width * 0.7)
                Image(systemName: (cockpit.queryCodes.contains(validEntry.icao) ? "minus.square" : "plus.square"))
                    .foregroundColor((cockpit.queryCodes.contains(validEntry.icao) ? Color.darkRed : Color.darkGreen))
                    .frame(width: UIScreen.main.bounds.width * 0.1).onTapGesture {
                    cockpit.editQueryList(validEntry.icao)
                }
            }.frame(maxWidth: .infinity).background(Color.bicolorInv.opacity(0.85))
        } else {
            EmptyView()
        }
    }
}

struct DropdownItem_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        DropdownItem(id: -1).environmentObject(cockpit)
    }
}
