//
//  ContentView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

import SwiftUI

// Outline that contains the UI
struct WeatherView: View {
    // Monitor status of the app (active/inactive/background)
    @Environment(\.scenePhase) var scenePhase
    // @Binding variables are state variables for the parent view for R & W access.
    @EnvironmentObject var cockpit: Cockpit
    @Binding var selectedTab: Views
    // @State variables control the app's render. If one is modified, it causes the screen to refresh.
    @State var searchAirport = "" // Airport code that appears in the search box.
    @State var airportSelectorVisible = false
    @State var hasError = false // Self-explanatory
    @State var errorStatement = "" // If an error is encountered, this is what will be shown to the user.
    let databaseConnection = DataBaseHandler()
    // Protects the report structure if it is updating. Queries will not fire if this lock is on.
    let refreshLock = DispatchSemaphore(value: 1)
    var weatherRefresher: Timer?
    func refresh() {
    }
    func simpleMetLookup() {
        // Shorthand get-met function, where user can press return with a valid airport code and get the weather report.
        guard let results = cockpit.dbQueryResults else {return}
        var matchingAirport: Airport?
        let searchTerm: String = searchAirport.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for item in results.values where item.icao == searchTerm {
                matchingAirport = item
                break
        }
        if let match = matchingAirport {
            airportSelectorVisible = false
            pushToQueryList(match.icao)
            searchAirport = ""
            getMet(moveTarget: searchTerm)
        }
    }
    func getMet(moveTarget: String? = nil) {
        refreshLock.wait()
        // Gets the weather report
        Task { // Opens new thread.
            do {
                try await cockpit.getWeather(moveTo: moveTarget) // Calls the getter/parser.
                refreshLock.signal()
            } catch Errors.noAirportCodes {
                // Changes the UI view to reflect that no weather report was found.
                refreshLock.signal()
            }
        }
    }
    func pushToQueryList(_ icao: String) {
        cockpit.editQueryList(icao, retain: true)
    }
    func editQueryList(_ icao: String) {
        cockpit.editQueryList(icao)
    }
    // Gets min & max dimensions of the current screen.  Useful for relative sizing of graphics.
    var minDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    // Structure of the actual view.
    // Unlike other languages, each row (w/ a linebreak) counts as a separate component.
    @ViewBuilder
    var body: some View {
        VStack { // Items within a VStack are stacked vertically, HStack, horizontally.
            HStack {}
            HStack(
                spacing: 10
            ) {
                Spacer()
                TextField("Lookup", text: $searchAirport).autocorrectionDisabled(true).onChange(of: searchAirport,
                                                                                                perform: {newValue in
                    airportSelectorVisible = true
                    cockpit.getAirportRecords(newValue)
                }).onSubmit {
                        simpleMetLookup() // Textbox that triggers dropdown menu for airport selection.
                    // The textbox's input is no longer used for weather queries.
                    }
                Button(action: simpleMetLookup) {
                    Text("RUN").foregroundColor(.white).font(.system(size: 16)).fontWeight(.bold).padding(7.0)
                    // Button does the same as pressing return on the text input box.
                }.background { Color.green }
                Spacer()
            }
            WeatherViewTabScroller()
            Spacer().frame(height: 20)
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        WeatherOverviewSmallView()
                        Spacer()
                        VStack {
                            DensityAltSmallView()
                            TempAndDewpointSmallView()
                        }
                        Spacer()
                    }.padding(.vertical, 10).background(Color.bicolorInv)
                        .frame(maxWidth: .infinity, maxHeight: 0.03 * maxDimension)
                    Spacer().frame(height: 20)
                    HStack {
                        ZStack {
                            CloudStackView()
                            ErrorMessageView()
                        }
                    }.padding(.vertical, 10).frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.skyBackground)
                    Spacer().frame(height: 0)
                    HStack {
                        Spacer()
                        AltimeterView()
                        Spacer()
                        VisibilityView()
                        Spacer()
                        WindView()
                        Spacer()
                    }.padding(.vertical, 20).frame(maxWidth: .infinity, maxHeight: maxDimension * 0.15)
                        .background {Color.groundBackground}
                }
                if airportSelectorVisible {
                    DropdownList()
                }
            }
        }.onAppear {
            if cockpit.queryCodes.count != 0 {
                getMet(moveTarget: cockpit.activeReport)
            }
            // Fix units based on user settings, not allowed at initialization.
            refresh()
        }.onChange(of: scenePhase) {newPhase in
            if newPhase == .active || newPhase == .inactive {
                // Force refresh of view if app becomes active or is shown in the App Switcher again.
                // Allows changes in the iOS settings to apply.
                refresh()
            }
        }
    }
}

#if !TESTING
struct WeatherView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherView(selectedTab: .constant(.weather)).environmentObject(cockpit)
    }
}
#endif
