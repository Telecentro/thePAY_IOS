//
//  CashHistory.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct CashHistoryResponse: ResponseAPI {
    struct O_DATA: Codable {
        struct cashList: Codable {
            var cashType: String?
            var cashAmt: Int?
            var cashRemainAf: Int?
            var cashDay: String?
            var cashMethod: String?
            var cashTime: String?
        }
        
        var cashOck: Int?
        var cashOamt: Int?
        var cashIamt: Int?
        var cashIck: Int?
        var cashList: [cashList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

/**
 *  통신테스트 결과 이상 없음
 */
class CashHistoryRequest: RequestAPI {
    
    struct Param {
        var DAY: String
        var IO: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.cash_history
    }
    
    override func getParam() -> [String : Any]? {

        let params = [
            Key.pinNumber   : pinNumber,
            Key.CTN         : ani,
            Key.USER_ID     : uuid,
            Key.DAY         : param.DAY,
            Key.IO          : param.IO,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
        ]

        return params
    }
}

/*
 EXCEL LINE 339 ~ 351
 
 pinNumber: 고객 핀 - 고객구분 유니크한 핀
 CTN: 전화번호
 USER_ID: Android - gmail 계정,  IOS - UUID
 DAY: 기간 1 , 7, 15 ,30
 IO: I : 입금 , O : 출금
 LANG: 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 SESSION_ID: session_id
 ENC_DATE: 암호값 사용인자로 생성시 날짜
 AES256: 암호화 값 ( user_id + enc_date + akey )
 */
