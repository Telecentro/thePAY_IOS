//
//  EasyPayCheck.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct CheckEasyResponse: ResponseAPI {
    struct O_DATA: Codable {
        var maxTryCnt: Int?
        var authFailCnt: Int?
        var failCnt: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class CheckEasyRequest: RequestAPI {
    
    struct Param {
        var easyPayAuthNum: String      // 간편결제 인증번호 6자리
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_check
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
            
            Key.EasyPay.easyPayAuthNum : param.easyPayAuthNum
        ]
        
        return params
    }
}
