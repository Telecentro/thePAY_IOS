//
//  App.swift
//  thepay
//
//  Created by xeozin on 2020/07/01.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import GoogleSignIn

enum DebugMode {
    case hard
    case soft
    case none
}

enum WebCache {
    case cached     // 캐쉬
    case none       // 캐쉬하지 않음
}

class App: NSObject {
    static let shared = App()
    
    var bundle: Bundle?
    var codeLang: CodeLang = .CodeLangUSA
    var intro: IntroStatus = .first
    var locale: Locale = Locale.current
    
    var debug:DebugMode = .none
    var debugResponseJSON = false
    var debugLanguageKeys = false
    var isRemainsInfoChanged = false
    var isKtposRemainsInfoChange = false
    var selectedServer = false
    var lastConnectionError = false
    var isReachable = true
    
    var animateText = true
    
    var pre: PreloadingResponse?
    
    var bankList: [SubPreloadingResponse.bankList]?
    var cashList: [SubPreloadingResponse.cashList]?
    var coupon: [SubPreloadingResponse.coupon]?
    var eLoad: [SubPreloadingResponse.eLoad]?
    var intl: [SubPreloadingResponse.intl]?
    var pps: [SubPreloadingResponse.pps]?
    var mthRate: [SubPreloadingResponse.mthRate]?
    var snsList: [SubPreloadingResponse.snsList]?
    
    var hasPushInfo = false
    var userInfo:[AnyHashable: Any]?
    var deeplink: String?
    var moveLink: String?
    
    var webCache: WebCache = .none
    
    var easyPayFlag = false
    
    func appendMvnoList(data: SubPreloadingResponse, opCode: SubPreloadingRequest.OP_CODE) {
        
        switch opCode {
        case .ppsAll:
            App.shared.mthRate = data.O_DATA?.mvnoList?.mthRate
            App.shared.pps = data.O_DATA?.mvnoList?.pps
        case .bankList:
            App.shared.bankList = data.O_DATA?.mvnoList?.bankList
        case .cashList:
            App.shared.cashList = data.O_DATA?.mvnoList?.cashList
        case .coupon:
            App.shared.coupon = data.O_DATA?.mvnoList?.coupon
        case .intl:
            App.shared.intl = data.O_DATA?.mvnoList?.intl
        case .snsList:
            App.shared.snsList = data.O_DATA?.snsList
        case .eload:
            App.shared.eLoad = data.O_DATA?.mvnoList?.eLoad
        }
    }
    
    func generateBundle(lang: String) {
        switch lang {
        case "KOR": codeLang = .CodeLangKOR
        case "USA": codeLang = .CodeLangUSA
        case "CHN": codeLang = .CodeLangCHN
        case "VNM": codeLang = .CodeLangVNM
        case "THA": codeLang = .CodeLangTHA
        case "IDN": codeLang = .CodeLangIDN
        case "MNG": codeLang = .CodeLangMNG
        case "KHM": codeLang = .CodeLangCAM
        case "UZB": codeLang = .CodeLangUZB
        case "MMR": codeLang = .CodeLangMMR
        case "LKA": codeLang = .CodeLangLKA
        case "NPL": codeLang = .CodeLangNPL
        case "RUS": codeLang = .CodeLangRUS
        case "PHL": codeLang = .CodeLangPHI
        case "BGD": codeLang = .CodeLangBGD
        case "LAO": codeLang = .CodeLangLAO
        case "PAK": codeLang = .CodeLangPAK
        case "MMY": codeLang = .CodeLangMMY
        default:
            codeLang = .CodeLangUSA
        }
        
        guard let path = Bundle.main.path(forResource: codeLang.languageCode, ofType: "lproj") else { return }
        self.bundle = Bundle.init(path: path)
        self.locale = LanguageUtils.getLocale() ?? Locale.current
    }
    
