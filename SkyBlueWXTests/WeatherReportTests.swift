//
//  WeatherReportTests.swift
//  SkyBlueWXTests
//
//  Created by Daniel Sanchez on 2/13/23.
//

import XCTest
@testable import SkyBlueWX

final class WeatherReportTests: XCTestCase {
    var weatherReportOne: WeatherReport?
    //
    override func setUpWithError() throws {
        weatherReportOne = WeatherReport(location: "ZZZZ")
    }
    //
    override func tearDownWithError() throws {
        weatherReportOne = nil
    }
    //
    func testPrecipitationParsing() throws {
        // Throwing other codes too...
        let lightRain = WeatherDetails(text: "BR -RA")
        let moderateRain = WeatherDetails(text: "FZRA")
        let heavyRain = WeatherDetails(text: "+RA")
        let lightSnow = WeatherDetails(text: "-SN")
        let moderateSnow = WeatherDetails(text: "BLSN")
        let heavySnow = WeatherDetails(text: "+SN")
        let thunderstorm = WeatherDetails(text: "TSRA")
        XCTAssertEqual(lightRain.rain, .light)
        XCTAssertEqual(moderateRain.rain, .moderate)
        XCTAssertEqual(heavyRain.rain, .heavy)
        XCTAssertEqual(lightSnow.snow, .light)
        XCTAssertEqual(moderateSnow.snow, .moderate)
        XCTAssertEqual(heavySnow.snow, .heavy)
        XCTAssertTrue(thunderstorm.thunderStormsReported)
        XCTAssertFalse(heavyRain.thunderStormsReported)
        XCTAssertTrue(heavyRain.isRaining)
        XCTAssertTrue(moderateSnow.isSnowing)
        XCTAssertFalse(heavySnow.isRaining)
        XCTAssertFalse(lightRain.isSnowing)
        // Add weather details to report to test colors & icons
        // No data
        XCTAssertEqual(weatherReportOne!.wxColor, .bicolor)
        XCTAssertEqual(weatherReportOne!.wxIcon, "questionmark.square.dashed")
        // Good weather
        weatherReportOne!.hasData = true
        weatherReportOne!.visibility = 10.0
        XCTAssertEqual(weatherReportOne!.wxColor, .yellow)
        XCTAssertEqual(weatherReportOne!.wxIcon, "sun.max.fill")
        // Cloudy
        weatherReportOne!.clouds = [CloudLayer(.overcast, 500, nil)]
        XCTAssertEqual(weatherReportOne!.wxColor, .gray)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.fill")
        // Heavy rain
        weatherReportOne!.details = heavyRain
        XCTAssertEqual(weatherReportOne!.wxColor, .blue)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.heavyrain.fill")
        // Moderate/light rain
        weatherReportOne!.details = lightRain
        XCTAssertEqual(weatherReportOne!.wxColor, .blue)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.rain.fill")
        // Any snow
        weatherReportOne!.details = heavySnow
        XCTAssertEqual(weatherReportOne!.wxColor, .cyan)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.snow.fill")
        // Thunderstorms, no precipitation, no ceiling
        weatherReportOne!.details = WeatherDetails(text: "TS")
        weatherReportOne!.clouds = []
        XCTAssertEqual(weatherReportOne!.wxColor, .bicolorCaution)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.sun.bolt.fill")
        // Thunderstorms, no precipitation, has ceiling
        weatherReportOne!.clouds = [CloudLayer(.broken, 1000, .toweringCumulus)]
        XCTAssertEqual(weatherReportOne!.wxColor, .bicolorCaution)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.bolt.fill")
        // Thunderstorms with precipitation
        weatherReportOne!.details = WeatherDetails(text: "TSRA")
        XCTAssertEqual(weatherReportOne!.wxColor, .bicolorCaution)
        XCTAssertEqual(weatherReportOne!.wxIcon, "cloud.bolt.rain.fill")
    }
    //
    func testCeilingHeight() {
        weatherReportOne!.hasData = true
        weatherReportOne!.clouds = [CloudLayer(.scattered, 1500, nil)]
        XCTAssertFalse(weatherReportOne!.hasCeiling)
        XCTAssertNil(weatherReportOne!.ceilingLayer)
        weatherReportOne!.clouds = [CloudLayer(.scattered, 1500, nil),
                                    CloudLayer(.broken, 3000, nil)]
        XCTAssertTrue(weatherReportOne!.hasCeiling)
        XCTAssertEqual(weatherReportOne!.ceilingHeight, 3000)
    }
    //
    func testWeatherReportFlightConditions() {
        // Test with no data
        XCTAssertEqual(weatherReportOne!.flightCondition, .unknown)
        XCTAssertEqual(weatherReportOne!.flightConditionColor, .bicolor)
        // Set VFR without ceiling.
        weatherReportOne!.hasData = true
        weatherReportOne!.clouds = [CloudLayer(.scattered, 3500, nil)]
        weatherReportOne!.visibility = 10
        XCTAssertEqual(weatherReportOne!.flightCondition, .vfr)
        XCTAssertEqual(weatherReportOne!.flightConditionColor, .darkGreen)
        // Set VFR with ceiling (no need to repeat color test for VFR)
        weatherReportOne!.clouds = [CloudLayer(.broken, 3500, nil)]
        XCTAssertEqual(weatherReportOne!.flightCondition, .vfr)
        // Set MVFR
        weatherReportOne!.visibility = 4
        XCTAssertEqual(weatherReportOne!.flightCondition, .mvfr)
        XCTAssertEqual(weatherReportOne!.flightConditionColor, .blue)
        // Set IFR
        weatherReportOne!.clouds = [CloudLayer(.broken, 700, nil)]
        XCTAssertEqual(weatherReportOne!.flightCondition, .ifr)
        XCTAssertEqual(weatherReportOne!.flightConditionColor, .darkRed)
        // Set LIFR
        weatherReportOne!.visibility = 0.70
        XCTAssertEqual(weatherReportOne!.flightCondition, .lifr)
        XCTAssertEqual(weatherReportOne!.flightConditionColor, .magenta)
    }
    //
    func testStationPressure() {
        // STP test.
        weatherReportOne!.altimeter = 29.92
        weatherReportOne!.elevation = 0.0
        XCTAssertEqual(weatherReportOne!.stationPressure, 29.92)
        // Non-STP test.
        weatherReportOne!.altimeter = 30.09
        weatherReportOne!.elevation = 1000.0
        XCTAssertEqual(weatherReportOne!.stationPressure, 26.6878, accuracy: 0.005)
    }
    func testDensityAltitude() {
        // Test KRDU report vs. ForeFlight
        weatherReportOne!.elevation = 435.feetToMeters
        weatherReportOne!.altimeter = 29.88
        weatherReportOne!.temperature = 11
        weatherReportOne!.dewPoint = -2
        XCTAssertEqual(weatherReportOne!.densityAltitude, 193, accuracy: 5)
        // Test LAX report vs. ForeFlight
        weatherReportOne!.elevation = 128.feetToMeters
        weatherReportOne!.altimeter = 29.94
        weatherReportOne!.temperature = 14
        weatherReportOne!.dewPoint = 9
        XCTAssertEqual(weatherReportOne!.densityAltitude, 182, accuracy: 5)
    }
    func testRelativeHumidity() {
        // Test no data
        XCTAssertEqual(weatherReportOne!.relativeHumidity, 0.0)
        // Test 100% humidity (T == D)
        weatherReportOne!.hasData = true
        weatherReportOne!.temperature = 15.0
        weatherReportOne!.dewPoint = 15.0
        XCTAssertEqual(weatherReportOne!.relativeHumidity, 100.0)
        // Test RDU report vs. ForeFlight
        weatherReportOne!.hasData = true
        weatherReportOne!.temperature = 4.0
        weatherReportOne!.dewPoint = -1.0
        XCTAssertEqual(weatherReportOne!.relativeHumidity, 70.0, accuracy: 2.0)
    }
    func testTemperatureStrings() {
        // No data
        XCTAssertEqual(weatherReportOne!.temperatureToString(unit: .celsius), "----")
        XCTAssertEqual(weatherReportOne!.dewpointToString(unit: .celsius), "----")
        // Test in Celsius
        weatherReportOne!.hasData = true
        weatherReportOne!.temperature = 15.0
        weatherReportOne!.dewPoint = 0.0
        XCTAssertEqual(weatherReportOne!.temperatureToString(unit: .celsius), "15°C")
        XCTAssertEqual(weatherReportOne!.dewpointToString(unit: .celsius), "0°C")
        // Test in Fahrenheit
        XCTAssertEqual(weatherReportOne!.temperatureToString(unit: .fahrenheit), "59°F")
        XCTAssertEqual(weatherReportOne!.dewpointToString(unit: .fahrenheit), "32°F")
    }
    func testVisibilityStrings() {
        // No data
        XCTAssertEqual(weatherReportOne!.visibilityToString(unit: .mile), "----")
        // Test 1 mile
        weatherReportOne!.hasData = true
        weatherReportOne!.visibility = 1.0
        XCTAssertEqual(weatherReportOne!.visibilityToString(unit: .mile), "1 mi")
        XCTAssertEqual(weatherReportOne!.visibilityToString(unit: .kilometer), "1.61 km")
        // Test 0.5 mile
        weatherReportOne!.visibility = 0.5
        XCTAssertEqual(weatherReportOne!.visibilityToString(unit: .mile), "0.50 mi")
        XCTAssertEqual(weatherReportOne!.visibilityToString(unit: .kilometer), "804 m")
    }
    func testAltimeterString() {
        // No data
        XCTAssertEqual(weatherReportOne!.altimeterToString(unit: .inHg), "----")
        // Test with 29.92 inHg
        weatherReportOne!.hasData = true
        weatherReportOne!.altimeter = 29.92
        // Test inHg output
        XCTAssertEqual(weatherReportOne!.altimeterToString(unit: .inHg), "29.92\"")
        // Test MB (Q) output
        XCTAssertEqual(weatherReportOne!.altimeterToString(unit: .mbar), "Q1013")
    }
    func testTimeSinceReport() {
        // Test with no data
        XCTAssertNil(weatherReportOne!.timeSinceReport)
        // Test with data but no timestamp
        weatherReportOne!.hasData = true
        XCTAssertNil(weatherReportOne!.timeSinceReport)
        // Test with data and timestamp
        // Because this function's result will change
        // because of execution time, using contant diff.
        weatherReportOne!.reportTime = Date.now
        let timeSinceTuple = weatherReportOne!.timeSinceReport
        XCTAssertEqual(timeSinceTuple?.hours, 0)
        XCTAssertEqual(timeSinceTuple?.minutes, 5)
    }
}
