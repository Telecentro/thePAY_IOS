//
//  RechargePreview.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum OCHARGEFLAG : String {
    case y = "y"
    case n = "n"
}

enum OPAYFLAG : String {
    case y = "y"
    case n = "n"
}

enum OCREDITBILLTYPE: String {
    case Bill_11 = "11"
    case Bill_12 = "12"
    case Bill_13 = "13" // 카유비생
    case Bill_18 = "18" // 카유
}

struct Bill {
    static let T11 = "11"
    static let T12 = "12"
    static let T13 = "13"
    static let T18 = "18"
}

struct Content {
    static let web = "web"
    static let txt = "txt"
}

struct RechargePreviewResponse: ResponseAPI {
    struct O_DATA: Codable {
        var O_RCG_SEQ: String?
        var O_PG_ID: String?
        var O_OP_CODE: String?
        var O_CHARGE_FLAG: String?
        var O_NOTIECE_CONTENT: String?
        var O_IS_SHOW_CREDIT_MENU: String?
        var NOTIECE_TITLE: String?
        var O_PAY_FLAG: String?
        var O_CREDIT_BILL_TYPE: String?
        var O_ORDERNUM: String?
        var easyPayFlag: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargePreviewRequest: RequestAPI {
    
    struct Param {
        var opCode: String
        var rcgType: String
        var ctn: String
        var mvnoId: String
        var rcgAmt: String
        var userCash: String
        var userPoint: String
        var payAmt: String
        var customLang: String?
        var alarmFlag: String?
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.recharge_preview
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode                      : param.opCode,   // [sendData opCode]
            Key.rcgType                     : param.rcgType,   // [sendData rcgType]
            Key.pinNumber                   : pinNumber,
            Key.CTN                         : param.ctn,   // [sendData pinNumber]
            Key.RechargePreview.mvnoId      : param.mvnoId,   // [sendData mvnoId]
            Key.rcgAmt                      : param.rcgAmt,   // [sendData rcgAmt]
            Key.userCash                    : param.userCash,   // [sendData userCash]
            Key.userPoint                   : param.userPoint,   // [sendData userPoint]
            Key.payAmt                      : param.payAmt,   // [sendData payAmt]
            Key.LANG                        : param.customLang ?? langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
            Key.OS_LANG                     : os_lang,
            Key.alarmFlag                   : param.alarmFlag ?? "",
            Key.ANI                         : ani
        ]
        
        return params
    }
}

