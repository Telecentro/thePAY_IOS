//
//  KtposRemains.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct KtposRemainsResponse: ResponseAPI {
    struct ktposBarCodeList: Codable {
        var mvnoName: String?
        var balance: String?
        var expireDate: String?
        var barcode2: String?
        var barcode1: String?
        var cardNumber: String?
    }
    
    struct O_DATA: Codable {
        var ktposBarCodeList:[ktposBarCodeList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class KtposRemainsRequest: RequestAPI{
    override func getAPI() -> String? {
        return API.shared.serviceURL.ktpos_remains
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                         : ani,
            Key.pinNumber                   : pinNumber,
            Key.LANG                        : langCode,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
            Key.SESSION_ID                  : sessionId,
            Key.KtposRemains.GOODS_ID       : ""    // [sendData ENC_DATE]
        ]
        
        return params
    }
}
