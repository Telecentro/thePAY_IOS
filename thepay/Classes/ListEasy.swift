//
//  EasyPayList.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

enum CardStatus: String {
    case typing     = "-1"
    case complete   = "00"
    case waiting    = "01"
    case processing = "02"
    case failure    = "09"
}

struct ListEasyResponse: ResponseAPI {
    struct O_DATA: Codable {
        var easyPayList:[easyPayList]?
        var easyPayAddFlag: String?
        var easyPayCheckList: Int?
    }
    
    struct easyPayList: Codable {
        let sortNo: Int
        let cardnum, cardnm, cardStatus, cardRegDt, cardStatusMsg: String?
        let status, authStatus: String?
        let easyPaySubSeq: Int?

        enum CodingKeys: String, CodingKey {
            case sortNo
            case cardnum = "CARDNUM"
            case cardnm = "CARDNM"
            case cardStatus = "CARDSTATUS"
            case cardStatusMsg = "CARDSTATUSMSG"
            case status = "STATUS"
            case authStatus = "AUTH_STATUS"
            case cardRegDt = "CARDREGDT"
            case easyPaySubSeq
        }
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class ListEasyRequest: RequestAPI {
    
    struct Param {
        var opCode: String
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_list
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
            Key.I_ACCESS_IP : ipAddress
        ]
        
        return params
    }
}
