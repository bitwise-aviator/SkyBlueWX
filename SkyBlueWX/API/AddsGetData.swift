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
    var data: [String: WeatherReport] = [:]
    func vacate() {
        // empty out data safely.
        data = [:]
    }
    func assign(key: String, value: WeatherReport?) {
        data[key] = value
    }
    func extract(key: String) -> WeatherReport? {
        return data[key]
    }
    func update(key: String, coordinates: CLLocation, reportTime: Date?, clouds: [CloudLayer], visibility: Double, temperature: Double, dewPoint: Double, wind: Wind, details: String, altimeter: Double, elevation: Double) {
        if let _ = data[key] {
            data[key]!.update(location: key, coordinates: coordinates, reportTime: reportTime, clouds: clouds, visibility: visibility, temperature: temperature, dewPoint: dewPoint, wind: wind, details: details, altimeter: altimeter, elevation: elevation)
        }
    }
}

// Function queries, gets, interprets, and returns WX reports.
func loadMe(icao query: Set<String>, cockpit: Cockpit) async -> [String: WeatherReport] {
    // Shorthand if we are returning data where all airports are bad (such as connection error)
    print(query)
    let wxReports = WXReports()
    let allBadData: [String: WeatherReport] = [:]
    if query.count == 0 { return allBadData }
    let formattedQuery = query.joined(separator: "+")
    // Query URL casted from a string.
    // URLs don't accept spaces, use + instead.
    let url = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=csv&stationString=\(formattedQuery)&hoursBeforeNow=24")!
    for code in query.sorted() {
        await wxReports.assign(key: code, value: WeatherReport(location: code, airport: cockpit.storedAirports[code])) // This is a basic initialization. The instance will have a bool property to track if it's good or not, it will start as bad. Calling the update method will make it good.
    }
    // Function that retrieves and parses data.
    func pullData() async {
        /// Convenience function prior to return if an error is encountered.
        func closeEmpty() async {
            await wxReports.vacate()
            print("No reports")
        }
        /// Perform the URL get request
        func getData(url: URL) async -> Data? {
            do {
                let (resultingData, _) = try await URLSession.shared.data(for: URLRequest(url: url))
                print("OK!")
                return resultingData
            } catch {
                print("Connection failed: error message below...")
                print("\(error)")
                return nil
            }
        }
        /// Takes the CSV lines and matches them to airports
        func matchReports() -> [String: String] {
            // Convert data to UTF-8 string.
            // Force unwrapping (!) is safe here because the function will have already returned if data was null.
            let res = String(data: data!, encoding: .utf8)!
            let resRows = res.components(separatedBy: "\n") // Split data into rows. 1 row = 1 report.
            // Initialize dictionary storing the weather row per airport.
            var weatherRows: [String: String] = [:]
            var matchedRows: Int = 0 // How many airports have been already matched to a row.
            for row in resRows { // There are header rows too. This iterates to filter out irrelevant rows.
                let rowIcao: String? = row.components(separatedBy: ",").count > 1 ?
                row.components(separatedBy: ",")[1]: nil // Extract the airport code.
                guard let rowIcao = rowIcao else {continue}
                // This should filter out the header rows, execution will restart on next row.
                if rowIcao == "station_id" {continue}
                if query.contains(rowIcao) && weatherRows[rowIcao] == nil {
                    // Observations are shown in the server by most recent to less.
                    // As we usually only want the latest one, we can stop searching after we find a match,
                    // hence the "break" statement.
                    weatherRows[rowIcao] = row // If a match is found, populate
                    matchedRows += 1
                    //
                    if matchedRows == query.count {break} // Exits if all matches have been found.
                }
            }
            return weatherRows
        }
        /// Extracts matched rows into WeatherReport structs
        func parseReport() async {
            for icao in query.sorted() {
                if !weatherRows.keys.contains(icao) {continue}
                let currentReport: String = weatherRows[icao]!
                // Pass the comma-separated report into an array.
                let csvItems = currentReport.components(separatedBy: ",")
                // This for loop is a debugging test and also provides indices for reference.
                for idx in 0..<csvItems.count {
                    print(idx, csvItems[idx])
                }
                // Start parsing the report
                let location: String = csvItems[1] // ICAO code
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let reportTime = dateFormatter.date(from: csvItems[2])
                let stationLatitude = Double(csvItems[3]) ?? 0.0
                let stationLongitude = Double(csvItems[4]) ?? 0.0
                let stationCoordinates = CLLocation(latitude: stationLatitude, longitude: stationLongitude)
                // Cloud layers
                var reportedClouds: [CloudLayer] = [] // Initialize an empty array to store cloud layers.
                // Each cloud layer uses two positions (first one has the cloud type & the second, the height).
                // We thus iterate with a step of 2.
                for idx in stride(from: 22, through: 28, by: 2) /* = [22, 24, 26, 28] */ {
                    // If this code is encountered, it means that clear skies are reported.
                    // We don't need to process anything and can get out.
                    if csvItems[idx] == "CLR" {break}
                    // First checking that both items of the data pair have non-empty values.
                    if csvItems[idx] != "" && csvItems[idx+1] != "" {
                        // It is safe to declare constants within for loops, as their scope does not carry over
                        // to future iterations.
                        let cloudCover: CloudCover?
                        switch csvItems[idx] { // Check the cloud cover codes and assign accordingly.
                        case "FEW": cloudCover = CloudCover.few
                        case "SCT": cloudCover = CloudCover.scattered
                        case "BKN": cloudCover = CloudCover.broken
                        case "OVC": cloudCover = CloudCover.overcast
                        // METARs use VV (vertical visibility) but server uses OVX when reporting this layer.
                        // This means that the sky is obscured and cloud boundaries cannot be identified,
                        // the measurement indicates how high up can be seen from the ground.
                        case "OVX": cloudCover = CloudCover.obscured
                        default: cloudCover = nil // If none apply, return a nil.
                            // This will trigger the guard and break out.
                        }
                        let cloudHeight: Int
                        if cloudCover == .obscured {
                            let fullMetar: String = csvItems[0]
                            let vvRegex = /.*VV(?<base>[0-9]{3})(?<rmk>\S*).*/
                            if let captures = try? vvRegex.wholeMatch(in: fullMetar) {
                                if let goodHeight = Int(captures.base) {
                                    cloudHeight = goodHeight * 100
                                } else {
                                    cloudHeight = 0
                                }
                            } else {
                                cloudHeight = 0
                            }
                        } else {
                            cloudHeight = Int(csvItems[idx+1])!
                        }
                        guard let cloudCover = cloudCover else {break}
                        // If cloud cover is matched, pass it along with the unwrapped height value casted as
                        // an integer, as per the CSV schema.
                        reportedClouds.append((cloudCover, cloudHeight, nil))
                    } else {break
                        // If a bad pair (i.e. either value missing) is encountered, stop.
                        // It could mean that no further clouds were observed.
                    }
                }
                /* The syntax a = x ?? y means that:
                 The system will check if x is nil or returns an error
                 (for example, trying to cast a letter as an integer).
                 If x does not return nil nor triggers errors, then use x as the value of a.
                 Else, use y - a default value - as the value of a.
                 */
                let altimeter = Double(csvItems[11]) ?? 29.92
                let visibility = Double(csvItems[10]) ?? 0.0
                // Temperature (C). Using double to increase precision when converting to/from F.
                let temp = Double(csvItems[5]) ?? 0.0
                let dewPt = Double(csvItems[6]) ?? 0.0 // Dewpoint
                let windDirection = Int(csvItems[7]) ?? 0 // Wind direction (degrees)
                let windSpeed = Int(csvItems[8]) ?? 0 // Wind speed (knots)
                let windGusts = Int(csvItems[9]) ?? nil // Wind gusts (knots, optional)
                // Create a Wind struct to store this.
                let wind = Wind(direction: windDirection, speed: windSpeed, gusts: windGusts)
                // This field will store data regarding non-numeric weather info (rain, snow, hail, fog, etc.)
                let weatherDetail = csvItems[21]
                let stationElevation = Double(csvItems[43]) ?? 0.0
                await wxReports.update(key: location, coordinates: stationCoordinates, reportTime: reportTime, clouds: reportedClouds, visibility: visibility, temperature: temp, dewPoint: dewPt, wind: wind, details: weatherDetail, altimeter: altimeter, elevation: stationElevation) // Pass the parsed/extracted data to the existing WeatherReport instance.
            }
        }
        let data = await getData(url: url)
        // Exits if no data was received
        guard data != nil else {
            await closeEmpty()
            return
        }
        let weatherRows = matchReports()
        await parseReport()
        return
    }
    // Call data get/parse function
    await pullData()
    return await wxReports.data
}
