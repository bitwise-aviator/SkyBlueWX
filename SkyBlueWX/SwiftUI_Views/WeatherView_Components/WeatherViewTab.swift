//
//  WeatherViewTab.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/3/23.
//

import SwiftUI

struct WeatherViewTab: View {
    @EnvironmentObject var cockpit : Cockpit
    let isPlaceholder : Bool
    let airportCode : String
    var weight : Font.Weight {
        cockpit.activeReport == airportCode ? .bold : .regular
    }
    var foreColor : Color {
        cockpit.activeReport == airportCode ? .white : .black
    }
    var backColor : Color {
        cockpit.activeReport == airportCode ? .blue : Color(UIColor.lightGray)
    }
    
    
    
    
    var body: some View {
        if isPlaceholder {
            Text("(No airports)").foregroundColor(Color(UIColor.lightGray)).fontWeight(.bold).padding(.horizontal, 15).padding(.vertical, 10)
        } else {
            HStack {
                Text(airportCode).fontWeight(weight).foregroundColor(foreColor)
                Image(systemName: "xmark").foregroundColor(.white).background(.red).onTapGesture {
                    cockpit.removeReport(icao: airportCode)
                }
                
            }.padding(.horizontal, 15).padding(.vertical, 10).background(backColor).cornerRadius(20).onTapGesture {
                _ = cockpit.moveToReport(icao: airportCode)
            }
        }
    }
}

struct WeatherViewTab_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherViewTab(isPlaceholder: false, airportCode: "XXXX").environmentObject(cockpit)
    }
}
