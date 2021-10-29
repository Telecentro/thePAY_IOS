//
//  EloadDynamicResponse.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

//struct EloadDynamicResponse: ResponseAPI {
//    
//    struct O_DATA: Codable {
//        // NO DATA
//    }
//    
//    var O_DATA: O_DATA?
//    var O_CODE: String
//    var O_MSG: String
//}

class EloadDynamicRequest: RequestAPI {
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.eload_dynamic
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                 : ani,
            Key.pinNumber           : pinNumber,
            Key.USER_ID             : uuid,
            Key.SESSION_ID          : sessionId,
            Key.TELCOM              : telecom,
            Key.LANG                : langCode,
            Key.APP_VER             : appver_desc,
            Key.OS                  : os_desc,
            Key.ENC_DATE            : enc_date,
            Key.AES256              : aes256Value
        ]
        
        return params
    }
}

//AES256 = "Cx+vhC/fwdhhhzyStDuoc5XFBddHup07zah88/5WQww=";
//ANI = 01071217767;
//"APP_VER" = "thePAY@1.6.6";
//"ENC_DATE" = 20200819203005;
//LANG = USA;
//OS = "ios@13.1.3";
//"SESSION_ID" = ax2y95xhq1woqd1xewdbfsjerrlsso44;
//TELCOM = SKTelecom;
//"USER_ID" = "DE79B7D9-4CB8-4211-A303-822789CDD6BE";
//pinNumber = uzo8cm6rs8qi1lj3;

//["LANG": "USA", "SESSION_ID": "w9rme2n1brl8z2nbf1uudtmtepof97z8", "ENC_DATE": "20200819204109", "AES256": "AKMhwKty+PwUsNXxph+doeOcU+JL4OM60WxlVKPhmOg=", "USER_ID": "101123539173263704412", "OS": "ios@13.1.3", "APP_VER": "thePAY@1.0", "TELCOM": "SK Telecom", "pinNumber": "z65ntd7kffokqspo", "ANI": "01071217767"]

/*
 EXCEL LINE 144 ~ 161
 
 ANI        : 전화번호
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 USER_ID    : Android - gmail 계정,  IOS - UUID
 SESSION_ID : session_id
 TELCOM     :
 LANG       : 앱 설정된  사용자 언어 ( 최초 실행은 앱 OS 언어, Default KOR )
 APP_VER    :
 OS         :
 ENC_DATE   : 암호값 사용인자로 생성시 날짜
 AES256     : 암호화 값 ( user_id + enc_date + akey )
 
 누락
 viewtype   : spinner , textedit ,,,  구분
 mvnoId     : 977,9981  mvno 사 아이디 값
 merchantId : 현지 통신사 명 또는 코드값
 regionId   : 지역코드값
 subMod     :
 apiKey     :
 searchKey  :
 */
