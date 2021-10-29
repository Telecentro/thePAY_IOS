//
//  SMSAuth.swift
//  thepay
//
//  Created by xeozin on 2020/07/09.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct SMSAuthResponse: ResponseAPI {
    struct O_DATA: Codable {
        var sessionId: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class SMSAuthRequest: RequestAPI {
    
    var phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.sms_auth
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode      : "req",
            Key.ANI         : phoneNumber,
            Key.USER_ID     : uuid,
            Key.MODEL       : model,
            Key.LANG        : langCode,
        ]
        
        return params
    }
}

/*
 EXCEL LINE 50 ~ 66
 
 OPCODE     : req / res ( 인증 요청시 req, 인증번호 확인시 res )
 ANI        : 전화번호 인증 번호 ( 010XXXXYYYY )
 USER_ID    : Android - gmail 계정,  IOS - UUID
 MODEL      : device 모델 ( IOS : iPhone, Android : SHV-160S … )
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 
 누락(문서에는 있음)
 AUTH_CODE  : 인증번호 ( 없으면 null )
 */
