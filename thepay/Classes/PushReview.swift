//
//  PushReview.swift
//  thepay
//
//  Created by xeozin on 2020/07/28.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct PushReviewResponse: ResponseAPI {
    struct O_DATA: Codable {
        var msgBoxType: String?
        var version: String?
        var push_seq: Int?
        var url: String?
        var msgType: String?
        var os: String?
        var app: String?
        var image: String?
        var title: String?
        var token: String?
        var moveLink: String?
        var push_type: String?
        var content: String?
        var moveBtnTitle: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PushReviewRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.push_review
    }
    
    var seq: String?
    
    init(seq: String) {
        self.seq = seq
    }
    
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.LANG                        : langCode,
            Key.PushReview.push_seq         : seq ?? "",
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value
        ]
        
        return params
    }
}

/*
 EXCEL LINE 422 ~ 433
 
 pinNumber: 사용자 고유의 식별용 PIN 번호
 ANI: 전화번호
 USER_ID: Android - gmail 계정,  IOS - UUID
 LANG: 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 push_seq: push msg seq 값
 SESSION_ID: session_id
 ENC_DATE: 암호값 사용인자로 생성시 날짜
 AES256: 암호화 값 ( user_id + enc_date + akey )
 */
