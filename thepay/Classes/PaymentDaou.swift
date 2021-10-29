//
//  PaymentDaou.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct PaymentDaouResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PaymentDaouRequest: RequestAPI {
    override func getAPI() -> String? {
        return API.shared.serviceURL.payment_daou
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.pinNumber           : pinNumber,
            Key.CTN                 : "",   // [[Utils getObject] CTN]
            Key.USER_ID             : uuid,
            Key.LANG                : langCode,
            Key.SESSION_ID          : sessionId,
            Key.ENC_DATE            : enc_date,
            Key.OS                  : "IOS",
            Key.appType             : "thePay",
            Key.ANI                 : ani,
            Key.opCode              : "",   // [[Utils getObject] OP_CODE]
            Key.rcgSeq              : "",   // [[Utils getObject] RCG_SEQ]
            Key.rcgType             : "",   // [[Utils getObject] RCG_TYPE]
            Key.rcgAmt              : "",   // [[Utils getObject] Recharge_Amount]
            Key.payAmt              : "",   // [[Utils getObject] Amount]
            Key.CREDIT_BILL_TYPE    : "",   // [[Utils getObject] O_CREDIT_BILL_TYPE]
            Key.ORDERNUM            : "",   // [[Utils getObject] ORDER_NUM]
            Key.PG_ID               : "",   // [[Utils getObject] PG_ID]
            Key.noticeContents      : ""    // mNotiContent // 분기 처리됨
        ]
        
        return params
    }
}

/*
 EXCEL LINE 284 ~ 300
 
 opCode             : "고객 CASH 에 충전시 : CASH , 선불폰 충전시 : NOTICE로 기존 API 충전에서 사용하던 opCode 값이랑 같음. view 페이지에서는 구성할 화면 분기할때 필요. "
 rcgSeq             : "pAppRcg.do 에서 리턴받은 o_rcg_seq 값 없으면 NULL"
 rcgType            : PPS : [ V=음성, D=데이터 ,E= ELOAD 충전], IC_RCG : [ I=국제 ] , P=skt let data 충전 , C = olleh wifi 판매, L = 선불정액제
 pinNumber          : 사용자 고유의 식별용 PIN 번호
 CTN                : 충전 전화번호
 USER_ID            : Android - gmail 계정,  IOS - UUID
 ANI                : 단말기 전화번호
 rcgAmt             : 충전금액
 payAmt             : "opCode : CASH 일때는 = null NOTICE 인경우는 pAppRcg 에서 필요한 결제할 needpay 금액 넘겨주면됨. 참고로 1,000 단위 이상임. "
 LANG               : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 CREDIT_BILL_TYPE   : 비인증모드 : 13 / 18(기존로직)   ,   12 :                                                   인증모드(http://61.111.2.224:7944/Pay010MobileApi/mobile_api/authCardPayment.do 호출 개발서버 작업중)
 ORDERNUM           : 12 인증모드인경우 daou , inicis 에서 사용할 주문번호
 PG_ID              : 12인경우  DAOU, INICIS 구분
 SESSION_ID         : session_id
 ENC_DATE           : 암호값 사용인자로 생성시 날짜  ( yyyyMMddHHmmss )
 AES256             : 암호화 값 ( pinNumber + enc_date + akey )
 */
