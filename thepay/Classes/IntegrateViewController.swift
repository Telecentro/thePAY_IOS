//
//  IntegrateViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum ProdCode: String {
    case D = "D"
    case V = "V"
    case L = "L"
    
    var Value: String {
        return self.rawValue
    }
}

enum ProdType: String {
    case normal = "0"
    case special = "2"
    case data = "3"
    
    var index: Int {
        switch self {
        case .normal:
            return 0
        case .special:
            return 2
        case .data:
            return 3
        }
    }
}


enum IntegrateType: String {
    case regular = "1"
    case monthly = "2"
    
    func getMenuKey(type: ProdType? = nil) -> NavContents {
        switch self {
        case .regular:
            switch type {
            case .data:
                return .data
            default:
                return .voice
            }
        case .monthly:
            return .month
        }
    }
}

class IntegrateViewController: TPBaseViewController, TPLocalizedController {
    
    struct AuthCtnData {
        var data: AuthCtnResponse?
        var error: Error?
    }
    
    enum TestPhoneNumber {
        case monthly
        case regular
        case ani
        
        var number: String {
            switch self {
            case .monthly:
                return "010-9494-6773"  // 모빙(선불정약제) - 테스트용
                    // 010-6715-6773 (선불정약제 : 25,000)
            case .regular:
                return "010-6452-4263"  // 아이즈(선불종량제) - 테스트용
            case .ani:
                return UserDefaultsManager.shared.loadANI() ?? ""   // 실제 번호
            }
        }
    }
    
    @IBOutlet weak var btnCharge: UIButton!
    
    @IBOutlet weak var viewPrepay: UIView!
    @IBOutlet weak var viewMonth: UIView!
    
    var regularViewController: RegularViewController?
    var monthViewController: MonthlyViewController?
    
    var type: IntegrateType = .regular
    var prodType: ProdType = .normal
    var authCtnData: AuthCtnData?
    var ctn: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        self.setProductType()
        self.setTabType()
        self.updateDisplay()
        
        requestSubPreloading(opCode: .ppsAll) { (data:[Any]?) -> Void in
            self.regularViewController?.updateRegularData(data: App.shared.pps)
            self.monthViewController?.updateMonthData(data: App.shared.mthRate)
            self.requestAuthCtn()
        }
    }
    
    func localize() {
        self.setupNavigationBar(type: .basic(title: Link.integrate.title))
        
        self.btnCharge.setTitle(Localized.btn_recharge.txt, for: .normal)
    }
    
    private func hasCtn() -> Bool {
        if let cnt = self.params?.count {
            return cnt > 2
        } else {
            return false
        }
    }
    
    private func setProductType() {
        // 일반 / 데이터
        if let prodType = ProdType(rawValue: self.params?["product_type"] as? String ?? "") {
            self.prodType = prodType
        }
    }
    
    private func setTabType() {
        // 일반선불 / 월 정액
        if let type = IntegrateType(rawValue: self.params?["tab_type"] as? String ?? "") {
            self.type = type
        }
    }
    
    private func updateDisplay() {
        switch type {
        case .regular:
            self.viewPrepay.isHidden = false
            self.viewMonth.isHidden = true
            
            self.monthViewController?.view.endEditing(true)
        case .monthly:
            self.viewMonth.isHidden = false
            self.viewPrepay.isHidden = true
            
            self.regularViewController?.view.endEditing(true)
        }
        
        updateNavTitle(prodType: self.prodType)
    }
    
    public func updateNavTitle(prodType: ProdType) {
        self.prodType = prodType
        self.regularViewController?.updateButtonState(type:type, menu: type.getMenuKey(type: prodType))
        self.monthViewController?.updateButtonState(type:type, menu: type.getMenuKey(type: prodType))
    }
}

extension IntegrateViewController {
    // 충전
    @IBAction func charge(_ sender: Any) {
        switch type {
        case .regular:
            self.regularViewController?.charge()
        case .monthly:
            self.monthViewController?.charge()
        }
    }
}

extension IntegrateViewController {
    
