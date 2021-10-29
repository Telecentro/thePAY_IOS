//
//  PreCheck.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/16.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct GiftTransCheckResponse: ResponseAPI {
    struct O_DATA: Codable {
        var transNm: String?       // 송금자명
        var transTo: String?       // 송금대상자 (전화번호,이메일주소)
        var transDt: String?       // 송금요청날짜
        var transAmt: String?
        
        /*
         0 : 없음 , 1 : 진행(한건)
         0일때  전체 초기 셑팅
         1 : 리턴값 화면 셑팅

         서버 내부 : 2 : 송금 완료. 9 : 송금실패또는 폐기
         */
        var transStatus: String?
        var authStatus: String?    // 0 :  인증확인 전  , 1 : 인증확인 완료.
        var authCode: String?      // 1:인경우 인증했던 코드값 리턴 0:인경우 null
        var authTime: String?      // 0: 인경우 timer 처리 1 : 경우 null
        var cash: Int?           // 고객이 잔액 cash
        var transSeq: String?      // trans_status : 1 인경우는 필수 리턴값 그외는 null
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class GiftTransCheckRequest: RequestAPI {
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.gift_trans_check
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber               :pinNumber,
            Key.ANI                     :ani,
            Key.USER_ID                 :uuid,
            Key.LANG                    :langCode,
            Key.SESSION_ID              :sessionId,
            Key.ENC_DATE                :enc_date,
            Key.AES256                  :aes256Value,
            Key.I_ACCESS_IP             :ipAddress
        ]
        
        return params
    }
}
