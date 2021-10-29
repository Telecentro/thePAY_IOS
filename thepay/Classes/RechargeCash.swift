//
//  RechargeCash.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct RechargeCashResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargeCashRequest: RequestAPI {
    
    struct Param {
        var rcgSeq: String
        var rcgMode: String
        var opCode: String
        var rcgType: String
        var CTN: String
        var rcgAmt: String
        var payAmt: String
        var lang: String?
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.recharge_cash
    }
    
    override func getParam() -> [String : Any]? {
        
        guard let lang = param.lang == nil ? langCode : param.lang else { return nil }
        
        let params = [
            Key.rcgSeq      : param.rcgSeq,   // [sendData rcgSeq]
            Key.rcgMode     : param.rcgMode,   // [sendData rcgMode]
            Key.opCode      : param.opCode,   // [sendData opCode]
            Key.rcgType     : param.rcgType,   // [sendData rcgType]
            Key.pinNumber   : pinNumber,
            Key.CTN         : param.CTN,   // [sendData CTN]
            Key.ANI         : ani,
            Key.rcgAmt      : param.rcgAmt,   // [sendData rcgAmt]
            Key.payAmt      : param.payAmt,   // [sendData payAmt]
            Key.LANG        : lang,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
        ]
        
        return params
    }
}
