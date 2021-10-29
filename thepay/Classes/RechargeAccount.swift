//
//  RechargeAccount.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct RechargeAccountResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargeAccountRequest: RequestAPI {
    
    struct Param {
        var rcgSeq: String
        var rcgMode: String
        var opCode: String
        var rcgType: String
        var ctn: String
        var rcgAmt: String
        var payAmt: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.recharge_account
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.rcgSeq      : param.rcgSeq,
            Key.rcgMode     : param.rcgMode,
            Key.opCode      : param.opCode,
            Key.rcgType     : param.rcgType,
            Key.pinNumber   : pinNumber,
            Key.CTN         : param.ctn,
            Key.ANI         : ani,
            Key.rcgAmt      : param.rcgAmt,
            Key.payAmt      : param.payAmt,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
        ]
        
        return params
    }
}
