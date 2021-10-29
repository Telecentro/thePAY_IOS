//
//  ContactHistory.swift
//  thepay
//
//  Created by xeozin on 2020/07/28.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct ContactHistoryResponse: ResponseAPI {
    struct O_DATA: Codable {
        struct contList: Codable {
            var contGubun: String?
            var contProfile: String?
            var contType: String?
            var jortNo: Int?
            var contDay: Int?
            var contTitle: String?
            var contContens: String?
            var imageData: String?
        }
        
        var contList: [contList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class ContactHistoryRequest: RequestAPI{
    override func getAPI() -> String? {
        return API.shared.serviceURL.contact_history
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber   : pinNumber,
            Key.CTN         : ani,
            Key.USER_ID     : uuid,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
        ]
        
        return params
    }
}

/*
 EXCEL LINE 446 ~ 456
 
 pinNumber  : 고객 핀 - 고객구분 유니크한 핀
 CTN        : 전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
 */
