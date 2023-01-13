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
    @Binding var cockpit : Cockpit
    @Binding var selectedTab : Views
    @State var searchAirport : String = ""
    @State var airportResultDict : AirportDict? = [:]
    @State var airportSelectorVisible : Bool = false
    @State var airportCodes = Set<String>()
    @State var boxContents : ListViewBoxDict = [:]
    @State var result : Int = 0
    
    func editQuery(_ parameter: String?) {
        if let _ = parameter {
            cockpit.editQueryList(parameter!)
            updateAirportCodes()
        }
    }
    
    func updateAirportCodes() {
        airportCodes = cockpit.queryCodes
    }
    
    func postWeather() {
    }
    
    func nothing() {
        if true {return}
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack (
                spacing: 10
            ){
                Spacer()
                TextField("Lookup", text: $searchAirport).autocorrectionDisabled(true).onChange(of: searchAirport, perform: {newValue in
                    airportSelectorVisible = true
                    airportResultDict = cockpit.dbConnection.getAirports(searchTerm: newValue)}).onSubmit {
                        nothing() // Textbox that triggers dropdown menu for airport selection. The textbox's input is no longer used for weather queries.
                    }
                Button(action: nothing) {
                    Text("To weather!") // Button does the same as pressing return on the text input box.
                }
                Spacer()
            }
            Spacer()
            ZStack {
                if airportSelectorVisible {
                    if let _ = airportResultDict {
                        VStack {
                            ScrollView {
                                VStack {
                                    ForEach(Array(airportResultDict!.keys).sorted(by: <), id: \.self) { key in
                                        HStack {
                                            Text(airportResultDict![key]!.icao).fontWeight(.bold).frame(width: UIScreen.main.bounds.width * 0.2)
                                            VStack {
                                                Text(airportResultDict![key]!.name).lineLimit(1).truncationMode(.tail)
                                                Spacer().frame(height: 0)
                                                Text(airportResultDict![key]!.city).lineLimit(1).truncationMode(.tail)
                                            }.frame(width: UIScreen.main.bounds.width * 0.7)
                                            Image(systemName: (cockpit.queryCodes.contains(airportResultDict![key]!.icao) ? "minus.square" : "plus.square")).foregroundColor((cockpit.queryCodes.contains(airportResultDict![key]!.icao) ? Color.darkRed : Color.darkGreen)).frame(width: UIScreen.main.bounds.width * 0.05).onTapGesture {
                                                editQuery(airportResultDict?[key]?.icao)
                                            }
                                        }.frame(maxWidth: .infinity).background(Color.bicolorInv.opacity(0.85))
                                    }
                                }
                            }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4)
                            Spacer()
                        }.frame(maxHeight: .infinity)
                    }
                }
                VStack {
                    ForEach(airportCodes.sorted(by: <), id: \.self) {
                        airport in
                            HStack {
                                Text(airport)
                            }
                        Divider()
                    }
                }
            }.frame(maxHeight: .infinity)
        }.onAppear {
            //cockpit.activeView = .list
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(cockpit: .constant(Cockpit()), selectedTab: .constant(.list))
    }
}
