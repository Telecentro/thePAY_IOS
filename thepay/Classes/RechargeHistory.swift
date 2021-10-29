//
//  RechargeHistory.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit


struct RechargeHistoryResponse: ResponseAPI {
    struct O_DATA: Codable {
        struct rcgList: Codable {
            var rcgAmt: String?
            var rcgCode: String?
            var rcgCtn: String?
            var rcgErrMsg: String?
            var rcgSeq: Int?
            var rcgStatus: String?
            var rcgTime: String?
            var rcgType: String?
            var rday: String?
            
        }
        var rcgTck: String?
        var rcgTpay: String?
        var rcgList: [rcgList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RechargeHistoryRequest: RequestAPI {
    
    struct Param {
        var DAY: String
        var rcgStatus: String
        var rcgType: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.recharge_history
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.CTN                         : ani,
            Key.USER_ID                     : uuid,
            Key.DAY                         : param.DAY,
            Key.rcgStatus                   : param.rcgStatus,
            Key.rcgType                     : param.rcgType,
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
        ]
        
        return params
    }
}

/*
 EXCEL LINE 313 ~ 326
 
 pinNumber  : 고객 핀 - 고객구분 유니크한 핀
 CTN        : 전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 DAY        : 기간 1, 7, 15 ,30
 rcgStatus  : 전체="", 2=성공, 5=관리자보류, 6=시스템보류, 9=실패
 rcgType    : 전체="", V:음성, D:데이터, I:국제
 
 "IN"이라는 문자열로 Deposit,
 "OUT"이라는 문자열로 Withdraw,
 "T"라는 문자열로 Trans
 
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
 */
