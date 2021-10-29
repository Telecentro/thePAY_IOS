//
//  WebViewCacheUsable.swift
//  thepay
//
//  Created by seojin on 2021/01/12.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

struct PreFindUserResponse: ResponseAPI {
    struct O_DATA: Codable {
        var pinNumber: String?
        var ANI: String?
        var SMS_FLAG: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PreFindUserRequest: RequestAPI {
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.pAppPreFindUser
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                     :ani,
            Key.USER_ID                 :uuid,
            Key.Preloading.USER_ID2     :email,
            Key.pinNumber               :pinNumber,
            Key.LANG                    :langCode,
            Key.TELCOM                  :telecom,
            Key.MODEL                   :model,
            Key.OS                      :os,
            Key.Preloading.IMEI         :localUUID,
            Key.IMSI                    :"",
            Key.APP_VER                 :appver,
            Key.NOTICE_SEQ              :noticeSeq,
            Key.Preloading.SMS_FLAG     :smsFlag,
            Key.DEVICE_TOKEN            :deviceToken,
            Key.Preloading.USER_ID_TYPE :userIdType,
            Key.Preloading.deepLink     :dynamicLink,
            Key.OS_LANG                 :os_lang
        ]
        
        return params
    }
}
