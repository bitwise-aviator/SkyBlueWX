//
//  AddsGetData.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 11/15/22.
//

/// API source: Aviation Weather server (NOAA)

import Foundation
import CoreLocation

actor WXReports {
    var data : [String : WeatherReport] = [:]
    
    func vacate() {
        // empty out data safelyl.
        data = [:]
    }
    
    func assign(key: String, value: WeatherReport?) {
        data[key] = value
    }
    
    func extract(key: String) -> WeatherReport? {
        return data[key]
    }
    
    func update(key: String, coordinates: CLLocation, clouds: [CloudLayer], visibility: Double, temperature: Double, dewPoint: Double, wind: Wind, details: String, altimeter: Double, elevation: Double) {
        if let _ = data[key] {
            data[key]!.update(location: key, coordinates: coordinates, clouds: clouds, visibility: visibility, temperature: temperature, dewPoint: dewPoint, wind: wind, details: details, altimeter: altimeter, elevation: elevation)
        }
    }
}

// Function queries, gets, interprets, and returns WX reports.
func loadMe(icao query: Set<String>, cockpit: Cockpit) async -> [String : WeatherReport] {
    // Shorthand if we are returning data where all airports are bad (such as connection error)
    print(query)
    let wxReports = WXReports()
    let allBadData : [String : WeatherReport] = [:]
    if query.count == 0 { return allBadData }
    let formattedQuery = query.joined(separator: "+")
    // Query URL casted from a string.
    let url = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=csv&stationString=\(formattedQuery)&hoursBeforeNow=2")!; // URLs don't accept spaces, use + instead.
    
    // Need to initialize the result here, as to keep the reference. Not sure if this is really necessary. Can experiment later.
    
    for code in query.sorted() {
        await wxReports.assign(key: code, value: WeatherReport(location: code)) // This is a basic initialization. The instance will have a bool property to track if it's good or not, it will start as bad. Calling the update method will make it good.
    }
    
    
    
    // Function that retrieves and parses data.
    func pullData() async {
        
        // Convenience function prior to return if an error is encountered.
        // @Sendable declares that the function is multi-threaded safe.
        @Sendable func closeEmpty() {
            print("No reports")
        }
        let data : Data?
        do {
            print("OK")
            let (resultingData, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            data = resultingData
        } catch {
            print("Connection failed: error message below...")
            print("\(error)")
            data = nil
        }
        if let _ = data {
            let res = String(data: data!, encoding: .utf8)! // Convert data to UTF-8 string. Force unwrapping (!) is safe here because the function will have already returned if data was null.
            let resRows = res.components(separatedBy: "\n") // Split data into rows. 1 row = 1 report.
            // Initialize dictionary storing the weather row per airport.
            var weatherRows : [String:String] = [:]
            
            var matchedRows : Int = 0 // How many airports have been already matched to a row.
            
            for row in resRows { // There are header rows too. This iterates to filter out irrelevant rows.
                let rowIcao : String? = row.components(separatedBy: ",").count > 1 ? row.components(separatedBy: ",")[1] : nil // Extract the airport code.
                guard let rowIcao = rowIcao else {continue}
                if rowIcao == "station_id" {continue} // This should filter out the header rows, execution will restart on next row.
                if query.contains(rowIcao) && weatherRows[rowIcao] == nil {
                    // Observations are shown in the server by most recent to less. As we usually only want the latest one, we can stop searching after we find a match, hence the "break" statement.
                    weatherRows[rowIcao] = row // If a match is found, populate
                    matchedRows += 1
                    //
                    if matchedRows == query.count {break} // Exits if all matches have been found.
                }
            }

            for icao in query.sorted() {
                if !weatherRows.keys.contains(icao) {continue}
                let currentReport : String = weatherRows[icao]!
                let csvItems = currentReport.components(separatedBy: ",") // Pass the comma-separated report into an array.
                
                // This for loop is a debugging test and also provides indices for reference.
                for k in 0..<csvItems.count {
                    print(k, csvItems[k])
                }
                
                // Start parsing the report
                let location : String = csvItems[1] // ICAO code
                let stationLatitude = Double(csvItems[3]) ?? 0.0
                let stationLongitude = Double(csvItems[4]) ?? 0.0
                let stationCoordinates = CLLocation(latitude: stationLatitude, longitude: stationLongitude)
                // TODO:  let relativePosition = cockpit.locationTracker.location
                // Cloud layers
                var reportedClouds : [CloudLayer] = [] // Initialize an empty array to store cloud layers.
                // Each cloud layer uses two positions (first one has the cloud type & the second, the height).
                // We thus iterate with a step of 2.
                for idx in stride(from: 22, through: 28, by: 2) /* = [22, 24, 26, 28] */ {
                    if csvItems[idx] == "CLR" {break} // If this code is encountered, it means that clear skies are reported. We don't need to process anything and can get out.
                    if csvItems[idx] != "" && csvItems[idx+1] != "" { // First checking that both items of the data pair have non-empty values.
                        let cloudCover : CloudCover? // It is safe to declare constants within for loops, as their scope does not carry over to future iterations.
                        switch(csvItems[idx]) { // Check the cloud cover codes and assign accordingly.
                        case "FEW": cloudCover = CloudCover.few
                        case "SCT": cloudCover = CloudCover.scattered
                        case "BKN": cloudCover = CloudCover.broken
                        case "OVC": cloudCover = CloudCover.overcast
                        case "OVX": cloudCover = CloudCover.obscured // METARs use VV (vertical visibility) but server uses OVX when reporting this layer. This means that the sky is obscured and cloud boundaries cannot be identified, the measurement indicates how high up can be seen from the ground.
                        default: cloudCover = nil; // If none apply, return a nil. This will trigger the guard and break out.
                        }
                        guard let cloudCover = cloudCover else {break}
                        reportedClouds.append((cloudCover, Int(csvItems[idx+1])!, nil)) // If cloud cover is matched, pass it along with the unwrapped height value casted as an integer, as per the CSV schema.
                    } else {break} // If a bad pair (i.e. either value missing) is encountered, stop. It could mean that no further clouds were observed.
                }
                /* The syntax a = x ?? y means that:
                 The system will check if x is nil or returns an error (for example, trying to cast a letter as an integer).
                 If x does not return nil nor triggers errors, then use x as the value of a.
                 Else, use y - a default value - as the value of a.
                 */
                let altimeter = Double(csvItems[11]) ?? 29.92
                let visibility = Double(csvItems[10]) ?? 0.0
                let temp = Double(csvItems[5]) ?? 0.0 // Temperature (C). Using double to increase precision when converting to/from F.
                let dewPt = Double(csvItems[6]) ?? 0.0 // Dewpoint
                let windDirection = Int(csvItems[7]) ?? 0 // Wind direction (degrees)
                let windSpeed = Int(csvItems[8]) ?? 0 // Wind speed (knots)
                let windGusts = Int(csvItems[9]) ?? nil // Wind gusts (knots, optional)
                let wind = Wind(direction: windDirection, speed: windSpeed, gusts: windGusts) // Create a Wind struct to store this.
                let weatherDetail = csvItems[21] // This field will store data regarding non-numeric weather info (rain, snow, hail, fog, etc.)
                let stationElevation = Double(csvItems[43]) ?? 0.0
                await wxReports.update(key: location, coordinates: stationCoordinates, clouds: reportedClouds, visibility: visibility, temperature: temp, dewPoint: dewPt, wind: wind, details: weatherDetail, altimeter: altimeter, elevation: stationElevation) // Pass the parsed/extracted data to the existing WeatherReport instance.
            }
        } else {
            await wxReports.vacate()
            closeEmpty()
            return
        }
    }
    
    // Call data get/parse function
    await pullData()
    return await wxReports.data
}

