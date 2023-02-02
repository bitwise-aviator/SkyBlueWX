//
//  SkyBlueWXApp.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

import SwiftUI

// App starts here. I haven't messed around yet.
@main
struct SkyBlueWXApp: App {
    @StateObject var cockpit = Cockpit() // Initialize the cockpit module.
    var body: some Scene {
        WindowGroup {
            /*Set cockpit as an environmental object to pass it to all descendants of the main view.*/
            MainView().environmentObject(cockpit)
        }
    }
}
