//
//  MapView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

struct MapView: View {
    @EnvironmentObject var cockpit : Cockpit
    @Binding var selectedTab : Views
    
    var body: some View {
        Text("A map view will be landing shortly...")
    }
}

struct MapView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        MapView(selectedTab: .constant(.map)).environmentObject(cockpit)
    }
}
