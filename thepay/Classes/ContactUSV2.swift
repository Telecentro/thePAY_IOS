//
//  ContactUSV2.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct ContactUSV2Response: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class ContactUSV2Request: RequestAPI{
    
    struct Param {
        var CTN: String
        var CONTENTS: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.contact_us_v2
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.CTN         : param.CTN,
            Key.pinNumber   : pinNumber,
            Key.ANI         : ani,
            Key.USER_ID     : uuid,
            Key.CONTENTS    : param.CONTENTS,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value
        ]
        
        return params
    }
}

/*
 EXCEL LINE 457 ~ 470
 문서에는 email이 신규 추가로 있고
 개발 통신 파라미터에는 누락
 
 pinNumber  : 고객 핀 - 고객구분 유니크한 핀
 CTN        : 전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 ANI        : 문의결과를 받을 전화번호로  - 가입자 휴대폰 번호를 DEFAULT 로 한다.
 email      : 회신받을 메일주소(안드로이드: default user_id 값으로)
 CONTENTS   : 문의글
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
*/
