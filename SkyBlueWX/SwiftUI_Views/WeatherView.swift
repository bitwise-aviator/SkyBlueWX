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


func getGreeting() -> String {
    let thisHour = Calendar.current.component(.hour, from: Date())
    switch (thisHour) {
    case 4..<12: return "Good morning!"
    case 12..<18: return "Good afternoon!"
    default: return "Good evening!"
    }
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

struct WeatherStateTracker {
    struct Temperature {
        var unit = TemperatureUnit.C
        var temp = "---"
        var dewPt = "---"
        var humid = 0.0
        var humidColor = Color.white
    }
    
    var temperature = Temperature()
}

// Outline that contains the UI
struct WeatherView: View {
    // Monitor status of the app (active/inactive/background)
    @Environment(\.scenePhase) var scenePhase
    // @Binding variables are state variables for the parent view for R & W access.
    @EnvironmentObject var cockpit : Cockpit
    @Binding var selectedTab : Views
    // @State variables control the app's render. If one is modified, it causes the screen to refresh.
    @State var wxIndex = 0 // Which report are we looking at?
    @State var wxText = "What's the weather like?" // Weather report text, if a report exists.
    @State var searchAirport = "" // Airport code that appears in the search box.
    @State var airportSelectorVisible = false;
    @State var queryCodes : Set<String> = [] // Codes sent to server as part of query. Use set to avoid repeated codes.
    @State var tracker = WeatherStateTracker() // Condense all state variables into a single struct.
    @State var hasError = false // Self-explanatory
    @State var errorStatement = "" // If an error is encountered, this is what will be shown to the user.
    @State var wxIcon = "questionmark.square.dashed" // This is the path for the weather icon that will be shown to the user.
    @State var wxColor = Color.white // Color of the weather icon.
    var speedUnitText : String {
        get {
            switch cockpit.settings.speedUnit {
            case .knot: return "kt"
            case .mph: return "mph"
            case .kmh: return "km/h"
            }
        }
    }
    @State var airportView : String? = nil
    @State var windSpeedString : String = "--"
    @State var windGustString : String = "--"
    @State var windsockIcon : String = "WindSock00kt"
    @State var windDirString : String = "---° --"
    @State var windDirRotate : Int = 0
    @State var visibilityString : String = "----"
    @State var visibilityIcon : String = "eye.fill"
    @State var visibilityColor = Color.white
    @State var densityAltitudeString = "-----"
    @State var flightRulesColor = Color.darkGreen
    @State var airportResultDict : AirportDict? = [:]
    let databaseConnection = DataBaseHandler()
    var greetingText : String = getGreeting() // Placeholder.
    let refreshLock = DispatchSemaphore(value: 1) // Protects the report structure if it is updating. Queries will not fire if this lock is on.
    var weatherRefresher : Timer?
    
    func moveForward() {
        guard let _ = airportView else {return}
        var reportKeys = Array(cockpit.reports.keys)
        reportKeys.sort()
        guard let currentIndex = reportKeys.firstIndex(of: airportView!) else {return}
        let index : Int = reportKeys.distance(from: reportKeys.startIndex, to: currentIndex)
        if  index < reportKeys.count - 1 {
            airportView = reportKeys[index + 1]
            printMet()
        }
        
    }
    
    func moveBack() {
        guard let _ = airportView else {return}
        var reportKeys = Array(cockpit.reports.keys)
        reportKeys.sort()
        guard let currentIndex = reportKeys.firstIndex(of: airportView!) else {return}
        let index : Int = reportKeys.distance(from: reportKeys.startIndex, to: currentIndex)
        if  index > 0 {
            airportView = reportKeys[index - 1]
            printMet()
        }
    }
    
    func moveTo(icao: String) -> Bool {
        // return is whether move was successful.
        if Array(cockpit.reports.keys).contains(icao) {
            airportView = icao
            return true
        } else {
            return false
        }
    }

    
    func refresh() {
        printMet()
    }
    
    func changeTempUnit() {
        cockpit.setTemperatureUnit()
        printMet() // Todo: split up printMet() so only temp. is refreshed. Ditto for other units.
    }
    
    func changeSpeedUnit() {
        cockpit.setSpeedUnit()
        printMet() // Todo: split up printMet() so only spd. is refreshed. Ditto for other units.
    }
    
    func changeVisUnit() {
        cockpit.setVisibilityUnit()
        printMet() // Todo: split up printMet() so only temp. is refreshed. Ditto for other units.
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
                cockpit.reports = await loadMe(icao: queryCodes, cockpit: cockpit) // Calls the getter/parser.
                var reportKeys = Array(cockpit.reports.keys)
                reportKeys.sort()
                if reportKeys.count == 0 {
                    throw Errors.noAirportCodes
                }
                var airportViewHasChanged : Bool = false
                if let _ = moveTarget {
                    airportViewHasChanged = moveTo(icao: moveTarget!)
                }
                // This block keeps the viewframe on the same airport that the user was already on after fetching weather data, if that airport is requested. Behavior is useful if auto-updating later.
                if !airportViewHasChanged {
                    if let shownAirport = airportView {
                        if !reportKeys.contains(shownAirport) {
                            airportView = reportKeys[0]
                        }
                    } else {
                        airportView = reportKeys[0]
                    }
                }
                printMet()
                refreshLock.signal()
            } catch Errors.noAirportCodes {
                // Changes the UI view to reflect that no weather report was found.
                airportView = nil
                printBadScreen()
                refreshLock.signal()
            }
        }
        
    }
    
    func printBadScreen() {
        hasError = true
        if let _ = airportView {
            errorStatement = "Airport \(airportView!) did not return a METAR..."
        } else {
            errorStatement = "No airports requested"
        }
        wxIcon = "questionmark.square.dashed"
        wxColor = Color.white
        windSpeedString = "--"
        windGustString = "--"
        windsockIcon = "WindSock00kt"
        windDirString = "---° --"
        windDirRotate = 0
        visibilityString = "----"
        visibilityIcon = "eye.fill"
        visibilityColor = .white
        tracker.temperature.temp = "---"
        tracker.temperature.dewPt = "---"
        densityAltitudeString = "-----"
        tracker.temperature.humid = 0.0
        tracker.temperature.humidColor = .white
        flightRulesColor = Color.darkGreen
        print(errorStatement)
    }
    
    func printMet() {
        // Handles UI changes in case of a valid weather report.
        guard let airportView = airportView else {return}
        guard let shownReport = cockpit.reports[airportView] else{return} // Shorthand for report visible in UI.
        if shownReport.hasData /*Checks if report is valid or not.*/ {
            // Updates text narrative, icon, and icon color accoridng to report data.
            hasError = false
            wxText = shownReport.reportClouds()
            wxIcon = shownReport.wxIcon
            wxColor = shownReport.wxColor
            windSpeedString = shownReport.windSpeedToString(unit: cockpit.settings.speedUnit)
            windGustString = shownReport.windGustsToString(unit: cockpit.settings.speedUnit)
            switch (shownReport.wind.speed) {
            case 15...: windsockIcon = "WindSock15kt"
            case 12..<15: windsockIcon = "WindSock12kt"
            case 9..<12: windsockIcon = "WindSock09kt"
            case 6..<9: windsockIcon = "WindSock06kt"
            case 3..<6: windsockIcon = "WindSock03kt"
            default: windsockIcon = "WindSock00kt"
            }
            windDirString = shownReport.windDirToString
            windDirRotate = shownReport.wind.direction ?? 0
            visibilityString = shownReport.visibilityToString(unit: cockpit.settings.visibilityUnit)
            visibilityIcon = shownReport.visibility >= 3.0 ? "eye.fill" : "eye.slash.fill"
            visibilityColor = shownReport.visibility >= 3.0 ? .white : .yellow
            tracker.temperature.temp = shownReport.temperatureToString(unit: cockpit.settings.temperatureUnit)
            tracker.temperature.dewPt = shownReport.dewpointToString(unit: cockpit.settings.temperatureUnit)
            densityAltitudeString = shownReport.densityAltitudeToString()
            tracker.temperature.humid = shownReport.relativeHumidity
            tracker.temperature.humidColor = tracker.temperature.humid >= 80 ? .yellow : .white
            flightRulesColor = shownReport.flightConditionColor
        } else {
            printBadScreen()
        }
        //
        
        
    }
    
    func pushToQueryList(_ icao: String) {
        cockpit.editQueryList(icao, retain: true)
        queryCodes = cockpit.queryCodes
    }
    
    func editQueryList(_ icao: String) {
        cockpit.editQueryList(icao)
        queryCodes = cockpit.queryCodes
    }
    
    
    // Gets min & max dimensions of the current screen.  Useful for relative sizing of graphics.
    var minDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    
    // Structure of the actual view.
    // Unlike other languages, each row (w/ a linebreak) counts as a separate component.
    @ViewBuilder
    var body: some View {
        VStack { // Items within a VStack are stacked vertically, HStack, horizontally.
            Text(greetingText)
                .foregroundColor(Color.blue)
                .padding()
            HStack (
                spacing: 10
            ){
                Spacer()
                TextField("Lookup", text: $searchAirport).autocorrectionDisabled(true).onChange(of: searchAirport, perform: {newValue in
                    airportSelectorVisible = true
                    airportResultDict = databaseConnection.getAirports(searchTerm: newValue)}).onSubmit {
                        simpleMetLookup() // Textbox that triggers dropdown menu for airport selection. The textbox's input is no longer used for weather queries.
                    }
                Button(action: simpleMetLookup) {
                    Text("Tell me!") // Button does the same as pressing return on the text input box.
                }
                Spacer()
            }
            HStack {
                Button(action: moveBack) {
                    Text("←")
                }
                Button(action: moveForward) {
                    Text("→")
                }
            }
            Spacer().frame(height: 20)
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: wxIcon).foregroundColor(wxColor)
                        Image(systemName: "circle.fill").foregroundColor(flightRulesColor)
                        Text(airportView ?? "----").foregroundColor(.white).font(.system(size: 16)).fontWeight(.bold)
                        Spacer()
                        VStack {
                            Text("Density altitude: \(densityAltitudeString)").foregroundColor(.white).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .trailing)
                            HStack {
                                Spacer().frame(maxWidth: .infinity)
                                Image(systemName: "thermometer.medium").foregroundColor(.white)
                                Text(tracker.temperature.temp).foregroundColor(.white)
                                Image(systemName: "thermometer.and.liquid.waves").foregroundColor(tracker.temperature.humidColor)
                                Text(tracker.temperature.dewPt).foregroundColor(tracker.temperature.humidColor)
                            }.onTapGesture {
                                changeTempUnit()
                            }
                        }
                        Spacer()
                    }.padding(.vertical, 10).background(Color.black).frame(maxWidth: .infinity, maxHeight: 0.03 * maxDimension)
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
                        VStack {
                            Image(systemName: visibilityIcon).resizable().frame(width: maxDimension * 0.03, height: maxDimension * 0.03).foregroundColor(visibilityColor)
                            Text(visibilityString).foregroundColor(visibilityColor).fontWeight(.bold)
                        }.onTapGesture {
                            changeVisUnit()
                        }
                        Spacer().frame(maxWidth: 30)
                        VStack {
                            Image(systemName: "location.north.fill").resizable().frame(width: maxDimension * 0.03, height: maxDimension * 0.03).rotationEffect(Angle(degrees: Double(windDirRotate + 180))).foregroundColor(.white)
                            Text(windDirString).foregroundColor(.white).fontWeight(.bold)
                        }
                        Spacer().frame(maxWidth: 30)
                        VStack {
                            Text(windSpeedString).fontWeight(.bold).font(.system(size: 32)).foregroundColor(.white)
                            Text(cockpit.settings.speedUnitString).foregroundColor(.white)
                            if windGustString != "--" {
                                HStack {
                                    if windGustString != "--" {
                                        Image(systemName: "wind").foregroundColor(.yellow)
                                        Text(windGustString).foregroundColor(.yellow).fontWeight(.bold)} else {
                                            Text("")
                                        }
                                }.frame(height: 25)
                            }
                            
                        }.onTapGesture {
                            changeSpeedUnit()
                        }
                        Image(windsockIcon).resizable().frame(
                            width: maxDimension * 0.1, height: maxDimension * 0.1)
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
                                            Image(systemName: (queryCodes.contains(airportResultDict![key]!.icao) ? "minus.square" : "plus.square")).foregroundColor((queryCodes.contains(airportResultDict![key]!.icao) ? Color.darkRed : Color.darkGreen)).frame(width: UIScreen.main.bounds.width * 0.1).onTapGesture {
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
