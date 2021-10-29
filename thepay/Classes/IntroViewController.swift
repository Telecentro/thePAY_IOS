//
//  IntroViewController.swift
//  thepay
//
//  Created by xeozin on 2020/06/26.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

enum Update: String {
    case ignore = "0"   // 업데이트 안함
    case soft   = "1"     // 업데이트 권장
    case hard   = "2"     // 업데이트 강제
}

enum IntroStatus {
    case lang
    case first
    case update
}

class IntroViewController: TPBaseViewController {
    @IBOutlet weak var lblVersion: TPLabel!
    var nations: [NationItem]?
    var update: Update = .ignore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createNationDBData()
        self.lblVersion.text = Utils.ver
    }
    
    private func createNationDBData() {
        if !DBListManager.isTable(NationDBColumn.table_NAME()) {
            DBListManager.createNationTable()
        } else {
            if DBListManager.deleteTable(NationDBColumn.table_NAME()) {
                DBListManager.createNationTable()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(type: .fullScreen)
        self.migrationDatabase()
    }
    
    private func next() {
        if App.shared.selectedServer {
            considerToNext()
        } else {
            switch App.shared.debug {
            case .hard:
                self.performSegue(withIdentifier: "Debug", sender: nil)
            case .soft:
                API.shared.serviceURL = .dev
                considerToNext()
            case .none:
                API.shared.serviceURL = .real
                considerToNext()
            }
            
        }
    }
    
    private func drawDebugLabel() {
        if API.shared.serviceURL != .real {
            guard let win = UIWindow.key else { return }
            let debugLabel = UILabel()
            debugLabel.text = "[DEBUG] / [IP: \(API.shared.serviceURL.baseURLName)] / [\(Utils.version ?? "X")] / [Pre: \(PreloadingRequest().ver.name)]"
            debugLabel.textAlignment = .center
            debugLabel.backgroundColor = UIColor(named: "Primary") ?? .red
            debugLabel.textColor = .white
            debugLabel.font = UIFont.boldSystemFont(ofSize: 10)
            
            win.addSubview(debugLabel)
            
            debugLabel.snp.makeConstraints { snp in
                snp.bottom.equalTo(win.snp.bottom)
                snp.leading.equalTo(win.snp.leading)
                snp.trailing.equalTo(win.snp.trailing)
            }
        }
    }
    
    private func loadWebCache() {
        if App.shared.webCache == .cached {
            if let vc = Link.webview.viewController {
                vc.view.alpha = 0
                self.view.addSubview(vc.view)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? LangViewController {
            vc.selectLangType = .first
        }
    }
    
    func considerToNext() {
        // TODO: 네트워크 체크
        self.resetSideMenu()
        
        let isJoined = UserDefaultsManager.shared.isJoined()
        
        switch isJoined {
        case true:
            print("로그인")
            self.requestAPI()
        case false:
            print("비로그인")
            let confirmedPermission = UserDefaultsManager.shared.loadPermisionConfirm()
            if confirmedPermission {
                /* LOAD LOCALIZED LANGUAGE BUNDLE */
                if App.shared.bundle == nil {
                    let langCode = UserDefaultsManager.shared.loadNationCode()
                    App.shared.generateBundle(lang: langCode)
                }
                SegueUtils.openMenu(target: self, link: .terms)
            } else {
                LanguageUtils.saveLanguage(lang: .CodeLangUSA)
                SegueUtils.openMenu(target: self, link: .lang)
            }
            
        }
        
        drawDebugLabel()
    }
    
    func requestAPI() {
        switch App.shared.intro {
        case .first:
            self.showLoadingWindow()
        case .lang:
            self.showLoadingWindow()
        case .update:
            self.showLoadingWindow()
        }
        
        let req = PreloadingRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<PreloadingResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                
                App.shared.pre = data
                
                UserDefaultsManager.shared.saveSessionID(value: data.O_DATA?.sessionId)
                UserDefaultsManager.shared.saveAES256Key(value: data.O_DATA?.aKey)
                UserDefaultsManager.shared.saveMyPinNumber(value: data.O_DATA?.pinNumber)
                UserDefaultsManager.shared.saveEncDate(value: Utils.generateCurrentTimeStamp())
                UserDefaultsManager.shared.saveContactPhone(value: data.O_DATA?.contactPhone)
                UserDefaultsManager.shared.saveContactTitle(value: data.O_DATA?.contactTitle)
                UserDefaultsManager.shared.saveContactProfile(value: data.O_DATA?.contactProfile)
                UserDefaultsManager.shared.saveloadInternationalTap(value: data.O_DATA?.isVisibleOpenInternationalCallTab)
                UserDefaultsManager.shared.saveCreditBillType(value: data.O_DATA?.O_CREDIT_BILL_TYPE)
                UserDefaultsManager.shared.saveSelectInterCallTab(value: data.O_DATA?.SelectInternationalCallTab)
                
                self.checkUpdate(flag: data.O_DATA?.isUpdate)
                
                self.hideLoadingWindow()
                
            case .failure(let error):
                self.hideLoadingWindow()
                switch error {
                case .retry:
                    // 추후에 대치
                    error.processError(target: self)
                    // self.retryRequestAPI()
                default:
                    error.processError(target: self)
                }
                
            }
        }
    }
    
    private func retryRequestAPI() {
        self.showCheckAlert(title: nil, message: "네트워크 재시도") {
            self.requestAPI()
        } cancel: {
            exit(0)
        }
    }
    
    private func goToMarket() {
        if let storeURL = URL(string: "https://itunes.apple.com/us/app/id1088189940") {
            UIApplication.shared.open(storeURL, options: [:]) { b in
                exit(0)
            }
        }
    }
    
    private func checkUpdate(flag: String?) {
        if let isUpdate = flag, let update = Update(rawValue: isUpdate) {
            self.update = update
            print("Update \(self.update)")
            
            switch self.update {
            case .ignore:
                SegueUtils.openMenu(target: self, link: .main)
            case .soft:
                let msg = App.shared.pre?.O_DATA?.updateMsg ?? Localized.alert_msg_update.txt
                self.showCheckHTMLAlert(title: Localized.alert_title_confirm.txt, htmlString: msg) {
                    self.goToMarket()
                } cancel: {
                    SegueUtils.openMenu(target: self, link: .main)
                }
            case .hard:
                let msg = App.shared.pre?.O_DATA?.updateMsg ?? Localized.alert_msg_update_mandatory.txt
                self.showConfirmHTMLAlert(title: Localized.alert_title_confirm.txt, htmlString: msg) {
                    self.goToMarket()
                }
            }
        } else {
            // 기타 상황
            SegueUtils.openMenu(target: self, link: .main)
        }
    }
}

extension IntroViewController {
    
    enum Mode {
        case migration
        case createDummy
    }
    
    private func migrationDatabase() {
        let mode: Mode = .migration
        
        if mode == .createDummy {
            DBListManager.deleteTable(AutoCompleteDBColumn.table_NAME())
            DummyManager.shared.createDummyData()
            DummyManager.shared.createCallDummyData()
            exit(-1)
        } else {
            destroyRechargeDatabase()
            destroyCallHistoryDatabase()
            next()
        }
    }
    
    
    private func destroyRechargeDatabase() {
        if !DBListManager.isTable(RechargeDBColumn.table_NAME()) {
            print("🥕 OLD RECHARGE HISTORY DB WAS DELETED")
            return
        } else {
            print("🥕 OLD RECHARGE HISTORY DB WAS DETECTED!")
        }
        
        nations = DBListManager.getNationList() as? [NationItem]
        let oldDB = DBListManager.getRechargeHistoryList() as! [CallHistoryItem]
        let appendItems = oldDB.filter { item -> Bool in
            if item.isNotValidNumber() {
                return false
            } else {
                return true
            }
        }.map { callItem -> AutoCompleteItem in
            let item = AutoCompleteItem()
            if let fakeItem:ContactInfo = PhoneUtils.findPrefixNationInfo(src: callItem.callNumber, nations: nations ?? []) {
                if callItem.callNumber.isNumber {
                    item.code = fakeItem.countryCode ?? ""
                    item.mvno = ""
                    item.type = ACType.num
                    item.text = fakeItem.callNumber ?? callItem.callNumber
                    item.name = ""
                    item.date = callItem.date
                    item.cate = ""
                    item.inter = ""
                    item.save = ""
                } else {
                    if callItem.callNumber.isEmail {
                        item.code = ""
                        item.mvno = ""
                        item.type = ACType.email
                        item.text = callItem.callNumber
                        item.name = ""
                        item.date = callItem.date
                        item.cate = ""
                        item.inter = ""
                        item.save = ""
                    } else {
                        item.code = ""
                        item.mvno = ""
                        item.type = ACType.id
                        item.text = callItem.callNumber
                        item.name = ""
                        item.date = callItem.date
                        item.cate = ""
                        item.inter = ""
                        item.save = ""
                    }
                }
            }
            return item
        }.filter { result -> Bool in
            if result.text.isEmpty {
                return false
            } else {
                return true
            }
        }
        
        for c in appendItems {
            print("🥕 \(c.code) \(c.mvno) \(c.type) \(c.text)")
            let item = Utils.getDuplateItem(text: c.text, type: c.type, code: c.code)
            if item.count == 0 {
                DBListManager.addAutoComplete(c)
            }
        }
        
        // 디비 삭제
        DBListManager.deleteTable(RechargeDBColumn.table_NAME())
    }
    
    private func destroyCallHistoryDatabase() {
        if !DBListManager.isTable(CallHistoryDBColumn.table_NAME()) {
            print("🥕 OLD CALL HISTORY DB WAS DELETED")
            return
        } else {
            print("🥕 OLD CALL HISTORY DB WAS DETECTED!")
        }
        
        let oldDB = DBListManager.getCallHistoryList() as! [CallHistoryItem]
        let appendItems = oldDB.filter { item -> Bool in
            if item.isNotValidCallNumber() {
                return false
            }
            
            if item.countryCode == "" {
                return false
            } else {
                return true
            }
        }.map { callItem -> AutoCompleteItem in
            let item = AutoCompleteItem()
            if callItem.callNumber.isNumber {
                item.code = callItem.countryCode
                item.mvno = callItem.countryNumber
                item.type = ACType.num
                item.text = callItem.callNumber
                item.name = ""
                item.date = callItem.date
                item.cate = Tel.call
                item.inter = callItem.interNumber
                item.save = "C"
            }
            return item
        }.filter { result -> Bool in
            if result.text.isEmpty {
                return false
            } else {
                return true
            }
        }
        
        for c in appendItems {
            print("🥕 \(c.code) \(c.mvno) \(c.type) \(c.text)")
            let item = Utils.getDuplateItem(text: c.text, type: c.type, code: c.code)
            if item.count == 0 {
                DBListManager.addAutoComplete(c)
            }
        }
        
        // 디비 삭제
        DBListManager.deleteTable(CallHistoryDBColumn.table_NAME())
    }
}
