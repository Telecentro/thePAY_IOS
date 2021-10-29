//
//  AuthAccount.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct AuthAccountResponse: ResponseAPI {
    struct O_DATA: Codable {
        var failCnt: String?      // 1/5
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class AuthAccountRequest: RequestAPI {
    
    struct Param {
        var opCode: String              // 계좌인증 : req, 인증번호입력 : res
        
        var acctBankCd: String          // req
        var acctBankNum: String         // req
        var acctHolder: String          // req
//        var acctSocileId: String        // req
        var acctAuthCd: String          // res
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_auth_account
    }
    
    
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode      : param.opCode,
            Key.pinNumber   : pinNumber,
            Key.ANI         : ani,
            Key.USER_ID     : uuid,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
            Key.I_ACCESS_IP : ipAddress,
            
            Key.EasyPay.acctBankCd      : param.acctBankCd,
            Key.EasyPay.acctBankNum     : param.acctBankNum,
            Key.EasyPay.acctHolder      : param.acctHolder,
//            Key.EasyPay.acctSocileId    : param.acctSocileId,
            Key.EasyPay.acctAuthCd      : param.acctAuthCd
        ]
        
        return params
    }
}
