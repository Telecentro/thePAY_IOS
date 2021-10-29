//
//  PaymentInicis.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct PaymentInicisResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String

}

class PaymentInicisRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.payment_inicis
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber           : pinNumber,
            Key.CTN                 : "",   // [[Utils getObject] CTN]
            Key.USER_ID             : uuid,
            Key.LANG                : langCode,
            Key.SESSION_ID          : sessionId,
            Key.ENC_DATE            : enc_date,
            Key.OS                  : "OS",
            Key.appType             : "appType",
            Key.ANI                 : ani,
            Key.opCode              : "opCode", // [[Utils getObject] OP_CODE]
            Key.rcgSeq              : "",   // [[Utils getObject] RCG_SEQ]
            Key.rcgType             : "",   // [[Utils getObject] RCG_TYPE]
            Key.rcgAmt              : "",   // [[Utils getObject] Recharge_Amount]
            Key.payAmt              : "",   // [[Utils getObject] Amount]
            Key.CREDIT_BILL_TYPE    : "",   // [[Utils getObject] O_CREDIT_BILL_TYPE]
            Key.ORDERNUM            : "",   // [[Utils getObject] ORDER_NUM]
            Key.PG_ID               : "",   // [[Utils getObject] PG_ID]
            Key.noticeContents      : ""    // [[Utils getObject] NOTI_CONTENT] 분기 있음
            ]
        
        return params
    }
}
