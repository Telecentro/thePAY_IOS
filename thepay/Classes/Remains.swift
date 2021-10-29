//
//  Remains.swift
//  thepay
//
//  Created by xeozin on 2020/07/23.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct RemainsResponse: ResponseAPI {
    struct O_DATA: Codable {
        var bankCode: String?
        var virAccountId: String?
        var imgNm: String?
        var pinNumber: String?
        var cash: Int?
        var point: Int?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RemainsRequest: RequestAPI {
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.remains
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI         : ani,
            Key.pinNumber   : pinNumber,
            Key.USER_ID     : uuid,
            Key.SESSION_ID  : sessionId,
            Key.LANG        : langCode,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value
        ]
        
        return params
    }
}

// 01071217767
// 4x658vhrnte3r1p5
// 947849109063702
// USA
// 1h12vt065qfjbzu103zeh3wniqu158i5
// 20200723163647
// 5/pgtRWnwAB6A6HvB5v0WLM5X7f9K3Fz1UaS5Qu0rio=

/*
 EXCEL LINE 67 ~ 82
 
 ANI        : 전화번호
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 SESSION_ID : session_id
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 eDate      : 암호값 사용인자로 생성시 날짜  ( yyyyMMddHHmmss )
 AES256     : 암호화 값 ( pinNumber + enc_date + akey )
 */
