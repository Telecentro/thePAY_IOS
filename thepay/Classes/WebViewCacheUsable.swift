//
//  WebViewCacheUsable.swift
//  thepay
//
//  Created by seojin on 2021/01/12.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

struct WebViewCacheUsableResponse: ResponseAPI {
    struct O_DATA: Codable {
        var webViewCacheUsable: String? // Y 스킵, N 로드
        var dataVer: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class WebViewCacheUsableRequest: RequestAPI {
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.pAppWebViewCacheUsable
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                             :ani,
            Key.USER_ID                         :uuid,
            Key.Preloading.USER_ID2             :email,
            Key.pinNumber                       :pinNumber,
            Key.LANG                            :langCode,
            Key.TELCOM                          :telecom,
            Key.MODEL                           :model,
            Key.OS                              :os,
            Key.Preloading.IMEI                 :localUUID,
            Key.IMSI                            :"",
            Key.APP_VER                         :appver,
            Key.Preloading.USER_ID_TYPE         :userIdType,
            Key.OS_LANG                         :os_lang,
            Key.WebViewCacheUsable.DATA_VER     :dataVer,
            Key.I_ACCESS_IP                     :ipAddress
        ]
        
        return params
    }
}


//IN    ANI            가입자 조회 번호
//IN    USER_ID            Android - gmail 계정,  IOS - UUID,,,
//IN    USER_ID_TYPE            현재는 GML , UUID:기존 사용하던 단말기 고유식별값 , FCB 만
//IN    USER_ID_2            안드로이드 : GMAIL , IOS -UUID
//IN    pinNumber            사용자 고유의 식별용 PIN 번호 최초 설치고객은 null 임.
//IN    LANG            단말기 언어 없으면 NULL
//
//IN    TELCOM            KT,LGT,,, 없으면 NULL
//IN    MODEL            모델 없으면 NULL
//IN    OS            OS 없으면 NULL
//IN    osLang            단말기 설정된 언어 없으면 NULL
//IN    IMEI            단말기 식별번호 없으면 NULL
//IN    IMSI            서비스 식별번호 없으면 NULL
//IN    APP_VER            APP 버전
//IN    DATA_VER            cache 버전 최초는 0 으로 시작하고 다음 호출시에는 서버에서 내려준 ver 값을 넘겨주어야 한다.
//IN    I_ACCESS_IP            접속 아이피추가
