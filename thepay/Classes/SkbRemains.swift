//
//  SkbRemains.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct SkbRemainsResponse: ResponseAPI {
    struct O_DATA: Codable {
        var Return_Code: String?
        var Control_No: String?
        var Current_Amt: String?
        var Trace_No: String?
        var cmd: String?
        var Access_No: String?
        var Ani_No: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class SkbRemainsRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.skb_remains
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                     : ani,
            Key.pinNumber               : pinNumber,
            Key.LANG                    : langCode,
            Key.SESSION_ID              : sessionId,
            Key.ENC_DATE                : enc_date,
            Key.AES256                  : aes256Value,
            Key.SkbRemains.Control_No   : ""    // [sendData Control_No]
            
        ]
        
        return params
    }
}
