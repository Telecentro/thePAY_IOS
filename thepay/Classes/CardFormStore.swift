//
//  CardFormStore.swift
//  thepay
//
//  Created by xeozin on 2020/09/17.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

struct CardFormStoreResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}


class CardFormStoreRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.card_form_store
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value
        ]
        
        return params
    }
}
