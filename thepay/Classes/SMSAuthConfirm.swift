//
//  SMSAuthConfirm.swift
//  thepay
//
//  Created by xeozin on 2020/07/11.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct SMSAuthConfirmResponse: ResponseAPI {
    struct O_DATA: Codable {
        
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class SMSAuthConfirmRequest: RequestAPI {
    
    struct SMSAuthConfirmData {
        var SESSION_ID: String
        var AUTH_CODE: String
        var ANI: String
    }
    
    var data: SMSAuthConfirmData
    
    init(data: SMSAuthConfirmData) {
        self.data = data
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.sms_auth
    }
    
    override func getParam() -> [String : Any]? {
        let langCode = UserDefaultsManager.shared.loadNationCode()
        guard let uuid = UserDefaultsManager.shared.loadUUID() else { return nil }
        let params = [
            Key.opCode                      : "res",
            Key.ANI                         : self.data.ANI,
            Key.USER_ID                     : uuid,
            Key.MODEL                       : Utils.getModel(),
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : self.data.SESSION_ID,
            Key.SMSAuthConfirm.AUTH_CODE    : self.data.AUTH_CODE
        ]
        
        return params
    }
}
