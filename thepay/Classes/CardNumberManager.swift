//
//  CardNumberManager.swift
//  thepay
//
//  Created by xeozin on 2020/08/07.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

enum CardType: Int {
    case CARD_TYPE_NULL
    case CARD_TYPE_VISA_SHORTER
    case CARD_TYPE_MASTERCARD_SHORTER
    case CARD_TYPE_AMERICAN_EXPRESS_SHORTER
    case CARD_TYPE_DISCOVER
    case CARD_TYPE_DISCOVER_SHORT
    case CARD_TYPE_JCB_SHORT
    case CARD_TYPE_DINERS_CLUB_SHORT
    case CARD_TYPE_UNION_PAY_SHORT
    case CARD_TYPE_HANA
    case CARD_TYPE_HANA_KEB
    case CARD_TYPE_KEB_HANA
    case CARD_TYPE_KOOKMIN
    case CARD_TYPE_HANA_CCHN
    case CARD_TYPE_KOOKMIN_CCKM
    case CARD_TYPE_BC
    case CARD_TYPE_KEB_HANA_CCKE
    case CARD_TYPE_BC_CCB
}

class CardManager: NSObject {
    
    var cardType: CardType = .CARD_TYPE_NULL
    static let shared = CardManager()
    
    func loadCardNumber1() -> String {
        if let savedCardNumbers = UserDefaultsManager.shared.loadRecentCardNumber() {
            if isShorterCard() {
                return String(savedCardNumbers[...3])
            } else {
                return String(savedCardNumbers[...3])
            }
        } else {
            return ""
        }
    }
    
    func loadCardNumber2() -> String {
        if let savedCardNumbers = UserDefaultsManager.shared.loadRecentCardNumber() {
            if isShorterCard() {
                return String(savedCardNumbers[4...9])
            } else {
                return String(savedCardNumbers[4...7])
            }
        } else {
            return ""
        }
    }
    
    func loadCardNumber3() -> String {
        if let savedCardNumbers = UserDefaultsManager.shared.loadRecentCardNumber() {
            if isShorterCard() {
                return String(savedCardNumbers[10...])
            } else {
                return String(savedCardNumbers[8...11])
            }
        } else {
            return ""
        }
    }
    
    func loadCardNumber4() -> String {
        if let savedCardNumbers = UserDefaultsManager.shared.loadRecentCardNumber() {
            let count = savedCardNumbers.count
            if count > 11 && count < 17 {
                return String(savedCardNumbers[12...])
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    func isShorterCard() -> Bool {
        switch cardType {
        case .CARD_TYPE_AMERICAN_EXPRESS_SHORTER, .CARD_TYPE_DINERS_CLUB_SHORT:
            return true
        default:
            return false
        }
    }
    
    func getLastCardPlaceholder() -> String {
        switch cardType {
        case .CARD_TYPE_AMERICAN_EXPRESS_SHORTER:
            return "00000"
        default:
            return "0000"
        }
    }
}
