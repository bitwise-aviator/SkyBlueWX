//
//  SettingsView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cockpit: Cockpit
    @Binding var selectedTab: Views
    var body: some View {
        Text("App settings will soon be available here...")
    }
}

#if !TESTING
struct SettingsView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        SettingsView(selectedTab: .constant(.setting)).environmentObject(cockpit)
    }
}
#endif
