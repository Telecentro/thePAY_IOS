//
//  RcgFailNote.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum NoteVisible : String {
    case n = "n"
    case y = "y"
}

enum NoteSize: String {
    case f = "f"
    case a = "a"
}

enum NoteType: String {
    case web = "web"
    case text = "text"
}

struct RcgFailNoteResponse: ResponseAPI {
    struct O_DATA: Codable {
        var noteVisible: String?
        var noteTitle: String?
        var noteType: String?
        var noteContents: String?
        var noteSeq: Int?
        var noteSize: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RcgFailNoteRequest: RequestAPI {
    
    struct Param {
        var ctn: String
        var rcgSeq: String
        var langCode: String
    }
    
    var param:Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.rcg_fail_note
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.CTN                         : param.ctn,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : param.langCode,
            Key.rcgSeq                      : param.rcgSeq,   // [sendData RCG_SEQ]
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
        ]
        
        return params
    }
    
    // 히스토리내역 임시
    func getParam2() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.CTN                         : param.ctn,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : param.langCode,
            "RCG_SEQ"                       : param.rcgSeq,   // [sendData RCG_SEQ]
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
        ]
        
        return params
    }
}

/*
 EXCEL LINE 327 ~338
 
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 CTN        : 충전전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 RCG_SEQ    : 선불폰충전에서 호출할때는 NULL , 충전내역에서 호출할때는 충전 SEQ 값을
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
 */
