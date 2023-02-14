//
//  WindTests.swift
//  SkyBlueWXTests
//
//  Created by Daniel Sanchez on 2/13/23.
//

import XCTest
@testable import SkyBlueWX

final class WindTests: XCTestCase {
    var reportOne: WeatherReport?
    var windOne: Wind?
    //
    override func setUp() {
        reportOne = WeatherReport(location: "XXXX")
        windOne = Wind(direction: nil, speed: 0, gusts: nil)
    }
    //
    override func tearDown() {
        windOne = nil
    }
    //
    func testWindIsVariable() {
        XCTAssertTrue(windOne!.isVariable)
        windOne!.direction = 0
        XCTAssertTrue(windOne!.isVariable)
        windOne!.direction = 10
        XCTAssertFalse(windOne!.isVariable)
    }
    //
    func testWindHasGusts() {
        XCTAssertFalse(windOne!.hasGusts)
        windOne!.direction = 90
        windOne!.speed = 5
        windOne!.gusts = 3
        XCTAssertFalse(windOne!.hasGusts)
        windOne!.gusts = 8
        XCTAssertTrue(windOne!.hasGusts)
    }
    //
    func testSpeedsToString() {
        // Test behavior for no data.
        XCTAssertEqual(reportOne!.windSpeedToString(unit: .knot), "--")
        XCTAssertEqual(reportOne!.windGustsToString(unit: .knot), "--")
        // Test behavior for wind without gusts.
        reportOne!.hasData = true
        reportOne!.wind = windOne!
        XCTAssertEqual(reportOne!.windGustsToString(unit: .knot), "--")
        // Test behavior for speed 5 kt & gusts 10 kt
        reportOne!.wind = Wind(direction: 320, speed: 5, gusts: 10)
        // In knots...
        XCTAssertEqual(reportOne!.windSpeedToString(unit: .knot), "5")
        XCTAssertEqual(reportOne!.windGustsToString(unit: .knot), "10")
        // In mph
        XCTAssertEqual(reportOne!.windSpeedToString(unit: .mph), "6")
        XCTAssertEqual(reportOne!.windGustsToString(unit: .mph), "12")
        // In km/h
        XCTAssertEqual(reportOne!.windSpeedToString(unit: .kmh), "9")
        XCTAssertEqual(reportOne!.windGustsToString(unit: .kmh), "19")
    }
    func testDirectionToString() {
        // Test no data
        XCTAssertEqual(reportOne!.windDirToString, "---° --")
        // Test calm winds
        reportOne!.hasData = true
        reportOne!.wind = Wind(direction: 0, speed: 0, gusts: nil)
        XCTAssertEqual(reportOne!.windDirToString, "CALM")
        // Test variable winds
        reportOne!.wind.speed = 2
        XCTAssertEqual(reportOne!.windDirToString, "VRB")
        // Test for all directions
        reportOne!.wind.direction = 360
        XCTAssertEqual(reportOne!.windDirToString, "360° N")
        reportOne!.wind.direction = 45
        XCTAssertEqual(reportOne!.windDirToString, "045° NE")
        reportOne!.wind.direction = 90
        XCTAssertEqual(reportOne!.windDirToString, "090° E")
        reportOne!.wind.direction = 135
        XCTAssertEqual(reportOne!.windDirToString, "135° SE")
        reportOne!.wind.direction = 180
        XCTAssertEqual(reportOne!.windDirToString, "180° S")
        reportOne!.wind.direction = 225
        XCTAssertEqual(reportOne!.windDirToString, "225° SW")
        reportOne!.wind.direction = 270
        XCTAssertEqual(reportOne!.windDirToString, "270° W")
        reportOne!.wind.direction = 315
        XCTAssertEqual(reportOne!.windDirToString, "315° NW")
        // Test for out-of-range wind directions
        // Should be treated as bad data.
        reportOne!.wind.direction = 371
        XCTAssertEqual(reportOne!.windDirToString, "---° --")
        reportOne!.wind.direction = -1
        XCTAssertEqual(reportOne!.windDirToString, "---° --")
    }
}
