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
        // Set VFR
        weatherReportOne!.hasData = true
        weatherReportOne!.clouds = [CloudLayer(.broken, 3500, nil)]
        weatherReportOne!.visibility = 10
        XCTAssertEqual(weatherReportOne!.flightCondition, .vfr)
        XCTAssertEqual(weatherReportOne!.flightConditionColor, .darkGreen)
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
}
