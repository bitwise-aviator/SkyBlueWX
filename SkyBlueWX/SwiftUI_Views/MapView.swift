//
//  MapView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

struct MapView: View {
    @Binding var cockpit : Cockpit
    @Binding var selectedTab : Views
    
    var body: some View {
        Text("A map view will be landing shortly...")
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(cockpit: .constant(Cockpit()), selectedTab: .constant(.map))
    }
}
