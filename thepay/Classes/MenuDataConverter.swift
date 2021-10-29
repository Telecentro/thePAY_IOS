//
//  MenuDataConverter.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/11.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation
import SPMenu

class MenuDataConverter {
    static func regularAmount(value: [SubPreloadingResponse.pps.rcgList]?) -> [SPMenuData<SubPreloadingResponse.pps.rcgList>] {
        var new: [SPMenuData<SubPreloadingResponse.pps.rcgList>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.mvnoName, data: i))
        }
        
        return new
    }
    
    static func mthRate(value: [SubPreloadingResponse.mthRate]?) -> [SPMenuData<SubPreloadingResponse.mthRate>] {
        var new: [SPMenuData<SubPreloadingResponse.mthRate>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.mvnoName, data: i))
        }
        
        return new
    }
    
    static func mthAmount(value: [SubPreloadingResponse.amounts]?) -> [SPMenuData<SubPreloadingResponse.amounts>] {
        var new: [SPMenuData<SubPreloadingResponse.amounts>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: String(i.amount ?? 0).currency.won, data: i))
        }
        
        return new
    }
    
    static func eload(value: [EloadRealResponse.item]?) -> [SPMenuData<EloadRealResponse.item>] {
        var new: [SPMenuData<EloadRealResponse.item>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.text, data: i))
        }
        
        return new
    }
    
    static func nations(value: [SubPreloadingResponse.eLoad]?) -> [SPMenuData<SubPreloadingResponse.eLoad>] {
    var new: [SPMenuData<SubPreloadingResponse.eLoad>] = []
    for i in value ?? [] {
        new.append(SPMenuData(title: i.mvnoName, imageName: "flag_\(i.countryCode ?? "0")", data: i))
    }
    
    return new
}
    
    static func cashList(value: [SubPreloadingResponse.cashList]?) -> [SPMenuData<SubPreloadingResponse.cashList>] {
        var new: [SPMenuData<SubPreloadingResponse.cashList>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.cashName, data: i))
        }
        
        return new
    }
    
    static func intlAmount(value: [SubPreloadingResponse.intl.amounts]?) -> [SPMenuData<SubPreloadingResponse.intl.amounts>] {
        var new: [SPMenuData<SubPreloadingResponse.intl.amounts>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.amount, data: i))
        }
        
        return new
    }
    
    static func intlLang(value: [SubPreloadingResponse.intl.arsLang]?) -> [SPMenuData<SubPreloadingResponse.intl.arsLang>] {
        var new: [SPMenuData<SubPreloadingResponse.intl.arsLang>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.langName, data: i))
        }
        
        return new
    }
    
    static func period(value: [UserformPreResponse.O_DATA.formList]?) -> [SPMenuData<UserformPreResponse.O_DATA.formList>] {
        var new: [SPMenuData<UserformPreResponse.O_DATA.formList>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.mvnoName, data: i))
        }
        
        return new
    }
    
    static func withdraw(value: [WithdrawalCheckResponse.O_DATA.withdraw]?) -> [SPMenuData<WithdrawalCheckResponse.O_DATA.withdraw>] {
        var new: [SPMenuData<WithdrawalCheckResponse.O_DATA.withdraw>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.withDrawResaon, data: i))
        }
        
        return new
    }
    
    static func bank(value: [SubPreloadingResponse.bankList]?) -> [SPMenuData<SubPreloadingResponse.bankList>] {
        var new: [SPMenuData<SubPreloadingResponse.bankList>] = []
        for i in value ?? [] {
            new.append(SPMenuData(title: i.bankNameKr, imageName: i.imgNm, data: i))
        }
        
        return new
    }
}
