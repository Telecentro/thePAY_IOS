//
//  ReleaseTestCase.swift
//  thePAYTests
//
//  Created by seojin on 2021/03/13.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import XCTest
//@testable import thePAY

class Release: XCTestCase {
    override func setUpWithError() throws {
        print("🏄🏼‍♂️ Release Start")
    }

    override func tearDownWithError() throws {
        print("🏄🏼‍♂️ Release End")
    }
    
    func testRelease() throws {
        XCTAssertTrue(App.shared.debug == .none)
    }
}
