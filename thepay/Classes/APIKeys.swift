//
//  APIKeys.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

struct Key {
    static let opCode           = "opCode"
    static let ANI              = "ANI"
    static let USER_ID          = "USER_ID"
    static let MODEL            = "MODEL"
    static let LANG             = "LANG"
    static let pinNumber        = "pinNumber"
    static let SESSION_ID       = "SESSION_ID"
    static let NOTICE_SEQ       = "NOTICE_SEQ"
    static let TELCOM           = "TELCOM"
    static let APP_VER          = "APP_VER"
    static let OS               = "OS"
    static let OS_LANG          = "osLang"
    static let ENC_DATE         = "ENC_DATE"
    static let AES256           = "AES256"
    static let IMSI             = "IMSI"
    static let mvnoId           = "mvnoId"
    static let CTN              = "CTN"
    static let rcgType          = "rcgType"
    static let rcgAmt           = "rcgAmt"
    static let payAmt           = "payAmt"
    static let rcgSeq           = "rcgSeq"
    static let appType          = "appType"
    static let CREDIT_BILL_TYPE = "CREDIT_BILL_TYPE"
    static let ORDERNUM         = "ORDERNUM"
    static let PG_ID            = "PG_ID"
    static let noticeContents   = "noticeContents"
    static let rcgMode          = "rcgMode"
    static let cardNum          = "cardNum"
    static let CARDNUM          = "CARDNUM"
    static let cardExpireYY     = "cardExpireYY"
    static let cardExpireMM     = "cardExpireMM"
    static let cardPsswd        = "cardPsswd"
    static let userSecureNum    = "userSecureNum"
    static let DAY              = "DAY"
    static let IO               = "IO"
    static let userCash         = "userCash"
    static let userPoint        = "userPoint"
    static let email            = "email"
    static let MESSAGE_ID       = "MESSAGE_ID"
    static let DEVICE_TOKEN     = "DEVICE_TOKEN"
    static let rcgStatus        = "rcgStatus"
    static let CONTENTS         = "CONTENTS"
    static let alarmFlag        = "alarmFlag"
    static let I_ACCESS_IP      = "ACCESS_IP"
    
    struct Preloading {
        static let USER_ID2     = "USER_ID2"
        static let IMEI         = "IMEI"
        static let SMS_FLAG     = "SMS_FLAG"
        
        static let USER_ID_TYPE = "USER_ID_TYPE"
        static let deepLink     = "deepLink"
        
        static let ANI2         = "ANI2"
        static let SESSION_ID   = "SESSION_ID"
        static let SMS_SESSION_ID   = "SMS_SESSION_ID"
        
        static let ram          = "ram"
        static let disk         = "disk"
        static let rooting      = "rooting"
    }
    
    struct WebViewCacheUsable {
        static let DATA_VER     = "DATA_VER"
    }
    
    struct SMSAuth { }
    
    struct SMSAuthConfirm {
        static let AUTH_CODE    = "AUTH_CODE"
        
    }

    struct EloadReal {
        static let prodItem     = "prodItem"
    }
    
    struct AuthCtn {
        static let CTN          = "CTN"
    }
    
    struct ExchangeRate {
        static let countryCode  = "countryCode"
        static let amount       = "amount"
        static let cost         = "cost"
    }
    
    struct RcgCardLimiteV3 {
        static let O_CREDIT_BILL_TYPE   = "O_CREDIT_BILL_TYPE"
    }
    
    struct RcgEloadV3 {
        static let itemId = "itemId"
    }
    
    struct KtposRemains {
        static let GOODS_ID     = "GOODS_ID"
    }
    
    struct SkbRemains {
        static let Control_No   = "Control_No"
    }
    
    struct RechargePreview {
        static let mvnoId       = "mvnoId"
    }
    
    struct RechargeCreditV2 {
        static let cardCvc      = "cardCvc"
        static let cardName     = "cardName"
        static let limiteSeq    = "limiteSeq"
    }
    
    struct ChangeAccount {
        static let bankCd       = "bankCd"
    }

    struct ContactUpload {
        static let uploadFile   = "uploadFile"
    }
    
    struct PushReview {
        static let push_seq     = "push_seq"
    }
    
    struct UserFormStore {
        static let CARDNUM_APP = "CARDNUM_APP"
    }
    
    struct EasyPay {
        static let easyPayAuthNum   = "easyPayAuthNum"
        static let easyPaySubSeq    = "easyPaySubSeq"
        static let limiteSeq        = "limiteSeq"
        static var easyPayStep      = "easyPayStep"
        
        static var acctBankCd       = "acctBankCd"
        static var acctBankNum      = "acctBankNum"
        static var acctHolder       = "acctHolder"
        static var acctSocileId     = "acctSocileId"
        static var acctAuthCd       = "acctAuthCd"
    }
    
    struct GiftCash {
        static var transSeq         = "transSeq"
        static var transNm          = "transNm"
        static var transTo          = "transTo"
        static var transAmt         = "transAmt"
        static var authCode         = "authCode"
    }
    
    struct Withdrawal {
        static var withDrawResaon   = "withDrawResaon"
    }
}
