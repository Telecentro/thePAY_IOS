//
//  AuthCtnResponse.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct AuthCtnResponse: ResponseAPI {
    struct O_DATA: Codable {
        
        struct addInfo: Codable {
            var expiredt: String?
            var balance: String?
            var rcgamt: String?
        }
        
        var expiredt: String?
        var O_CODE: String?
        var O_MSG: String?
        var balance: String?
        var databalance: String?
        var rcgtype: String?
        var mvno: String?
        var rcgamt: String?
        var addInfo: addInfo?
        var ctn: String?
        var plan: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class AuthCtnRequest: RequestAPI {
    var ctn: String
    
    init(ctn: String) {
        self.ctn = ctn
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.auth_ctn
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode      : "P",
            Key.pinNumber   : pinNumber,
            Key.AuthCtn.CTN : ctn.removeDash(),
            Key.USER_ID     : uuid,
            Key.SESSION_ID  : sessionId,
            Key.LANG        : langCode,
            Key.ANI         : ani,
            Key.TELCOM      : telecom,
            Key.MODEL       : model,
            Key.APP_VER     : appver_desc,
            Key.OS          : os_desc,
            Key.OS_LANG     : os_lang,
            Key.IMSI        : "",
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value
        ]
        
        return params
    }
}

/*
 EXCEL LINE 83 ~ 101
 
 opCode         : P : 요금제조회  , B: 잔액조회
 pinNumber      : 고객 핀 - 고객구분 유니크한 핀
 AuthCtn.CTN    : 전화번호
 USER_ID        : Android - gmail 계정,  IOS - UUID
 LANG           : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 ANI            : 문의결과를 받을 전화번호로  - 가입자 휴대폰 번호를 DEFAULT 로 한다.
 TELCOM         : KT,LGT,,, 없으면 NULL
 MODEL          : 모델 없으면 NULL
 APP_VER        : thePAY 버전
 OS             : OS  없으면 NULL
 OS_LANG        : 단말기 설정된 언어 없으면 NULL
 SESSION_ID     : session_id
 IMSI           : 서비스 식별번호 없으면 NULL
 ENC_DATE       : 암호값 사용인자로 생성시 날짜
 AES256         : 암호화 값 ( user_id + enc_date + akey )
 */
