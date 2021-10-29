//
//  CameraType.swift
//  thepay
//
//  Created by 홍서진 on 2021/09/17.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

enum CameraType {
    
    /* Safe Card */
    case creditCardFront
    case creditCardFront_Only
    case creditCardBack
    case idCardFront
    case myFace
    
    /* 체류 연장 */
    case alienCardFront
    case alienCardBack
    case passport
    case a4
    
    /* 웹뷰 */
    case imageScan
    case cardScan
    case webFace
    
    /* 일반 사진 */
    case clear
    
    var isFront: Bool {
        switch self {
        case .myFace, .webFace:
            return true
        default:
            return false
        }
    }
    
    var bnbID: String {
        switch self {
        case .creditCardFront:
            return "CREDIT_CARD_FRONT"
        case .creditCardBack:
            return "CREDIT_CARD_BACK"
        default:
            return ""
        }
    }
}
