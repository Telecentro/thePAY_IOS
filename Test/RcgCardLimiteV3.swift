//
//  RcgCardLimiteV3.swift
//  thePAYTests
//
//  Created by seojin on 2021/03/13.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import XCTest
//@testable import thePAY

class RcgCardLimiteV3API: XCTestCase {
    
    override func setUpWithError() throws {
        print("🏄🏼‍♂️ PreloadingAPI Start")
    }

    override func tearDownWithError() throws {
        print("🏄🏼‍♂️ PreloadingAPI End")
    }
    
    func testAPI() throws {
        guard let param = getDummyParam() as? RcgCardLimiteV3Request.Param else { return }
        
        var result: RcgCardLimiteV3Response?
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        
        APIProvider().rcgCardLimiteV3(param: param) { data in
            result = data
            expectation.fulfill() // 작업 완료 알림
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(result)
    }
    
    private func getDummyParam() -> Any {
        return RcgCardLimiteV3Request.Param(cardNum: "1111222233334444",
                                            cardExpireYY: "24",
                                            cardExpireMM: "12",
                                            cardPsswd: "22",
                                            userSecureNum: "901010",
                                            rcgAmt: "10000",
                                            payAmt: "20000",
                                            rcgType: "L",
                                            rcgSeq: "0",
                                            O_CREDIT_BILL_TYPE: Bill.T13,
                                            ctn: "")
    }
}
