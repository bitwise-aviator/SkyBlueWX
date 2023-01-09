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
    @State private var cockpit : Cockpit
    @State private var selectedTab : Views = .weather
    init() {
        // Initialize the controller for the app.
        self.cockpit = Cockpit()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack{ListView(cockpit: $cockpit, selectedTab: $selectedTab)}.tabItem {
                Label("Airports", systemImage: "airplane.departure")
            }.tag(Views.list)
            NavigationStack{MapView(cockpit: $cockpit, selectedTab: $selectedTab)}.tabItem {
                Label("Map", systemImage: "map.fill")
            }.tag(Views.map)
            WeatherView(cockpit: $cockpit, selectedTab: $selectedTab).tabItem {
                Label("Weather", systemImage: "sun.max.fill")
            }.tag(Views.weather)
            FlightPlanView(cockpit: $cockpit, selectedTab: $selectedTab).tabItem {
                Label("Flight Plan", systemImage: "airplane")
            }.tag(Views.flightPlan)
            SettingsView(cockpit: $cockpit, selectedTab: $selectedTab).tabItem {
                Label("Settings", systemImage: "gear")
            }.tag(Views.setting)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
