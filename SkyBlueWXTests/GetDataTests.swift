//
//  GetDataTests.swift
//  SkyBlueWXTests
//
//  Created by Daniel Sanchez on 2/16/23.
//

import XCTest
@testable import SkyBlueWX

final class GetDataTests: XCTestCase {
    var reportHolder: WXReports?
    var reportOne: WeatherReport?

    override func setUpWithError() throws {
        reportHolder = WXReports()
        reportOne = WeatherReport(location: "ABCD")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testAssignmentAndRetrieval() async {
        await reportHolder!.assign(key: "ABCD", value: reportOne!)
        let goodReport = await reportHolder!.extract(key: "ABCD")
        XCTAssertEqual(goodReport!.icao, "ABCD")
        let badReport = await reportHolder!.extract(key: "BCDE")
        XCTAssertNil(badReport
        )
        await reportHolder!.vacate()
        let numberOfRecords = await reportHolder!.data.count
        XCTAssertEqual(numberOfRecords, 0)
    }
    func testDateSubtraction() {
        let nowDate = Date.now
        let nowPlusOneHour = nowDate.addingTimeInterval(300)
        XCTAssertEqual(nowPlusOneHour - nowDate, TimeInterval(300))
    }
    func testDateFormatting() {
        let timeString = "2023-02-17T02:23:00Z"
        var calendar = Calendar.current
        calendar.timeZone = .gmt
        let timeObject = parseReportTime(dateText: timeString)
        XCTAssertNotNil(timeObject)
        XCTAssertEqual(calendar.component(.hour, from: timeObject!), 2)
        XCTAssertEqual(calendar.component(.minute, from: timeObject!), 23)
        XCTAssertEqual(calendar.component(.day, from: timeObject!), 17)
        let badTimeString = "20230217T02:23:00Z"
        XCTAssertNil(parseReportTime(dateText: badTimeString))
    }
}
