//
//  CoreTests.swift
//  SkyBlueWXTests
//
//  Created by Daniel Sanchez on 2/16/23.
//

import XCTest
@testable import SkyBlueWX

final class CoreTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testDoubleMetersAndFeet() {
        let oneFoot: Double = 1.0
        let oneMeter: Double = 1.0
        XCTAssertEqual(oneFoot.feetToMeters, 0.3048)
        XCTAssertEqual(oneMeter.metersToFeet, 3.281, accuracy: 0.001)
    }
    func testDateSubtraction() {
        let nowDate = Date.now
        let nowPlusOneHour = nowDate.addingTimeInterval(300)
        XCTAssertEqual(nowPlusOneHour - nowDate, TimeInterval(300))
    }
}
