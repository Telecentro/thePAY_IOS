//
//  UserformPre.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct UserformPreResponse: ResponseAPI {
    struct O_DATA: Codable {
        var formMsg: String?
        
        struct formList: Codable {
            var sortNo: String?
            var mvnoName: String?
            var mvnoId: String?
        }
        
        var formList: [formList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class UserformPreRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.user_form_pre
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                 : ani,
            Key.pinNumber           : pinNumber,
            Key.USER_ID             : uuid,
            Key.LANG                : langCode,
            Key.SESSION_ID          : sessionId,
            Key.ENC_DATE            : enc_date,
            Key.AES256              : aes256Value
        ]
        
        return params
    }
}

/*
 EXCEL LINE 369 ~ 379
 
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 ANI        : 전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
 */