    func requestAuthCtn() {
        self.updateForceCtn()
        if needSearchCTN() {
            switch self.type {
            case .regular:
                self.regularViewController?.invalidateAutoComplete()
            case .monthly:
                self.monthViewController?.invalidateAutoComplete()
            }
            self.showLoadingWindow()
            let req = AuthCtnRequest(ctn: getPhoneNumber())
            API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<AuthCtnResponse, TPError>) -> Void in
                guard let self = self else { return }
                switch response {
                case .success(let data):
                    self.authCtnData = AuthCtnData(data: data, error: nil)
                    self.monthViewController?.authCtnData = data    // monthly 에도 전달
                    self.updateProdDisplay()
                    self.hideLoadingWindow()
                case .failure(let error):
                    self.authCtnData = AuthCtnData(data: nil, error: error)
                    self.monthViewController?.updateUnknown()
                    self.hideLoadingWindow()
                    /* "O_DATA":{},"O_CODE":"9999","O_MSG":"선불 가입자가 아니거나 조회할 사업자 없음" */
                    // error.processError(target: self)
                }
            }
        }
    }
    
    private func getPhoneNumber() -> String {
        return self.ctn ?? TestPhoneNumber.ani.number
    }
    
    /* 선불/월정액 전화번호 동기화 */
    private func updateForceCtn() {
        let num = getPhoneNumber()
        
        switch self.type {
        case .regular:
            self.monthViewController?.tfPhone.text = Utils.format(phone: num)
        case .monthly:
            self.regularViewController?.tfPhone.text = Utils.format(phone: num)
        }
    }
    
    // (정약제 -> 종량제) or (종량제 -> 정액제) 변경 알림 팝업
    private func updateProdDisplay() {
        guard let rcgType = ProdCode(rawValue: self.authCtnData?.data?.O_DATA?.rcgtype ?? "") else { return }
        guard let plan = self.authCtnData?.data?.O_DATA?.plan else { return }
        print("💚 \(self.type) \(rcgType) \(plan)")
        
        switch self.type {
        case .regular:
            switch rcgType {
            case .L:
                if plan != "special" {
                    self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: Localized.alert_msg_normal_to_month.txt, confirm: {
                        self.type = .monthly
                        self.updateDisplay()
                        self.monthViewController?.updateCtn(data: self.authCtnData?.data)
                    }, cancel: {
                        self.regularViewController?.updateCtn(data: self.authCtnData?.data, changeProd: false)
                    })
                } else {
                    self.regularViewController?.updateCtn(data: self.authCtnData?.data)
                }
            case .V:
                if plan != "special" {
                    self.regularViewController?.updateCtn(data: self.authCtnData?.data)
                }
            default:
                if self.prodType == .data || self.prodType == .special {
                    return
                }
                self.regularViewController?.updateCtn(data: self.authCtnData?.data, changeProd: false)
            }
        case .monthly:
            switch rcgType {
            case .V:
                self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: Localized.alert_msg_month_to_normal.txt, confirm: {
                    self.type = .regular
                    self.updateDisplay()
                    self.regularViewController?.updateCtn(data: self.authCtnData?.data)
                }, cancel: {
                    self.monthViewController?.updateCtn(data: self.authCtnData?.data)
                })
            default:
                self.monthViewController?.updateCtn(data: self.authCtnData?.data)
            }
        }
    }
    
    // 파라미터가 3보다 작고 (ctn 같은 고정 정보가 없다는 의미)
    // 데이터 충전이 아닌 경우 (2020.10.08 제거)
    // 기존에 통신한 적이 없는 경우 (최초 1회만 통신)
    private func needSearchCTN() -> Bool {
//        return !hasCtn() && self.prodType != .data && self.authCtnData == nil // 2020.10.08 제거
        return !hasCtn()
    }
}

extension IntegrateViewController {
    
    // 전달받은 param 데이터를 ContainerView에 전달(복사) 한다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? RegularViewController {
            self.regularViewController = vc
            self.regularViewController?.type = self.type
            vc.changeView = {
                switch $0 {
                case .regular:
                    self.type = .regular
                    self.updateDisplay()
                case .monthly:
                    self.type = .monthly
                    self.updateDisplay()
                }
            }
            vc.title = self.title
            vc.params = self.params
        }
        
        if let vc = segue.destination as? MonthlyViewController {
            self.monthViewController = vc
            self.monthViewController?.type = self.type
            vc.changeView = {
                switch $0 {
                case .regular:
                    self.type = .regular
                    self.updateDisplay()
                case .monthly:
                    self.type = .monthly
                    self.updateDisplay()
                }
            }
            vc.title = self.title
            vc.params = self.params
        }
    }
}
