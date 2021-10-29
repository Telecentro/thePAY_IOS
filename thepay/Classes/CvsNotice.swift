//
//  CvsNotice.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct CvsNoticeResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class CvsNoticeRequest: RequestAPI{
    override func getAPI() -> String? {
        return API.shared.serviceURL.cvs_notice
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
//            [sendData ACCESS_IP], "ACCESS_IP", Obj-C 주석 긁어옴
        ]
        
        return params
    }
}
