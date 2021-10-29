//
//  CardViewModel.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/16.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

enum RcgCardUsable: String {
    case n = "n"
    case y = "y"
}

struct DIGIT {
//    static let L2: Int = 2
    static let L4: Int = 4
    static let L5: Int = 5
    static let L6: Int = 6
}

enum PaymentType {
    case cardpay
    case easypay
}

enum EasyPaymentType {
    case select
    case easyAndSafe
    case easyOnly
}



struct CardInfo {
    let encryptCardNum:String
    let yy: String
    let mm: String
    let cardPwd: String
    let userSecureNum: String
}

struct RechargeInfo {
    let rcgType: String
    let rcgAmt: String
    let payAmt: String
    let rcgSeq: String
    let opCode: String
    let ctn: String
}

struct RecharegeLimitInfo {
    let rcgType: String
    let rcgAmt: String
    let payAmt: String
    let rcgSeq: String
    let billtype: String    // easypay에서는 사용안함
    let ctn: String
}


class CardViewModel {
    var inputCount = 0
    var from: ChargeFrom?
    var payInfo: PayInfo?
    var showDetail: Bool = false
    var limitSeq = ""
    var cm = CardManager.shared
    
    // ChargeCard 관련
    var chargeIndex = 0
    var oCreditBillType = UserDefaultsManager.shared.loadCreditBillType() ?? ""
    var amount = ""
    var lastSelectAmountInfo: SubPreloadingResponse.cashList?
    
    // 간편결제 관련
    var paymentType: PaymentType = .cardpay
    var ezPaymentType: EasyPaymentType = .select
    
    
    func getRechargeInfo() -> RechargeInfo? {
        guard let t = self.from else {
            return nil
        }
        
        switch t {
        case .cash:
            return RechargeInfo(
                rcgType: "CASH",
                rcgAmt: amount,
                payAmt: amount,
                rcgSeq: "CASH",
                opCode: "CASH",
                ctn: UserDefaultsManager.shared.loadANI() ?? ""
            )
        case .payment:
            guard let info = self.payInfo else { return nil }
            return RechargeInfo(
                rcgType: info.rcgType ?? "",
                rcgAmt: String(info.rechargeAmount ?? 0),
                payAmt: String(info.amount ?? 0),
                rcgSeq: info.rcgSeq ?? "",
                opCode: info.opCode ?? "",
                ctn: info.ctn ?? ""
            )
        }
    }
    
    func getRechargeLimitInfo() -> RecharegeLimitInfo? {
        guard let t = self.from else {
            return nil
        }
        
        switch t {
        case .cash:
            return RecharegeLimitInfo(
                rcgType: "CASH",
                rcgAmt: amount,
                payAmt: amount,
                rcgSeq: "CASH",
                billtype: oCreditBillType,
                ctn: UserDefaultsManager.shared.loadANI() ?? ""
            )
        case .payment:
            guard let info = self.payInfo else { return nil }
            return RecharegeLimitInfo(
                rcgType: info.rcgType ?? "",
                rcgAmt: String(info.rechargeAmount ?? 0),
                payAmt: String(info.amount ?? 0),
                rcgSeq: info.rcgSeq ?? "",
                billtype: oCreditBillType,
                ctn: info.ctn ?? ""
            )
        }
    }
}
