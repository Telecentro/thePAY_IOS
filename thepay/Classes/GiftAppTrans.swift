//
//  PreCheck.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/16.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct GiftTransResponse: ResponseAPI {
    struct O_DATA: Codable {
        var transType: String?
        var transSeq: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class GiftTransRequest: RequestAPI {
    
    struct Param {
        var opCode: GiftCash.OperationCode
        var transSeq: String    // 최초 req 에는 null
        var transNm: String     // 송금자명
        var transTo: String     // 타깃 (전화번호 또는 mail)
        var transAmt: String    // 송금액
        var authCode: String    // res 때만 입력 필수 그외는 null
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.gift_trans
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode                  :param.opCode.code,
            Key.pinNumber               :pinNumber,
            Key.ANI                     :ani,
            Key.USER_ID                 :uuid,
            Key.LANG                    :langCode,
            Key.SESSION_ID              :sessionId,
            Key.ENC_DATE                :enc_date,
            Key.AES256                  :aes256Value,
            Key.I_ACCESS_IP             :ipAddress,
            
            Key.GiftCash.transSeq       :param.transSeq,
            Key.GiftCash.transNm        :param.transNm,
            Key.GiftCash.transTo        :param.transTo,
            Key.GiftCash.transAmt       :param.transAmt,
            Key.GiftCash.authCode       :param.authCode,
        ]
        
        return params
    }
}
