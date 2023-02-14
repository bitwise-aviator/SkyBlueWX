//
//  CloudLayerTests.swift
//  SkyBlueWXTests
//
//  Created by Daniel Sanchez on 2/13/23.
//

import XCTest
@testable import SkyBlueWX

final class CloudLayerTests: XCTestCase {
    var cloudOne: CloudLayer?
    var cloudTwo: CloudLayer?
    var cloudThree: CloudLayer?
    //
    override func setUp() {
        cloudOne = CloudLayer(.few, 1500, nil)
        cloudTwo = CloudLayer(.few, 1000, nil)
        cloudThree = CloudLayer(.few, 1500, nil)
    }
    //
    override func tearDown() {
        cloudOne = nil
        cloudTwo = nil
        cloudThree = nil
    }
    //
    func testLayerEquality() {
        XCTAssertNotEqual(cloudOne, cloudTwo)
        XCTAssertEqual(cloudOne, cloudThree)
    }
    //
    func testInitNoArgs() {
        let newLayer = CloudLayer(.few, 1000, .cumulonimbus)
        XCTAssertEqual(newLayer.cover, .few)
        XCTAssertEqual(newLayer.height, 1000)
        XCTAssertEqual(newLayer.specialCloud, .cumulonimbus)
    }
    //
    func testInitNamedArgs() {
        let newLayer = CloudLayer(cover: .scattered, height: 3000, specialCloud: .toweringCumulus)
        XCTAssertEqual(newLayer.cover, .scattered)
        XCTAssertEqual(newLayer.height, 3000)
        XCTAssertEqual(newLayer.specialCloud, .toweringCumulus)
    }
}
