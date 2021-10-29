//
//  EasyPayPreValue.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct PreEasyResponse: ResponseAPI {
    struct O_DATA: Codable {
        var msgType: String?
        var O_CREDIT_BILL_TYPE: String?
        var msgBoxGubun: String?
        var moveLink: String?
        var bankList: [bankList]?
        var rcvOptionList: rcvOptionList?
        var easyPayStepValue: easyPayStepValue?
    }
    
    struct easyPayStepValue: Codable {
        var step2:[step2]?
        var step3:[step3]?
    }
    
    struct step2:Codable {
        var FILE_PATH_1: String?
        var FILE_PATH_2: String?
        var FILE_PATH_3: String?
        var FILE_PATH_4: String?
        var FILE_PATH_5: String?
        var FILE_PATH_6: String?
        var FILE_PATH_7: String?
    }
    
    struct step3:Codable {
        var CARD_SOCIAL_ID: String?
        var CARD_PASSWD: String?
        var CARD_EXPIRE_YY: String?
        var CARD_EXPIRE_MM: String?
        var CARD_NUMBER: String?
    }
    
    struct rcvOptionList: Codable {
        var SIGN_PIC: String?
        var SELF_PIC: String?
        var PASSPORT_PIC: String?
        var CREDITCARD_PIC2: String?
        var FOREIGN_PIC1: String?
        var FOREIGN_PIC2: String?
        var CREDITCARD_PIC1: String?
    }
    
    struct bankList: Codable {
        var sortNo: Int?
        var bankCode: String?
        var bankNameKr: String?
        var bankNameJp: String?
        var imgNm: String?
        var bankNameCn: String?
        var bankNameUs: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PreEasyRequest: RequestAPI {
    
    struct Param {
        var easyPaySubSeq: String       // 선택한 간편결제 SEQ
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_pre
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
            
            Key.EasyPay.easyPaySubSeq : param.easyPaySubSeq
        ]
        
        return params
    }
}
