//
//  MainView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

/**
 Main landing view.
 */

import SwiftUI

enum Views {
    case list, map, weather, flightPlan, setting
}

struct MainView: View {
    @EnvironmentObject var cockpit : Cockpit
    // Monitor status of the app (active/inactive/background)
    @Environment(\.scenePhase) var scenePhase
    @State private var selectedTab : Views = .weather
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack{ListView(selectedTab: $selectedTab)}.tabItem {
                Label("Airports", systemImage: "airplane.departure")
            }.tag(Views.list)
            NavigationStack{MapView(selectedTab: $selectedTab)}.tabItem {
                Label("Map", systemImage: "map.fill")
            }.tag(Views.map)
            WeatherView(selectedTab: $selectedTab).tabItem {
                Label("Weather", systemImage: "sun.max.fill")
            }.tag(Views.weather)
            FlightPlanView(selectedTab: $selectedTab).tabItem {
                Label("Flight Plan", systemImage: "airplane")
            }.tag(Views.flightPlan)
            SettingsView(selectedTab: $selectedTab).tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(Views.setting)
        }.onAppear()
            .onChange(of: scenePhase) {newPhase in
                switch newPhase {
                case .active, .inactive: cockpit.refreshSettings()
                default: ()
                }
                
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
