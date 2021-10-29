//
//  ContactUpload.swift
//  thepay
//
//  Created by xeozin on 2020/07/28.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct ContactUploadResponse: ResponseAPI {
    struct O_DATA: Codable {
        var MESSAGE_ID: String?
        var REG_DATE: Int?
        var FILE_PATH: String?
        var RESULT: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class ContactUploadRequest: RequestAPI {
    struct Param {
//        var MESSAGE_ID: String
//        var uploadFile: Data?
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.contact_upload
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.CTN                         : ani,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
//            Key.MESSAGE_ID                  : param.MESSAGE_ID,
//            Key.ContactUpload.uploadFile    : param.uploadFile ?? ""
        ] as [String : Any]
        
        return params
    }
}

/*
 EXCEL LINE 486 ~ 498
 
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 ANI        : 전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 uploadFile : multi/part
 MESSAGE_ID : array
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
 */
