//
//  APITestCase.swift
//  thePAYTests
//
//  Created by seojin on 2021/03/13.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import XCTest
//@testable import thePAY

class AuthCtnAPI: XCTestCase {
    struct CTN {
        static let MONTHLY  = IntegrateViewController.TestPhoneNumber.monthly.number
        static let REGULAR  = IntegrateViewController.TestPhoneNumber.regular.number
        static let ANI      = IntegrateViewController.TestPhoneNumber.ani.number
    }
    
    override func setUpWithError() throws {
        print("🏄🏼‍♂️ AuthCtnAPI Start")
    }

    override func tearDownWithError() throws {
        print("🏄🏼‍♂️ AuthCtnAPI End")
    }

    func testAPI() throws {
        var result: AuthCtnResponse?
        
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        
        APIProvider().authCtn(ctn: CTN.MONTHLY) { data in
            result = data
            if let printData = data?.O_DATA {
                self.printResult(result: printData)
            }
            expectation.fulfill() // 작업 완료 알림
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(result)
    }
    
    private func printResult(result: AuthCtnResponse.O_DATA) {
        print("🏄🏼‍♂️ result.rcgtype   \(result.rcgtype!)")
        print("🏄🏼‍♂️ result.rcgamt    \(result.rcgamt!)")
        print("🏄🏼‍♂️ result.mvno      \(result.mvno!)")
    }
}
