//
//  EasyPayDel.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct DeleteEasyResponse: ResponseAPI {
    struct O_DATA: Codable {
        var moveLink: String?   // 삭제 후 이동페이지
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class DeleteEasyRequest: RequestAPI {
    
    struct Param {
        var easyPaySubSeq: String       // 선택한 간편결제 SEQ
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_delete
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
            
            Key.EasyPay.easyPaySubSeq  : param.easyPaySubSeq,
        ]
        
        return params
    }
}
