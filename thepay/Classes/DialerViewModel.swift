//
//  DialViewModel.swift
//  thepay
//
//  Created by 홍서진 on 2021/05/17.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct RateMoveInfo {
    var urlString: String
    var titleString: String
}

class DialerViewModel {
    
    var db = DisposeBag()
    
    var type = BehaviorRelay<DialerType>(value: .kt)
    var balance = BehaviorRelay<String>(value: "0")
    var netError = PublishRelay<TPError>()
    var isAirplaneMode = PublishRelay<Bool>()
    var pressedNumber = BehaviorRelay<String>(value: "")
    var lastAirplaneMode = false
    
    var savedKT = UserDefaultsManager.shared.loadKTDial()
    var savedSKT = UserDefaultsManager.shared.loadSKTDial()
    var selectNation: NationItem = NationItem()
    
    // TODO: 뷰 컨트롤러 값 모델로 옮기기
    var currentType: DialerType {
        return type.value
    }
    
    init() {
        debug()
        
        setupCallTap()
        
        bind()
    }
    
    // TODO: UserDefaultManager 에 값 저장하기
    private func debug() {
        print("👩‍❤️‍💋‍👩 KT \(App.shared.pre?.O_DATA?.intBarCodeList?.ktposBarCodeList?.balance?.currency.won ?? "XXX")")
        switch App.shared.pre?.O_DATA?.intBarCodeList?.skbBarCodeList?.Current_Amt {
        case .double(let value):
            print("👩‍❤️‍💋‍👩 SKT DOUBLE \(value)")
        case .string(let value):
            print("👩‍❤️‍💋‍👩 SKT STRING \(value)")
        case .none:
            break
        }
    }
    
    private func bind() {
        type.subscribe {
            switch $0.element ?? .skt {
            case .kt:
                self.balance.accept(App.shared.pre?.O_DATA?.intBarCodeList?.ktposBarCodeList?.balance?.currency.won ?? "0".currency.won)
            case .skt:
                switch App.shared.pre?.O_DATA?.intBarCodeList?.skbBarCodeList?.Current_Amt {
                case .double(let value):
                    self.balance.accept(String(value).currency.won)
                case .string(let value):
                    self.balance.accept(value.currency.won)
                case .none:
                    break
                }
            }
        }.disposed(by: db)
        
        isAirplaneMode.subscribe { [weak self] in
            self?.lastAirplaneMode = $0.element ?? false
        }.disposed(by: db)
    }
    
    func checkNetwork() {
        if App.shared.lastConnectionError {
            isAirplaneMode.accept(true)
        } else {
            isAirplaneMode.accept(false)
        }
    }
}

extension DialerViewModel {
    
    func getServiceCode(cc: String, dial: String, isKorean: Bool) -> String {
        // KT 탭이고 KT 유심일 경우
        if currentType == .kt && PhoneUtils.isKTUSIM() {
            let s = KT(rawValue: savedKT ?? 0) ?? KT.defaultValue
            return s.telecomNumber
        }
        
        // 한국일 경우 강제 (080)
        if isKorean {
            return TELECOM.CODE_080
        }
        
        switch currentType {
        case .kt:
            let s = KT(rawValue: savedKT ?? 0) ?? KT.defaultValue
            return s.telecomNumber
        case .skt:
            let s = SKT(rawValue: savedSKT ?? 0) ?? SKT.defaultValue
            return s.telecomNumber
        }
    }
    
    func updatePressNumber(str: String) {
        self.pressedNumber.accept(pressedNumber.value + str)
    }
    
    func updateNumber(new: String) {
        self.pressedNumber.accept(new)
    }
    
    func backspace() {
        if pressedNumber.value.count > 0 {
            var o = pressedNumber.value
            o.removeLast()
            pressedNumber.accept(o)
        }
    }
    
    func setupCallTap() {
        if let callTab = App.shared.pre?.O_DATA?.SelectInternationalCallTab {
            if callTab == TELECOM.SKT_CODE {   // "193"
                type.accept(.skt)
            } else {
                type.accept(.kt)
            }
        }
    }
    
