//
//  RcgCardLimiteV3.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct RcgCardLimiteV3Response: ResponseAPI {
    struct O_DATA: Codable {
        var rcgCardContents: String?
        var rcgCardTitle: String?
        var rcgCardType: String?
        var vRetCd: String?
        var limiteSeq: String?
        var rcgCardUsable: String?
        var O_CREDIT_BILL_TYPE: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class RcgCardLimiteV3Request: RequestAPI {
    
    struct Param {
        var cardNum: String
        var cardExpireYY: String
        var cardExpireMM: String
        var cardPsswd: String
        var userSecureNum: String
        var rcgAmt: String
        var payAmt: String
        var rcgType: String
        var rcgSeq: String
        var O_CREDIT_BILL_TYPE: String
        var ctn: String // 2021.07.21 추가
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.rcg_card_limte_v3
    }
    
    override func getParam() -> [String : Any]? {
        let params = [
            Key.ANI                                 : ani,
            Key.pinNumber                           : pinNumber,
            Key.USER_ID                             : uuid,
            Key.LANG                                : langCode,
            Key.CARDNUM                             : param.cardNum.encryptCard(),
            Key.cardExpireYY                        : param.cardExpireYY.encryptCard(),
            Key.cardExpireMM                        : param.cardExpireMM.encryptCard(),
            Key.cardPsswd                           : param.cardPsswd.encryptCard(),
            Key.userSecureNum                       : param.userSecureNum.encryptCard(),
            Key.rcgAmt                              : param.rcgAmt,
            Key.payAmt                              : param.payAmt,
            Key.rcgType                             : param.rcgType,
            Key.rcgSeq                              : param.rcgSeq,
            Key.RcgCardLimiteV3.O_CREDIT_BILL_TYPE  : param.O_CREDIT_BILL_TYPE,
            Key.SESSION_ID                          : sessionId,
            Key.ENC_DATE                            : enc_date,
            Key.AES256                              : aes256Value,
            Key.CTN                                 : param.ctn
        ]
        
        return params
    }
}

/*
 EXCEL LINE 238 ~ 258
 AOS는 변경 pAppRcgCardLimte_V4.do => P_APPU_RCG_CARD_LIMITE_V2
 iOS는 pAppRcgCardLimte_V3까지 있는 것으로
 
 ANI                : 충전 전화번호
 pinNumber          : 사용자 고유의 식별용 PIN 번호
 USER_ID            : Android - gmail 계정,  IOS - UUID
 LANG               : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 CARDNUM            : 카드번호 암호화
 cardExpireYY       : 만료일 년
 cardExpireMM       : 만료일 월
 cardPsswd          : 비밀번호
 userSecureNum      : 주민등록번호
 rcgAmt             : 결제금액(충전금액)
 rcgType            : Cash 충전인 경우 NULL, 나머지 V, D, C, P, I, E….
 O_CREDIT_BILL_TYPE : pAppRcg.do  --> P_APPU_RCG_REQ 에서 리턴받은값 13, 18
 SESSION_ID         : session_id
 ENC_DATE           : 암호값 사용인자로 생성시 날짜
 AES256             : 암호화 값 ( user_id + enc_date + akey )
 
 누락
 payAmt             :
 rcgSeq             : pAppRcg.do 에서 리턴받은 o_rcg_seq 값
 */
