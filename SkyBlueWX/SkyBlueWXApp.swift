//
//  SkyBlueWXApp.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

import SwiftUI

// Loads custom colors from assets folder and assigns them as properties to the Color struct.
extension Color {
    static let bicolor = Color("Bicolor")
    static let darkGreen = Color("DarkGreen")
    static let darkBlue = Color("DarkBlue")
    static let darkRed = Color("DarkRed")
    static let magenta = Color("Magenta")
}

// App starts here. I haven't messed around yet.
@main
struct SkyBlueWXApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
