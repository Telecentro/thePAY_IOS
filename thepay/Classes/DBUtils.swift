//
//  SaveUtils.swift
//  thepay
//
//  Created by seojin on 2020/12/11.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import Foundation

enum SaveDBType: String {
    case recharge   = "R"
    case call       = "C"
    case eload      = "E"
}

extension Utils {
    static func saveRechargeNumber(ctn: String) {
        Utils.saveAutoCompleteNumber(
            saveType: .recharge,
            code: Tel.kr,      // 지역코드 kr
            mvno: Tel.kr_mvno, // 지역번호 82
            type: ACType.num,    // num
            text: ctn,         // 전화번호
            cate: Tel.paid)    // item_paid
    }
    
    static func saveCalledNumber(ctn: String, code: String, mvno: String, inter: String) {
        Utils.saveAutoCompleteNumber(
            saveType: .call,
            code: code,        // 지역코드
            mvno: mvno,        // 지역번호
            type: ACType.num,    // num
            text: ctn,         // 전화번호
            cate: Tel.call,
            inter: inter)    // item_call
    }
    
    static func saveEloadNumber(ctn: String, code: String, mvno: String, type: String, cate: String) {
        Utils.saveAutoCompleteNumber(
            saveType: .eload,
            code: code,
            mvno: mvno,
            type: type,
            text: ctn,
            cate: cate)
    }
    
    /**
     *  code : countryCode
     *  mvno : countryNum (778 like%)
     */
    // saveType 제거 -> saveType / callDate 추가
    static func saveAutoCompleteNumber(saveType: SaveDBType, code: String, mvno: String, type: String, text: String, cate: String = "", inter: String = "", name: String = "") {
        let item = AutoCompleteItem()
        item.code = code
        item.mvno = mvno
        item.name = name
        item.type = type
        item.text = text
        item.date = Utils.generateCurrentTimeStamp()
        item.cate = cate
        item.inter = inter
        
        switch saveType {
        case .recharge:
            item.save = "R"
        case .call:
            item.save = "C"
        case .eload:
            item.save = "E"
        }
        
        if !Utils.updateBlankItem(item: item) {
            Utils.upsert(item: item)
        }
    }
    
    static func updateBlankItem(item: AutoCompleteItem) -> Bool {
        let blankDic = [AutoCompleteDBColumn.type():item.type,
                        AutoCompleteDBColumn.country_NUMBER():"",
                        AutoCompleteDBColumn.text():item.text]
        
        if let blankItem = DBListManager.getAutoCompleteList(blankDic) as? [AutoCompleteItem] {
            // 레거시 아이템 복사
            if blankItem.count > 0 {
                DBListManager.updateAutoCompleteList(item, andWhere: blankDic)
                return true
            }
        }
        
        return false
    }
    
    static func upsert(item: AutoCompleteItem) {
        let whereDic = Utils.getWhereDic(item: item)
        let saveType = SaveDBType(rawValue: item.save)
        let list = DBListManager.getAutoCompleteList(whereDic) as! [AutoCompleteItem]
        if list.count > 0 {
            let oldItem = list[0]
            switch saveType {
            case .eload, .recharge:
                // 이로드에서 연락처, 또는 최근 전화 수정시 (날짜만 수정)
                if oldItem.cate == Tel.call
                    || oldItem.cate == Tel.paid {
                    Utils.updateTime(item: oldItem, whereDic: whereDic)
                } else {
                    DBListManager.updateAutoCompleteList(item, andWhere: whereDic)
                }
            case .call:
                DBListManager.updateAutoCompleteList(item, andWhere: whereDic)
            case .none:
                break
            }
        } else {
            // 국제전화, 충전 타입 일때 이로드 내에서 다시 검색 후 업데이트
            if item.cate == Tel.call
                || item.cate == Tel.paid {
                Utils.updateEload(item: item)
            } else {
                DBListManager.addAutoComplete(item)
            }
        }
    }
    
    static func updateEload(item: AutoCompleteItem) {
        var eDic = [AutoCompleteDBColumn.text():item.text]
        eDic.updateValue(item.type, forKey: AutoCompleteDBColumn.type())
        eDic.updateValue(item.code, forKey: AutoCompleteDBColumn.country_CODE())
        if let eList = DBListManager.getAutoCompleteList(eDic) as? [AutoCompleteItem] {
            if eList.count > 0 {
                let oldItem = eList[0]
                if oldItem.cate == Tel.call {
                    Utils.updateTime(item: oldItem, whereDic: eDic)
                } else {
                    DBListManager.updateAutoCompleteList(item, andWhere: eDic)
                }
            } else {
                DBListManager.addAutoComplete(item)
            }
        }
    }
    
    /**
     *  시간만 업데이트
     */
    static func updateTime(item: AutoCompleteItem, whereDic: [String: String]) {
        item.date = Utils.generateCurrentTimeStamp()
        DBListManager.updateAutoCompleteList(item, andWhere: whereDic)
    }
    
