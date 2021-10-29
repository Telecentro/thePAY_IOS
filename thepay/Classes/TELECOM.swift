//
//  TELECOM.swift
//  thepay
//
//  Created by xeozin on 2020/10/14.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import Foundation

struct Tel {
    static let kr = "kr"
    static let kr_mvno = "82"
    static let paid = "item_paid"
    static let call = "item_call"
}

struct ACType {
    static let id = "id"
    static let email = "email"
    static let num = "num"
}

enum TELECOM {
    static let CODE_080 = "080"
    static let KT_CODE = "192"
    static let SKT_CODE = "193"
    
    static let KT_INTERNATIONAL_CODE = "00796"
    static let SKT_INTERNATIONAL_CODE_1 = "00301"
    static let SKT_INTERNATIONAL_CODE_2 = "0841102"
    
    static let KT_080_NUMBER = "080-320-0796"
    static let SKT_080_NUMBER = "080-820-1440"
    
    static let IMAGE_080301 = "dial_btn_080301"
    static let IMAGE_080796 = "dial_btn_080796"
    static let IMAGE_301080 = "dial_btn_301080"
    static let IMAGE_796080 = "dial_btn_796080"
    static let IMAGE_0841102 = "dial_btn_0841102"
}

enum KT: Int {
    case N796080 = 0
    case N080796 = 1
    
    var next: Int {
        switch self {
        case .N796080:
            return 1
        case .N080796:
            return 0
        }
    }
    
    static var defaultValue: KT {
        return .N080796
    }
    
    var telecomNumber: String {
        switch self {
        case .N796080:
            return TELECOM.KT_INTERNATIONAL_CODE
        case .N080796:
            return TELECOM.CODE_080
        }
    }
}

enum SKT: Int {
    case N301080 = 1
    case N080301 = 2
    case N0841102 = 0
    
    var next: Int {
        switch self {
        case .N301080:
            return 2
        case .N080301:
            return 0
        case .N0841102:
            return 1
        }
    }
    
    static var defaultValue: SKT {
        return .N0841102
    }
    
    var guidePreviewMsg: String {
        switch self {
        case .N301080:
            return Localized.guide_preview_msg_00796or00301.txt
        case .N080301:
            return Localized.guide_preview_msg_080to00301.txt
        case .N0841102:
            return Localized.guide_preview_msg_00301to0841102.txt
        }
    }
    
    var telecomNumber: String {
        switch self {
        case .N301080:
            return TELECOM.SKT_INTERNATIONAL_CODE_1
        case .N080301:
            return TELECOM.CODE_080
        case .N0841102:
            return TELECOM.SKT_INTERNATIONAL_CODE_2
        }
    }
    
    var imageName: String {
        switch self {
        case .N301080:
            return TELECOM.IMAGE_301080
        case .N080301:
            return TELECOM.IMAGE_080301
        case .N0841102:
            return TELECOM.IMAGE_0841102
        }
    }
}


enum DialerType {
    case kt
    case skt
    
//    var code: String {
//        switch self {
//        case .kt:
//            return TELECOM.KT_INTERNATIONAL_CODE
//        case .skt:
//            return TELECOM.SKT_INTERNATIONAL_CODE
//        }
//    }
    
    
    var emptyPrefix: String {
        switch self {
        case .kt:
            return TELECOM.KT_INTERNATIONAL_CODE
        case .skt:
            return TELECOM.SKT_INTERNATIONAL_CODE_1
        }
    }
    
    var number080: String {
        switch self {
        case .kt:
            return TELECOM.KT_080_NUMBER
        case .skt:
            return TELECOM.SKT_080_NUMBER
        }
    }
    
    var title: String{
        switch self {
        case .kt:
            return "KT"
        case .skt:
            return "SK"
        }
    }
    
    var key: String {
        switch self {
        case .kt:
            return TELECOM.KT_CODE
        case .skt:
            return TELECOM.SKT_CODE
        }
    }
}
