//
//  WithdrawalCheck.swift
//  thepay
//
//  Created by 홍서진 on 2021/09/24.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct WithdrawalCheckResponse: ResponseAPI {
    struct O_DATA: Codable {
        var rcgMsg: String?
        var RCK: Int?
        var CASH: Int?
        var POINT: Int?
        var withDraw: [withdraw]?
        
        struct withdraw: Codable {
            var sortNo: Int?
            var withDrawCD: String?
            var withDrawResaon: String?
        }
        
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class WithdrawalCheckRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.withdrawalCheck
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber               :pinNumber,
            Key.ANI                     :ani,
            Key.USER_ID                 :uuid,
            Key.LANG                    :langCode,
            Key.SESSION_ID              :sessionId,
            Key.ENC_DATE                :enc_date,
            Key.AES256                  :aes256Value,
            Key.I_ACCESS_IP             :ipAddress,
        ]
        
        return params
    }
}
