//
//  PreladingAPITestCase.swift
//  thePAYTests
//
//  Created by seojin on 2021/03/13.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import XCTest
//@testable import thePAY

class PreloadingAPI: XCTestCase {
    
    override func setUpWithError() throws {
        print("🏄🏼‍♂️ PreloadingAPI Start")
    }

    override func tearDownWithError() throws {
        print("🏄🏼‍♂️ PreloadingAPI End")
    }
    
    func testAPI() throws {
        var result: PreloadingResponse?
        
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        
        APIProvider().preloading { data in
            result = data
            expectation.fulfill() // 작업 완료 알림
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(result)
    }
}
