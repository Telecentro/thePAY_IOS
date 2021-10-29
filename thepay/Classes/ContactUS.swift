//
//  ContactUS.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct ContactUSResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class ContactUSRequest: RequestAPI{
    override func getAPI() -> String? {
        return API.shared.serviceURL.contact_us
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber   : pinNumber,
            Key.CTN         : "",
            Key.USER_ID     : uuid,
            Key.ANI         : ani,
            Key.LANG        : langCode,
            Key.CONTENTS    : "",
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value
        ]
        
        return params
    }
}
