//
//  SubPreloading.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/16.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

struct SubPreloadingResponse: ResponseAPI {
    
    struct mthRate: Codable {
        var mvnoName: String?
        var sortNo: Int?
        var includeBand: String?
        var amounts: [amounts]?
        var imageDefaultUrl: String?
        var mvnoId: Int?
        var rcgType: String?
    }
    
    struct amounts: Codable {
        var amountType: Int?
        var sortNo: String?
        var amount: Int?
        var cost: Int?
        var prodName: String?
        var prodId: Int?
        var Info1: String?
        var prodType: String?
        var img1: String?
    }
    
    // pps
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
    
    struct cashList: Codable {
        var sortNo: String?
        var cashName: String?
        var amounts: String?
        var maxVal: String?
        var minVal: String?
        var hint: String?
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
    
    
    struct eLoad: Codable, Equatable {
        var mvnoName: String?
        var sortNo: String?
        var countryCode: String?
        var mvnoId: Int?
        var itemLists: [itemLists]?
        
        static func ==(left: eLoad, right: eLoad) -> Bool {
            return left.countryCode == right.countryCode && left.mvnoId == right.mvnoId
        }
    }
    
    struct itemLists: Codable, Equatable {
        var imageSelectUrl: String?
        var sortNo: String?
        var itemId: String?
        var itemName: String?
        var imageDefaultUrl: String?
        var itemFailMsg: String?
        var title: String?
        var imageSelectFlag: Int?
        var itemFailure: FlexValue?
        
        static func ==(left: itemLists, right: itemLists) -> Bool {
            return left.itemId == right.itemId && left.itemName == right.itemName
        }
    }
    
    struct snsList: Codable {
        var downloadUrl: String?
        var sortNo: Int?
        var text: String?
        var type: String?
        var url: String?
        var iconUrl: String?
    }
    
    struct mvnoList: Codable {
        var mthRate: [mthRate]?
        var pps: [pps]?
        var intl: [intl]?
        var coupon: [coupon]?
        var cashList: [cashList]?
        var bankList: [bankList]?
        var eLoad: [eLoad]?
    }
    
    struct O_DATA: Codable {
        var mvnoList: mvnoList?
        var snsList: [snsList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class SubPreloadingRequest: RequestAPI {
    
    enum OP_CODE : String {
        case ppsAll = "ppsAll"
        case intl = "intl"
        case snsList = "snsList"
        case coupon = "coupon"
        case cashList = "cashList"
        case eload = "eload"
        case bankList = "bankList"
        
        var name: String {
            return self.rawValue
        }
    }
    
    var opCode: SubPreloadingRequest.OP_CODE
    
    init(opCode: SubPreloadingRequest.OP_CODE) {
        self.opCode = opCode
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.subPreloading
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode      : opCode.name,
            Key.USER_ID     : uuid,
            Key.ANI         : ani,
            Key.pinNumber   : pinNumber,
            Key.LANG        : langCode,
            Key.TELCOM      : telecom,
            Key.APP_VER     : appver,
            Key.NOTICE_SEQ  : noticeSeq,
            Key.I_ACCESS_IP : ipAddress
        ]
        
        return params
    }
}
