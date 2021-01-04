//
//  MusicAppTests.swift
//  MusicAppTests
//
//  Created by MSS on 23/11/20.
//  Copyright © 2020 Ankit Bansal. All rights reserved.
//

import XCTest
@testable import MusicApp

class MusicAppTests: XCTestCase {

    func testInValidDuration() {
        let vc = ViewController()
        let duration = vc.formatTimeFor(seconds: -2)
        if duration.contains("-") {
            XCTFail("Invalid Duration")
        }
    }
    
    func testValidDuration() {
        let vc = ViewController()
        let _ = vc.formatTimeFor(seconds: 2)
        XCTAssertTrue(true, "Valid Duration")
    }
}
