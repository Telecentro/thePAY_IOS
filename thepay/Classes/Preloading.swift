//
//  Response.swift
//  thepay
//
//  Created by xeozin on 2020/07/01.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit



enum FlexValue: Codable {
    case string(String)
    case double(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(FlexValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MyValue"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        }
    }
    
    var raw: String {
        switch self {
        case .double(let d):
            return String(d)
        case .string(let s):
            return s
        }
    }
    
    var rawInt: Int {
        switch self {
        case .double(let d):
            return Int(d)
        case .string(let s):
            return Int(s) ?? 0
        }
    }
}

struct PreloadingResponse: ResponseAPI {
    
    struct intBarCodeList: Codable {
        struct skbBarCodeList: Codable {
            var mvnoName: String?
            var sortNo: Int?
            var Control_No: String?
            var Current_Amt: FlexValue?
            var mvnoId: String?
            var expireDate: String?
            var skGoodId: String?
            var Lang_Type: FlexValue?
            var barcode2: String?
            var barcode1: String?
        }
        
        struct ktposBarCodeList: Codable {
            var mvnoName: String?
            var sortNo: Int?
            var balance: String?
            var mvnoId: String?
            var ktGoodId: String?
            var expireDate: String?
            var Lang_Type: String?
            var barcode2: String?
            var cardNumber: String?
            var barcode1: String?
        }
        
        var skbBarCodeList: skbBarCodeList?
        var ktposBarCodeList: ktposBarCodeList?
    }
    
    struct mainMenuList: Codable {
        var sortNo: Int?
        var iconImg: String?
        var iconType: String?
        var moveLink: String?
        var iconUrl: String?
        var title: String?
        var content: String?
    }
    
    struct cashList: Codable {
        var sortNo: String?
        var cashName: String?
        var amounts: String?
        var maxVal: String?
        var minVal: String?
        var hint: String?
    }
    
    
    
    struct inboundChannels: Codable {
        var sortNo: Int?
        var downloadUrl: String?
        var text: String?
        var type: Int?
        var url: String?
    }
    
    struct toggleMenuList: Codable {
        var sortNo: Int?
        var iconImg: String?
        var iconType: String?
        var moveLink: String?
        var iconUrl: String?
        var title: String?
        var type: String?
        var content: String?
    }
    
    struct hotKeyList: Codable {
        var sortNo: Int? // Optional(1)
        var iconImg: String? // Optional("ic_hotkey_contactus")
        var iconType: String?
        var moveLink: String?
        var iconUrl: String?
        var title: String?
    }
    
    struct adverTise: Codable {
        var adverTitle: String?
        var adverType: String?
        var sortNo: Int?
        var adverViewType: String?
        var adverLinkUrl: String?
        var adverImgUrl: String?
    }
    
    struct ktposBarCodeList: Codable {
        var mvnoName: String?
        var balance: Int?
        var expireDate: String?
        var barcode2: String?
        var cardNumber: String?
        var barcode1: String?
    }
    
    struct creditList: Codable {
        var sortNo: String?
        var creditCode: String?
        var imgNm: String?
        var nameEn: String?
        var nameKr: String?
    }
    
    struct bankList: Codable {
        var sortNo: Int?
        var bankCode: String?
        var bankNameKr: String?
        var bankNameJp: String?
        var imgNm: String?
        var bankNameCn: String?
        var bankNameUs: String?
    }
    
    
    
    struct mvnoList: Codable {
        struct coupon: Codable {
            var mvnoName: String?
            var disOff: Int?
            var sortNo: String?
            var amount: Int?
            var price: Int?
            var mvnoId: Int?
            var rcgType: String?
            var Info1: String?
            var img1: String?
        }
        
        struct intl: Codable {
            struct arsLang: Codable {
                var sortNo: Int?
                var langName: String?
                var langCd: String?
            }
            
            struct amounts: Codable {
                var sortNo: String?
                var amount: String?
            }
            
            var arsLang: [arsLang]?
            var amounts: [amounts]?
            var mvnoId: Int?
            var mvno080: String?
            var noticeType: String?
            var noticeContents: String?
        }
        
        
        struct pps: Codable {
            struct rcgList: Codable {
                var mvnoName: String?
                var sortNo: String?
                var amounts: String?
                var mvnoId: FlexValue?
                var rcgType: String?
            }
            
            var rcgList: [rcgList]?
            var ppsId: String?
            var imageSelectUrl: String?
            var sortNo: Int?
            var imageDefaultUrl: String?
            var ppsName: String?
            var title: String?
            var imageSelectFlag: Int?
        }
        
        var coupon: [coupon]?
        var intl: [intl]?
        var pps: [pps]?
    }
    
    struct notice: Codable {
        var noticeEnterDate: String?
        var noticeExpireDate: String?
        var noticeType: String?
        var noticeContents: String?
        var noticeSeq: FlexValue?
        var noticeTitle: String?
        var noticeUsable: String?
    }
    
