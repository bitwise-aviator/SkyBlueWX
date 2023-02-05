//
//  ContentView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

import SwiftUI

// Enumeration for errors. To be expanded.
enum Errors : Error {
    case noReportFound, noAirportCodes
}

func getFirstRuntime() -> Date {
    // This determines when the first refresh query is going to run. Ideally, it should refresh in the background every 1-2 min or so.
    //let interval = 120 // Cycles are 2 min (120s) long
    let nowPlusBuffer = Date() + 1 // 1s buffer
    print(nowPlusBuffer)
    let firstRuntime = (1 + (Int(nowPlusBuffer.timeIntervalSinceReferenceDate) / 120)) * 120 // Calculates the seconds since reference date for the next time when the clock will be at XX:YY:00, where YY is a multiple of 2.
    // Notice that I am using integer division (i.e. drop the remainder) to have the result automatically round down, and then adding 1 (round up)
    print(Date(timeIntervalSinceReferenceDate: TimeInterval(firstRuntime)))
    return Date(timeIntervalSinceReferenceDate: TimeInterval(firstRuntime))
}

// Outline that contains the UI
struct WeatherView: View {
    // Monitor status of the app (active/inactive/background)
    @Environment(\.scenePhase) var scenePhase
    // @Binding variables are state variables for the parent view for R & W access.
    @EnvironmentObject var cockpit : Cockpit
    @Binding var selectedTab : Views
    // @State variables control the app's render. If one is modified, it causes the screen to refresh.
    @State var searchAirport = "" // Airport code that appears in the search box.
    @State var airportSelectorVisible = false;
    @State var hasError = false // Self-explanatory
    @State var errorStatement = "" // If an error is encountered, this is what will be shown to the user.
    @State var airportResultDict : AirportDict? = [:]
    let databaseConnection = DataBaseHandler()
    let refreshLock = DispatchSemaphore(value: 1) // Protects the report structure if it is updating. Queries will not fire if this lock is on.
    var weatherRefresher : Timer?
    
    func refresh() {
        printMet()
    }
    
    func simpleMetLookup() {
        // Shorthand get-met function, where user can press return with a valid airport code and get the weather report.
        guard let _ = airportResultDict else {return}
        var matchingAirport : Airport? = nil
        let searchTerm : String = searchAirport.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for item in airportResultDict!.values {
            if item.icao == searchTerm {
                matchingAirport = item
                break
            }
        }
        if let _ = matchingAirport {
            airportSelectorVisible = false
            pushToQueryList(matchingAirport!.icao)
            searchAirport = ""
            getMet(moveTarget: searchTerm)
        }
    }
    
    func getMet(moveTarget: String? = nil) {
        refreshLock.wait()
        // Gets the weather report
        Task { // Opens new thread.
            do {
                try await cockpit.getWeather() // Calls the getter/parser.
                if cockpit.reportKeys.count == 0 {
                    throw Errors.noAirportCodes
                }
                var airportViewHasChanged : Bool = false
                if let _ = moveTarget {
                    airportViewHasChanged = cockpit.moveToReport(icao: moveTarget!)
                }
                // This block keeps the viewframe on the same airport that the user was already on after fetching weather data, if that airport is requested. Behavior is useful if auto-updating later.
                if !airportViewHasChanged {
                    if let shownAirport = cockpit.activeReport {
                        if !cockpit.reportKeys.contains(shownAirport) {
                            cockpit.activeReport = cockpit.reportKeys[0]
                        }
                    } else {
                        cockpit.activeReport = cockpit.reportKeys[0]
                    }
                }
                printMet()
                refreshLock.signal()
            } catch Errors.noAirportCodes {
                // Changes the UI view to reflect that no weather report was found.
                cockpit.activeReport = nil
                printBadScreen()
                refreshLock.signal()
            }
        }
        
    }
    
    func printBadScreen() {
        hasError = true
        if let _ = cockpit.activeReport {
            errorStatement = "Airport \(cockpit.activeReport!) did not return a METAR..."
        } else {
            errorStatement = "No airports requested"
        }
        print(errorStatement)
    }
    
    func printMet() {
        // Handles UI changes in case of a valid weather report.
        guard let _ = cockpit.activeReport else {return}
        guard let shownReport = cockpit.reports[cockpit.activeReport!] else{return} // Shorthand for report visible in UI.
        if shownReport.hasData /*Checks if report is valid or not.*/ {
            // Updates text narrative, icon, and icon color accoridng to report data.
            hasError = false
        } else {
            printBadScreen()
        }
        //
        
        
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
            HStack (
                spacing: 10
            ){
                Spacer()
                TextField("Lookup", text: $searchAirport).autocorrectionDisabled(true).onChange(of: searchAirport, perform: {newValue in
                    airportSelectorVisible = true
                    airportResultDict = cockpit.getAirportRecords(newValue)}).onSubmit {
                        simpleMetLookup() // Textbox that triggers dropdown menu for airport selection. The textbox's input is no longer used for weather queries.
                    }
                Button(action: simpleMetLookup) {
                    Text("RUN").foregroundColor(.white).font(.system(size: 16)).fontWeight(.bold).padding(7.0) // Button does the same as pressing return on the text input box.
                }.background{ Color.green }
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
                    }.padding(.vertical, 10).background(Color.bicolorInv).frame(maxWidth: .infinity, maxHeight: 0.03 * maxDimension)
                    Spacer().frame(height: 20)
                    HStack {
                        if hasError {
                            VStack {
                                Text(errorStatement).foregroundColor(.red)
                            }.padding().border(.red, width: 5).background(Color.white)
                            
                        } else {
                            Text("")
                        }
                    }.padding(.vertical, 10).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.blue)
                    Spacer().frame(height: 0)
                    HStack {
                        VisibilityView()
                        Spacer().frame(maxWidth: 30)
                        WindView()
                    }.padding(.vertical, 20).frame(maxWidth: .infinity, maxHeight: maxDimension * 0.15).background(Color.green)
                }
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
                                            Image(systemName: (cockpit.queryCodes.contains(airportResultDict![key]!.icao) ? "minus.square" : "plus.square")).foregroundColor((cockpit.queryCodes.contains(airportResultDict![key]!.icao) ? Color.darkRed : Color.darkGreen)).frame(width: UIScreen.main.bounds.width * 0.1).onTapGesture {
                                                editQueryList(airportResultDict![key]!.icao)
                                            }
                                        }.frame(maxWidth: .infinity).background(Color.bicolorInv.opacity(0.85))
                                    }
                                }
                            }.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4)
                            Spacer()
                        }.frame(maxHeight: .infinity)
                    }
                }
            }
        }.onAppear{
            if cockpit.queryCodes.count != 0 {
                getMet()
            }
            // Fix units based on user settings, not allowed at initialization.
            refresh()
        }.onChange(of: scenePhase) {newPhase in
            if newPhase == .active || newPhase == .inactive {
                //Force refresh of view if app becomes active or is shown in the App Switcher again. Allows changes in the iOS settings to apply.
                refresh()
            }
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherView(selectedTab: .constant(.weather)).environmentObject(cockpit)
    }
}
