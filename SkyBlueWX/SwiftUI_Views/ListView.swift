//
//  ListView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

typealias ListViewBoxDict = [String : ListViewBoxHolder]



struct ListViewBoxContents {
    let airportName : String
    var flightCondtions : FlightConditions
}

class ListViewBoxHolder {
    let airport : String
    var isWaitingForData : Bool
    var parameters : ListViewBoxContents?
    
    init(airport : String) {
        // Use this simple init if data is pending.
        self.airport = airport
        self.isWaitingForData = true
        self.parameters = nil
    }
    
    init(airport : String, parameters : ListViewBoxContents) {
        self.airport = airport
        self.isWaitingForData = false
        self.parameters = parameters
    }
    
    func renderView() -> any View {
        return Text(airport)
    }
    

}


struct ListView: View {
    @EnvironmentObject var cockpit : Cockpit
    @Binding var selectedTab : Views

    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array.init(repeating: GridItem(.flexible()), count: cockpit.deviceInfo.deviceType == .pad ? 4 : 2), spacing: 20) {
                ForEach(cockpit.reportKeys, id: \.self) { AirportTileView(selectedTab:  $selectedTab, icao: $0)
                }
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        ListView(selectedTab: .constant(.list)).environmentObject(cockpit)
    }
}
