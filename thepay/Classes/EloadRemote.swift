//
//  EloadRemoteResponse.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct EloadRemoteResponse: ResponseAPI {
    struct O_DATA: Codable {
        // NODATA
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class EloadRemoteRequest: RequestAPI {
    
    var mvnoId: String
    
    init(mvnoId: String) {
        self.mvnoId = mvnoId
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.eload_remote
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode          : "P",
            Key.pinNumber       : pinNumber,
            Key.ANI             : ani,
            Key.USER_ID         : uuid,
            Key.mvnoId          : self.mvnoId, // self.selectNationData.mvnoId
            Key.TELCOM          : telecom,
            Key.LANG            : langCode,
            Key.SESSION_ID      : sessionId,
            Key.ENC_DATE        : enc_date,
            Key.APP_VER         : appver_desc,
            Key.OS              : os_desc,
            Key.AES256          : aes256Value
        ]
        
        return params
    }
}

/*
 EXCEL LINE 162 ~ 189
 
 opCode     : P : 상품 요금제 조회  ,,,,,
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 ANI        : 전화번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 mvnoId     : 977
 TELCOM     : KT,LGT,,, 없으면 NULL
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 SESSION_ID : session_id
 ENC_DATE   : 암호값 사용인자로 생성시 날짜  ( yyyyMMddHHmmss )
 APP_VER    : thePAY 버전
 OS         : OS  없으면 NULL
 AES256     : 암호화 값 ( pinNumber + enc_date + akey )
 
 누락(문서에는 있음)
 viewtype   : spinner , edittext , text
 itemId     : 선택한 아이템…
 merchantId : 공급자
 subId      : 지역명.
 subMod     : 리턴할때 사용할 id 명nplspinnerUtilityService
 apiKey     : 리턴할때 사용할 변수명및 리턴 대상 검색조건 1
 searchKey  : 추가 검색조건이 있을경우에 사용. (검색할 전화번호)
 MODEL      : 모델 없으면 NULL
 osLang     : 단말기 설정된 언어 없으면 NULL
 */