    struct subMoveLinkList: Codable {
        var sortNo: String?
        var moveLinkId: String?
        var moveLink: String?
    }
    
    struct O_DATA: Codable {
        var bankCode: String?
        var virAccountId: String?
        var userGuideList: [String]?
        var pinNumber: String?                              // 유저 고유 식별자
        var ktGoodId: String?
        var sessionId: String?                              // 세션 ID
        var version: String?
        var adverTise: [adverTise]?
        var point: Int?
        var creditList: [creditList]?
        var aKey: String?                                   // AES256 암호화 키
        var ktposBarCodeList: [ktposBarCodeList]?
        var isKtNewFlag: String?
        var bankList: [bankList]?
        var updateUrl: String?
        var imgNm: String?
        var rcgAmt: String?
        var contactPhone: String?
        var cash: Int?
        var isUpdate: String?
        var notice: notice?
        var mvnoList: mvnoList?
        var mainMenuList: [mainMenuList]?
        var cashList: [cashList]?
        var inboundChannels: [inboundChannels]?
        var bannerInterval: String?
        var updateMsg: String?
        var isSkNewFlag: String?
        var easyPayFlag: String?
        var toggleMenuList: [toggleMenuList]?
        var hotKeyList: [hotKeyList]?
        var intBarCodeList: intBarCodeList?
        var subMoveLinkList: [subMoveLinkList]?
        
        var contactProfile: String?
        var O_CREDIT_BILL_TYPE: String?
        var contactTitle: String?
        var O_IS_CONVENIENCE: String?
        var isVisibleOpenInternationalCallTab: String?
        var channelTalkLink: String?
        var SelectInternationalCallTab: String?
        var O_IS_SHOW_CREDIT_MENU: String?
        var isVisiableOpenMenuContactUs: String?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PreloadingRequest: RequestAPI {
    
    enum Version: String {
        case v7
        case v8
        case v9
        case v10
        case v11
        
        var name: String {
            return self.rawValue
        }
    }
    
    var ver: Version = .v11
    
    override func getAPI() -> String? {
        switch ver {
        case .v7:
            return API.shared.serviceURL.preloading_v7
        case .v8:
            return API.shared.serviceURL.preloading_v8
        case .v9:
            return API.shared.serviceURL.preloading_v9
        case .v10:
            return API.shared.serviceURL.preloading_v10
        case .v11:
            return API.shared.serviceURL.preloading_v11
        }
        
    }
    
    override func getParam() -> [String : Any]? {
        
        print("🦄 ", freeDisk, freeMemory)
        
        /* LOAD LOCALIZED LANGUAGE BUNDLE */
        if App.shared.bundle == nil {
            App.shared.generateBundle(lang: langCode)
        }
        
        var params = [
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
            Key.Preloading.rooting      :isRooting
        ]
        
        switch ver {
        case .v7:
            break
        case .v8, .v9, .v10, .v11:
            params.updateValue(ani2, forKey: Key.Preloading.ANI2)
            params.updateValue(sessionId, forKey: Key.Preloading.SESSION_ID)
            params.updateValue(sms_sessionId, forKey: Key.Preloading.SMS_SESSION_ID)
        }
        
        return params
    }
}

/*
 EXCEL API LINE 3 ~ 23
 
 ANI                        : 단말기 전화번호 없으면  sms  인증 받아서 처리
 USER_ID                    : IOS -UUID , GMAIL 아이디 , FACEBOOK 아이디 ,APPLE 아이디
 Preloading.USER_ID2        : GMAIL : GMAIL 로그인 계정 , FACEBOOK 로그인계정,APPLE 로그인계정
 pinNumber                  : 사용자 고유의 식별용 PIN 번호
 LANG                       : 단말기 언어 없으면 NULL
 TELCOM                     : 통신사 구분 KT,LGT,,, 없으면 NULL
 MODEL                      : 단말기 모델명 없으면 NULL
 OS                         : OS 버전  없으면 NULL
 Preloading.IMEI            : 단말기 식별번호 없으면 NULL
 IMEI                       : 단말기 식별번호 없으면 NULL
 IMSI                       : 단말기 식별번호 없으면 NULL
 APP_VER                    : APP 버전
 NOTICE_SEQ                 : 마지막으로 확인한 공지사항
 Preloading.SMS_FLAG        : SMS 문자 수신동의 - Y : 동의, N : 거부
 DEVICE_TOKEN               : PUSH 용 아이디
 Preloading.USER_ID_TYPE    : 현재는 GML , UUID:기존 사용하던 단말기 고유식별값 , FCB 만  ,APPLE
 Preloading.deepLink        : 외부 유입경로 표기 없으면 NULL
 OS_LANG                    : 단말기 설정 언어  kr,us…..
*/
