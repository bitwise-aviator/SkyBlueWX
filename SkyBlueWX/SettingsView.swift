//
//  SettingsView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var cockpit : Cockpit
    @Binding var selectedTab : Views
    
    var body: some View {
        Text("App settings will soon be available here...")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(cockpit: .constant(Cockpit()), selectedTab: .constant(.setting))
    }
}
