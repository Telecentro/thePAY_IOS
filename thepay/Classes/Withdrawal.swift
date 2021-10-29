//
//  Withdrawal.swift
//  thepay
//
//  Created by 홍서진 on 2021/09/24.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct WithdrawalResponse: ResponseAPI {
    struct O_DATA: Codable {
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class WithdrawalRequest: RequestAPI {
    
    struct Param {
        var withDrawResaon: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.withdrawal
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   :pinNumber,
            Key.ANI                         :ani,
            Key.USER_ID                     :uuid,
            Key.LANG                        :langCode,
            Key.SESSION_ID                  :sessionId,
            Key.ENC_DATE                    :enc_date,
            Key.AES256                      :aes256Value,
            Key.Withdrawal.withDrawResaon   :param.withDrawResaon,
            Key.I_ACCESS_IP                 :ipAddress,
        ]
        
        return params
    }
}
