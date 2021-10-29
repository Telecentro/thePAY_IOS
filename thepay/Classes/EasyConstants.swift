//
//  EasyPayObjects.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

enum EasyStep : String {
    case step1 = "1"
    case step2 = "2"
    case step3 = "3"
    case step4 = "4"
    case step5 = "5"
}


struct FLAG {
    static let A = "A"
    static let U = "U"
    static let Y = "Y"
    static let N = "N"
    
    static let SUCCESS = "0000"
    static let E0001 = "0001"
    static let E0002 = "0002"
    static let E8905 = "8905"
    static let E8906 = "8906"
    
    static let alert = "alert"
    static let toast = "toast"
}

struct FILE_NAME {
    static let FILE_CREDIT_CARD_FRONT = "CREDIT_CARD_FRONT";
    static let FILE_CREDIT_CARD_BACK = "CREDIT_CARD_BACK";
    static let FILE_ALINE_CARD_FRONT = "ALINE_CARD_FRONT";
    static let FILE_ALINE_CARD_BACK = "ALINE_CARD_BACK";
    static let FILE_PASSPORT = "PASSPORT";
    static let FILE_SELF_CAMERA = "SELF_CAMERA";
    static let FILE_SIGNATURE = "SIGNATURE";
}

struct CARD_INFO {
    static let NUMBER_1 = "NUMBER_1"
    static let NUMBER_2 = "NUMBER_2"
    static let NUMBER_3 = "NUMBER_3"
    static let NUMBER_4 = "NUMBER_4"
    static let NUMBER_2_EXPRESS = "NUMBER_2_EXPRESS"
    static let NUMBER_3_EXPRESS = "NUMBER_3_EXPRESS"
    static let MONTH = "MONTH"
    static let YEAR = "YEAR"
    static let PASSWORD = "PASSWORD"
    static let BIRTH = "BIRTH"
}
