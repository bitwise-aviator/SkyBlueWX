//
//  WindReadout.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/2/23.
//

import SwiftUI

struct WindView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct WindView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WindView().environmentObject(cockpit)
    }
}
