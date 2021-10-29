//
//  UserFormStore.swift
//  thepay
//
//  Created by xeozin on 2020/07/28.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct UserFormStoreResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class UserFormStoreRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.user_form_store
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value
        ]
        
        return params
    }
}



/*
 EXCEL LINE 380 ~ 405 구 버전
 EXCEL LINE 406 ~ 421 최신 버전
 
 pinNumber: 사용자 고유의 식별용 PIN 번호
 ANI: 전화번호
 USER_ID: Android - gmail 계정,  IOS - UUID
 LANG: 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 CARDNUM: 카드번호 암호화
 CARDNUM_APP: 앱에서 스캔으로 인식한 카드번호(통계용)
 userName: 가입자 명
 userName_APP: 앱에서 스캔으로 인식한 소유자명(통계용)
 uploadFile: multi/part
 SESSION_ID: session_id
 ENC_DATE: 암호값 사용인자로 생성시 날짜
 AES256: 암호화 값 ( user_id + enc_date + akey )
 */
