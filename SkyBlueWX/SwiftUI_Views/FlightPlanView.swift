//
//  FlightPlanView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

struct FlightPlanView: View {
    @EnvironmentObject var cockpit: Cockpit
    @Binding var selectedTab: Views
    var body: some View {
        Text("The Flight Plan mode will soon be available here...")
    }
}

#if !TESTING
struct FlightPlanView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        FlightPlanView(selectedTab: .constant(.flightPlan)).environmentObject(cockpit)
    }
}
#endif
