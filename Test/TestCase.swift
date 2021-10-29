//
//  TestCase.swift
//  thePAYTests
//
//  Created by seojin on 2021/03/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import XCTest
//@testable import thePAY

class Test: XCTestCase {
    override func setUpWithError() throws {
        print("🏄🏼‍♂️ Test Start")
    }

    override func tearDownWithError() throws {
        print("🏄🏼‍♂️ Test End")
    }
    
    func test() throws {
        let p = CameraPermission()
        p.showCamera {
            print("🏄🏼‍♂️ OK")
        } denied: {
            print("🏄🏼‍♂️ OK")
        } notDetermined: {
            print("🏄🏼‍♂️ OK")
        }

    }
}
