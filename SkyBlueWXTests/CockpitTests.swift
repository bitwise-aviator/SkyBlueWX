//
//  CockpitTests.swift
//  SkyBlueWXTests
//
//  Created by Daniel Sanchez on 2/14/23.
//

import XCTest
@testable import SkyBlueWX

final class CockpitTests: XCTestCase {
    var cockpit: Cockpit?
    var reportOne = WeatherReport(location: "1")
    var reportTwo = WeatherReport(location: "2")
    var reportThree = WeatherReport(location: "3")
    override func setUpWithError() throws {
        cockpit = Cockpit()
        cockpit!.reports["1"] = reportOne
        cockpit!.reports["2"] = reportTwo
        cockpit!.reports["3"] = reportThree
        cockpit!.activeReport = "2"
        cockpit!.activeReportStruct = cockpit!.reports["2"]
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testMoveToReport() {
        // Test against moving to a non-existing report.
        XCTAssertFalse(cockpit!.moveToReport(icao: "4"))
        XCTAssertEqual(cockpit!.activeReport, "2")
        // Test moving to existing report.
        XCTAssertTrue(cockpit!.moveToReport(icao: "1"))
        XCTAssertEqual(cockpit!.activeReport, "1")
    }
    func testRemoveReport() {
        // Test that setup is correct.
        XCTAssertEqual(cockpit!.reportKeys, ["1", "2", "3"])
        // Test removing a non-existing report.
        cockpit!.removeReport(icao: "0")
        XCTAssertEqual(cockpit!.reportKeys, ["1", "2", "3"])
        // Test removing a non-active report
        cockpit!.removeReport(icao: "3")
        XCTAssertEqual(cockpit!.reportKeys, ["1", "2"])
        XCTAssertEqual(cockpit!.activeReport, "2")
        // Test removing the second report (active!)
        cockpit!.removeReport(icao: "2")
        XCTAssertEqual(cockpit!.reportKeys, ["1"])
        XCTAssertEqual(cockpit!.activeReport, "1")
        // Test removing the final report
        cockpit!.removeReport(icao: "1")
        XCTAssertEqual(cockpit!.reportKeys, [])
        XCTAssertNil(cockpit!.activeReport)
    }
    func testSetVisibilityUnit() {
        // Force set to km
        cockpit!.setVisibilityUnit(.kilometer)
        XCTAssertEqual(cockpit!.settings.visibilityUnit, .kilometer)
        // Force set to miles
        cockpit!.setVisibilityUnit(.mile)
        XCTAssertEqual(cockpit!.settings.visibilityUnit, .mile)
        // Toggle from miles to km
        cockpit!.setVisibilityUnit()
        XCTAssertEqual(cockpit!.settings.visibilityUnit, .kilometer)
        // Toggle from km to miles
        cockpit!.setVisibilityUnit()
        XCTAssertEqual(cockpit!.settings.visibilityUnit, .mile)
    }
    func testSetAltitudeUnit() {
        // Force set to meters
        cockpit!.setAltitudeUnit(.meter)
        XCTAssertEqual(cockpit!.settings.altitudeUnit, .meter)
        // Force set to feet
        cockpit!.setAltitudeUnit(.feet)
        XCTAssertEqual(cockpit!.settings.altitudeUnit, .feet)
        // Toggle from feet to meters
        cockpit!.setAltitudeUnit()
        XCTAssertEqual(cockpit!.settings.altitudeUnit, .meter)
        // Toggle from meters to feet
        cockpit!.setAltitudeUnit()
        XCTAssertEqual(cockpit!.settings.altitudeUnit, .feet)
    }
    func testSetPressureUnit() {
        // Force set to MB
        cockpit!.setPressureUnit(.mbar)
        XCTAssertEqual(cockpit!.settings.pressureUnit, .mbar)
        // Force set to inHg
        cockpit!.setPressureUnit(.inHg)
        XCTAssertEqual(cockpit!.settings.pressureUnit, .inHg)
        // Toggle from inHg to MB
        cockpit!.setPressureUnit()
        XCTAssertEqual(cockpit!.settings.pressureUnit, .mbar)
        // Toggle from MB to inHg
        cockpit!.setPressureUnit()
        XCTAssertEqual(cockpit!.settings.pressureUnit, .inHg)
    }
    func testSetHomeAirport() {
        cockpit!.setHomeAirport("ABCD")
        XCTAssertEqual(cockpit!.settings.homeAirport, "ABCD")
    }
    func testQueryListManipulation() {
        cockpit!.queryCodes = ["A", "B", "C", "D"]
        // Toggle: add value
        cockpit!.editQueryList("E")
        XCTAssertTrue(cockpit!.queryCodes.contains("E"))
        // Toggle: remove value
        cockpit!.editQueryList("E")
        XCTAssertFalse(cockpit!.queryCodes.contains("E"))
        // Retention: D should not be removed
        cockpit!.editQueryList("D", retain: true)
        XCTAssertTrue(cockpit!.queryCodes.contains("D"))
        // Exclusion: F should not be added.
        cockpit!.editQueryList("F", exclude: true)
        XCTAssertFalse(cockpit!.queryCodes.contains("F"))
    }
}