    func tapKT() {
        if currentType == .kt {
            return
        }
        type.accept(.kt)
    }
    
    func tapSKT() {
        if currentType == .skt {
            return
        }
        type.accept(.skt)
    }
    
    func clear() {
        pressedNumber.accept("")
    }
    
    func rotateNumber() {
        switch currentType {
        case .kt:
            UserDefaultsManager.shared.saveKTDial(value: (KT(rawValue: savedKT ?? 0) ?? KT.defaultValue).next)
        case .skt:
            UserDefaultsManager.shared.saveSKTDial(value: (SKT(rawValue: savedSKT ?? 0) ?? SKT.defaultValue).next)
        }
        
        savedKT = UserDefaultsManager.shared.loadKTDial()
        savedSKT = UserDefaultsManager.shared.loadSKTDial()
        
        // 화면 갱신용
        type.accept(currentType)
    }
    
    func request() {
        switch currentType {
        case .kt:
            requestKT()
        case .skt:
            requestSK()
        }
    }
    
    func getRateMoveInfo() -> RateMoveInfo {
        var urlString = ""
        var titleString = ""
        var moveLink: String?
        switch currentType {
        case .kt:
            titleString = Localized.title_activity_rates.txt
            moveLink = App.shared.pre?.O_DATA?.subMoveLinkList?[exist: 1]?.moveLink
        case .skt:
            titleString = Localized.title_activity_rates_sk.txt
            moveLink = App.shared.pre?.O_DATA?.subMoveLinkList?[exist: 2]?.moveLink
        }
        
        if let url = SegueUtils.parseSchemeWebURL(moveLink: moveLink) {
            urlString = url
        }
        
        return RateMoveInfo(urlString: urlString, titleString: titleString)
    }
    
    func requestKT() {
        let req = KtposRemainsRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<KtposRemainsResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                let d = data.O_DATA?.ktposBarCodeList?.first?.balance ?? "0"
                if self.balance.value.isEmpty {
                    self.balance.accept("0".currency.won)
                } else {
                    self.balance.accept(d.currency.won)
                }
                App.shared.pre?.O_DATA?.intBarCodeList?.ktposBarCodeList?.balance = d
            case .failure(let error):
                self.netError.accept(error)
            }
        }
    }
    
    func requestSK() {
        let req = SkbRemainsRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<SkbRemainsResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                var value = data.O_DATA?.Current_Amt
                if self.balance.value == "0.0" {
                    value = "0"
                    self.balance.accept("0".currency.won)
                } else {
                    self.balance.accept(value?.currency.won ?? "0".currency.won)
                }
                App.shared.pre?.O_DATA?.intBarCodeList?.skbBarCodeList?.Current_Amt = FlexValue.string(value ?? "0")
            case .failure(let error):
                self.netError.accept(error)
            }
        }
    }
    
    func savedInternaltionalCallISO2Code() -> String {
        if let code = UserDefaultsManager.shared.loadInternationalCallISO2() {
            return code
        } else {
            if App.shared.codeLang == .CodeLangUSA {
                return CodeLang.CodeLangKOR.countryCode
            } else {
                return App.shared.codeLang.countryCode
            }
        }
    }
    
    func updateKR() {
        selectNation.countryCode = "kr"
        selectNation.nameKr = "대한민국"
        selectNation.nameUs = "Korea"
        selectNation.nameCn = "韩国"
        selectNation.countryNumber = "82"
        selectNation.gmt = "ets/GMT+9\r"
    }
    
    func updateNation(item: NationItem) {
        selectNation.countryCode = item.countryCode
        selectNation.nameKr = item.nameKr
        selectNation.nameUs = item.nameUs
        selectNation.nameCn = item.nameCn
        selectNation.countryNumber = item.countryNumber
        selectNation.gmt = item.gmt
    }
    
}