    /**
     *  조회 조건 가져오기
     */
    static func getWhereDic(item: AutoCompleteItem) -> [String: String] {
        var whereDic = [AutoCompleteDBColumn.text():item.text]
        let saveType = SaveDBType(rawValue: item.save)
        switch saveType {
        case .recharge, .call:
            whereDic.updateValue(item.type, forKey: AutoCompleteDBColumn.type())
            whereDic.updateValue(item.code, forKey: AutoCompleteDBColumn.country_CODE())
            if !item.cate.isEmpty {
                whereDic.updateValue(item.cate, forKey: AutoCompleteDBColumn.cate())
            }
        case .eload:    // 텍스트, 타입이 같으면 저장 (id 경우 국가 구분)
            whereDic.updateValue(item.type, forKey: AutoCompleteDBColumn.type())
            if item.type != ACType.email {
                whereDic.updateValue(item.code, forKey: AutoCompleteDBColumn.country_CODE())
            }
        case .none:
            break
        }
        
        // 이름이 비여 있지 않으면 조회 지금은 모두 ("")
        if !item.name.isEmpty {
            whereDic.updateValue(item.name, forKey: AutoCompleteDBColumn.name())
        }
        
        return whereDic
    }
    
    /**
     *  전화번호 리스트
     */
    static func getCallHistory() -> [CallHistoryItem] {
//        let items = Utils.getTypeCateHistory(type: ACType.num, cate: Tel.call)
        let items = Utils.getTypeHistory(type: ACType.num)
        
        return items.filter({ item -> Bool in
            if item.code == "" {
                return false
            }
            return !item.isNotValidTextItem()
        }).map({ item -> CallHistoryItem in
            let new = CallHistoryItem()
            new.callNumber = item.text
            new.countryCode = item.code
            new.countryNumber = item.mvno
            new.interNumber = item.inter
            new.date = item.date
            new.name = ""
            return new
        }).reversed()
    }
    
    /**
     *  충전 리스트
     */
    static func getRechargeHistory(type: String, code: String) -> [CallHistoryItem] {
        let items = Utils.getTypeCodeHistory(type: type, code: code)
        return items.filter({ item -> Bool in
            if item.type == type && item.code == code {
                if !item.isNotValidTextItem() {
                    if item.text.hasPrefix("010") && item.text.count == 11 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        }).map({ item -> CallHistoryItem in
            let new = CallHistoryItem()
            new.callNumber = item.text
            new.countryCode = item.code
            new.countryNumber = item.mvno
            new.date = item.date
            new.name = ""
            return new
        }).reversed()
    }
    
    /**
     *  이로드 리스트
     */
    static func getEloadHistory(type: String, code: String) -> [CallHistoryItem] {
        var items:[AutoCompleteItem] = []
        
        switch type {
        case ACType.email:
            items = Utils.getAllEmailHistory()
        default:
            items = Utils.getTypeCodeHistory(type: type, code: code)
            items.append(contentsOf: getBlankCodeHistory(type: type))
        }
        
        return items.filter({ item -> Bool in
            return !item.isNotValidTextItem()
        }).map({ item -> CallHistoryItem in
            let new = CallHistoryItem()
            new.callNumber = item.text
            new.countryCode = item.code
            new.countryNumber = item.mvno
            new.date = item.date
            new.name = ""
            return new
        }).reversed()
    }
    
    /**
     *  자동완성 리스트
     */
    static func getAutoCompleteHistory(type: String, code: String) -> [AutoCompleteItem] {
        var items:[AutoCompleteItem] = []
        
        switch type {
        case ACType.email:
            items = Utils.getAllEmailHistory()
        default:
            items = Utils.getTypeCodeHistory(type: type, code: code)
            items.append(contentsOf: getBlankCodeHistory(type: type))
        }
        
        return items.filter({ item -> Bool in
            return !item.isNotValidTextItem()
        }).sorted { (lhs: AutoCompleteItem, rhs: AutoCompleteItem) -> Bool in
            return lhs.date > rhs.date
        }
    }
    
    static func getAllEmailHistory() -> [AutoCompleteItem] {
        let dic = [AutoCompleteDBColumn.type():ACType.email]
        return DBListManager.getAutoCompleteList(dic) as! [AutoCompleteItem]
    }
    
    static func getBlankCodeHistory(type: String) -> [AutoCompleteItem] {
        let dic = [
            AutoCompleteDBColumn.type():type,
            AutoCompleteDBColumn.country_CODE():""
        ]
        return DBListManager.getAutoCompleteList(dic) as! [AutoCompleteItem]
    }
    
    static func getTypeHistory(type: String) -> [AutoCompleteItem] {
        let dic = [
            AutoCompleteDBColumn.type():type
        ]
        return DBListManager.getAutoCompleteList(dic) as! [AutoCompleteItem]
    }
    
    static func getTypeCodeHistory(type: String, code: String) -> [AutoCompleteItem] {
        let dic = [
            AutoCompleteDBColumn.type():type,
            AutoCompleteDBColumn.country_CODE():code
        ]
        return DBListManager.getAutoCompleteList(dic) as! [AutoCompleteItem]
    }
    
    static func getTypeCateHistory(type: String, cate: String) -> [AutoCompleteItem] {
        let dic = [
            AutoCompleteDBColumn.type():type,
            AutoCompleteDBColumn.cate():cate
        ]
        return DBListManager.getAutoCompleteList(dic) as! [AutoCompleteItem]
    }
    
    static func getDuplateItem(text: String, type: String, code: String) -> [AutoCompleteItem] {
        let dic = [
            AutoCompleteDBColumn.text():text,
            AutoCompleteDBColumn.type():type,
            AutoCompleteDBColumn.country_CODE():code
        ]
        return DBListManager.getAutoCompleteList(dic) as! [AutoCompleteItem]
    }
}
