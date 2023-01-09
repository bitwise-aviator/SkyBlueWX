//
//  FlightPlanView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

struct FlightPlanView: View {
    @Binding var cockpit : Cockpit
    @Binding var selectedTab : Views
    
    var body: some View {
        Text("The Flight Plan mode will soon be available here...")
    }
}

struct FlightPlanView_Previews: PreviewProvider {
    static var previews: some View {
        FlightPlanView(cockpit: .constant(Cockpit()), selectedTab: .constant(.flightPlan))
    }
}