    let nations: [String: Int] = [
        "kr":82,
        "bd":880,
        "kh":855,
        "cn":86,
        "id":62,
        "jp":81,
        "kz":77,
        "kg":996,
        "la":856,
        "my":60,
        "mn":976,
        "mm":95,
        "np":977,
        "pk":92,
        "ph":63,
        "ru":7,
        "lk":94,
        "tw":886,
        "th":66,
        "us":1,
        "uz":998,
        "vn":84,
        "af":93,
        "ak":1907,
        "al":355,
        "dz":213,
        "as":1684,
        "ad":376,
        "ao":244,
        "ai":1264,
        "ag":599,
        "ar":54,
        "am":374,
        "aw":297,
        "au":61,
        "at":43,
        "az":994,
        "bs":1242,
        "bh":973,
        "bb":1246,
        "by":375,
        "be":32,
        "bz":501,
        "bj":229,
        "bm":1441,
        "bt":975,
        "bo":591,
        "bw":267,
        "br":55,
        "bn":673,
        "bg":359,
        "bf":226,
        "bi":257,
        "cm":237,
        "ca":1,
        "ky":1345,
        "cf":236,
        "td":235,
        "cl":56,
        "co":57,
        "cg":242,
        "cd":243,
        "ck":682,
        "cr":506,
        "hr":385,
        "cu":53,
        "cz":420,
        "dk":45,
        "io":246,
        "dj":253,
        "dm":1767,
        "tl":670,
        "ec":593,
        "eg":20,
        "sv":503,
        "gq":240,
        "er":291,
        "ee":372,
        "et":251,
        "fo":298,
        "fk":500,
        "fj":679,
        "fi":358,
        "fr":33,
        "ga":241,
        "gm":220,
        "ge":995,
        "de":49,
        "gh":233,
        "gi":350,
        "gr":30,
        "gl":299,
        "gd":1473,
        "gp":590,
        "gu":1671,
        "gt":502,
        "gn":224,
        "gy":592,
        "ht":509,
        "hw":1808,
        "hn":504,
        "hk":852,
        "hu":36,
        "is":354,
        "in":91,
        "ir":98,
        "iq":964,
        "ie":353,
        "il":972,
        "it":39,
        "jm":1876,
        "jo":962,
        "ke":254,
        "ki":686,
        "kw":965,
        "lv":371,
        "lb":961,
        "ls":266,
        "lr":231,
        "ly":218,
        "li":423,
        "lt":370,
        "lu":352,
        "mo":853,
        "mk":389,
        "mg":261,
        "mw":265,
        "mv":960,
        "ml":223,
        "mt":356,
        "mh":692,
        "mq":596,
        "mr":222,
        "mu":230,
        "yt":2696,
        "mx":52,
        "fm":691,
        "md":373,
        "mc":377,
        "ms":1664,
        "ma":212,
        "mz":258,
        "na":264,
        "nr":674,
        "nl":31,
        "nc":687,
        "nz":64,
        "ni":505,
        "ne":227,
        "ng":234,
        "nu":683,
        "no":47,
        "om":968,
        "pw":680,
        "ps":970,
        "pa":507,
        "pg":675,
        "py":595,
        "pe":51,
        "pl":48,
        "pt":351,
        "pr":1787,
        "qa":974,
        "ro":40,
        "rw":250,
        "sm":378,
        "sa":966,
        "sn":221,
        "rs":381,
        "me":381,
        "sc":248,
        "sl":232,
        "sg":65,
        "si":386,
        "sb":677,
        "so":252,
        "za":27,
        "es":34,
        "sh":290,
        "kn":1869,
        "lc":1758,
        "vc":1784,
        "sd":249,
        "sr":597,
        "sz":268,
        "se":46,
        "ch":41,
        "sy":963,
        "tj":992,
        "tz":255,
        "tg":228,
        "tk":690,
        "to":676,
        "tt":1868,
        "tn":216,
        "tr":90,
        "tm":993,
        "tc":1649,
        "tv":688,
        "ug":256,
        "ua":380,
        "ae":971,
        "gb":44,
        "uy":598,
        "vu":678,
        "ve":58,
        "vg":1284,
        "vi":1340,
        "wf":681,
        "ws":685,
        "ye":967,
        "zm":260,
        "zw":263,
        "cy":357
    ]
}

// Active Compilation Conditions
// DEBUG
// Other Swift Flags
// -D COCOAPODS
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
    #endif
}
