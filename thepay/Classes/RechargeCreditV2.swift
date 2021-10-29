//
//  RechargeCreditV2.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct RechargeCreditV2Response: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargeCreditV2Request: RequestAPI {
    
    struct Param {
        var rcgSeq: String
        var rcgMode: String
        var opCode: String
        var rcgType: String
        var CTN: String
        var rcgAmt: String
        var payAmt: String
        var cardName: String
        var cardNum: String
        var cardExpireYY: String
        var cardExpireMM: String
        var cardPsswd: String
        var cardCvc: String
        var userSecureNum: String
        var limiteSeq: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.recharge_credit_v2
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.rcgSeq                      : param.rcgSeq,
            Key.rcgMode                     : param.rcgMode,
            Key.opCode                      : param.opCode,
            Key.rcgType                     : param.rcgType,
            Key.pinNumber                   : pinNumber,
            Key.CTN                         : param.CTN,
            Key.ANI                         : ani,
            Key.rcgAmt                      : param.rcgAmt,
            Key.payAmt                      : param.payAmt,
            Key.LANG                        : langCode,
            Key.RechargeCreditV2.cardName   : param.cardName,
            Key.cardNum                     : param.cardNum.encryptCard(),
            Key.cardExpireYY                : param.cardExpireYY.encryptCard(),
            Key.cardExpireMM                : param.cardExpireMM.encryptCard(),
            Key.cardPsswd                   : param.cardPsswd.encryptCard(),
            Key.RechargeCreditV2.cardCvc    : param.cardCvc,
            Key.userSecureNum               : param.userSecureNum.encryptCard(),
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
            Key.RechargeCreditV2.limiteSeq  : param.limiteSeq
        ]
        
        return params
    }
}
