//
//  EloadSubPreloading.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct EloadSubPreloadingResponse2: ResponseAPI {
    
    struct mvnoList: Codable {
        var mthRate: [mthRate]?
        var eLoad: [eLoad]?
        var notice: notice?
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
    
    struct notice: Codable {
        var noticeEnterDate: String?
        var noticeExpireDate: String?
        var noticeType: String?
        var noticeContents: String?
        var noticeSeq: String?
        var noticeTitle: String?
        var noticeUsable: String?
    }
    
    struct O_DATA: Codable {
        var mvnoList: mvnoList?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class EloadSubPreloadingRequest: RequestAPI {
    
    var opCode: String
    // "eload", "mthRate"
    
    init(opCode: String) {
        self.opCode = opCode
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.eload_sub_preloading
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                         : ani,
            Key.pinNumber                   : pinNumber,
            Key.USER_ID                     : uuid,
            Key.TELCOM                      : telecom,
            Key.APP_VER                     : appver,
            Key.LANG                        : langCode,
            Key.NOTICE_SEQ                  : noticeSeq,
            Key.opCode                      : opCode
        ]
        
        return params
    }
}

/*
 EXCEL LINE 24 ~ 39
 
 ANI        : 단말기 전화번호 없으면 NULL
 pinNumber  : 사용자 고유의 식별용 PIN 번호
 USER_ID    : 안드로이드 : GMAIL   , IOS -UUID
 TELCOM     : KT,LGT,,, 없으면 NULL
 APP_VER    : APP 버전
 LANG       : 단말기 언어 없으면 NULL
 NOTICE_SEQ : 마지막으로 확인한 공지사항
 opCode     : 선불정액 : mthRate , 이로드 : eload
 
 누락(문서에는 있음)
 MODEL      : 모델 없으면 NULL
 */
