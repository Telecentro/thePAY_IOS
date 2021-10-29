//
//  EasyPayReg.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct RegisterEasyResponse: ResponseAPI {
    struct O_DATA: Codable {
        var moveLink:String?
        var easyPaySubSeq: Int?
        var finishStepFlag: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RegisterEasyRequest: RequestAPI {
    
    struct Param {
        var easyPaySubSeq: String       // 선택한 간편결제 SEQ
        var easyPayStep: String         // 스텝
        var easyPayAuthNum: String
        var CREDIT_BILL_TYPE: String
        var cardNum: String
        var cardExpireYY: String
        var cardExpireMM: String
        var cardPsswd: String
        var userSecureNum: String
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_reg
    }
    
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber   : pinNumber,
            Key.ANI         : ani,
            Key.USER_ID     : uuid,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
            Key.I_ACCESS_IP : ipAddress,
            
            Key.CREDIT_BILL_TYPE    : param.CREDIT_BILL_TYPE,
            Key.cardNum             : param.cardNum,
            Key.cardExpireYY        : param.cardExpireYY,
            Key.cardExpireMM        : param.cardExpireMM,
            Key.cardPsswd           : param.cardPsswd,
            Key.userSecureNum       : param.userSecureNum,
            
            Key.EasyPay.easyPaySubSeq : param.easyPaySubSeq,
            Key.EasyPay.easyPayStep : param.easyPayStep,
            Key.EasyPay.easyPayAuthNum : param.easyPayAuthNum,
            
            // uploadFile : multi/part
            
        ]
        
        return params
    }
}
