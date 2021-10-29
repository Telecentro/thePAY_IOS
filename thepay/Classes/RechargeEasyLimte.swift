//
//  RcgEasyPayLimit.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

// 간편결제 사항 체크
import Foundation

struct RechargeEasyLimteResponse: ResponseAPI {
    struct O_DATA: Codable {
        var rcgCardUsable: String?
        var rcgCardTitle: String?
        var rcgCardContents: String?
        var rcgCardType: String?
        var O_CREDIT_BILL_TYPE: String?
        var limiteSeq: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargeEasyLimteRequest: RequestAPI {
    
    struct Param {
        var rcgSeq: String
        var rcgType: String
        var rcgAmt: String
        var payAmt: String
        
        var easyPaySubSeq: String       // 선택한 간편결제 SEQ
        var ctn: String
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_pay_limte
    }
    
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.rcgSeq      : param.rcgSeq,
            Key.rcgType     : param.rcgType,
            Key.pinNumber   : pinNumber,
            Key.ANI         : ani,
            Key.USER_ID     : uuid,
            Key.rcgAmt      : param.rcgAmt,
            Key.payAmt      : param.payAmt,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
            Key.I_ACCESS_IP : ipAddress,
            Key.CTN         : param.ctn,
            Key.EasyPay.easyPaySubSeq  : param.easyPaySubSeq
        ]
        
        return params
    }
}
