//
//  RcgEasyPay.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

// 간편결제로 결제하기
import Foundation

struct RechargeEasyResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargeEasyRequest: RequestAPI {
    
    struct Param {
        var rcgSeq: String
        var rcgMode: String
        var opCode: String
        var rcgType: String
        var ctn: String
        var rcgAmt: String
        var payAmt: String
        
        var easyPayAuthNum: String      // 간편결제 인증번호 6자리
        var easyPaySubSeq: String       // 선택한 간편결제 SEQ
        var limiteSeq: String           // pAppRcgEasyPayLimte 리턴받는 SEQ 값
    }
    
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.easy_pay
    }
    
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.rcgSeq      : param.rcgSeq,
            Key.rcgMode     : param.rcgMode,
            Key.opCode      : param.opCode,
            Key.rcgType     : param.rcgType,
            Key.pinNumber   : pinNumber,
            Key.CTN         : param.ctn,
            Key.ANI         : ani,
            Key.rcgAmt      : param.rcgAmt,
            Key.payAmt      : param.payAmt,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
            Key.I_ACCESS_IP : ipAddress,
            
            Key.EasyPay.easyPayAuthNum  : param.easyPayAuthNum,
            Key.EasyPay.easyPaySubSeq   : param.easyPaySubSeq,
            Key.EasyPay.limiteSeq       : param.limiteSeq,
        ]
        
        return params
    }
}
