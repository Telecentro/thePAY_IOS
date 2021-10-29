//
//  PreCheck.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/16.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct PreCheckResponse: ResponseAPI {
    struct O_DATA: Codable {
        var loginList:[loginList]?
    }
    
    struct loginList: Codable {
        var sortNo: String?
        var loginCode: String?
        var loginTitle: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PreCheckRequest: RequestAPI {
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.precheck
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
            Key.OS_LANG                 :os_lang,
            Key.Preloading.ram          :freeMemory,
            Key.Preloading.disk         :freeDisk,
            Key.Preloading.rooting      :isRooting,
            Key.I_ACCESS_IP             :ipAddress
        ]
        
        return params
    }
}
