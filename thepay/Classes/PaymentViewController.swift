//
//  PaymentViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/22.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct PGInfo {
    var pgID: String?
    var amount: Int?
    var rechargeAmount: Int?
    var rcgSeq: String?
    var opCode: String?
    var rcgType: String?
    var ctn: String?
    var notiContent: String?
    var oderNum: String?
    var btype: String?
}

struct PayInfo {
    var payType: PayType?
    var amount: Int?
    var rechargeAmount: Int?
    var rcgSeq: String?
    var opCode: String?
    var rcgType: String?
    var ctn: String?
    var notiContent: String?
    var btype: String?
    var tabType: String = ""
}

class ProductData {
    var mvnoId: Int
    var rcgType: String
    var price: Int
    var alarmFlag: String?
    
    var ctn: String = ""
    var lang: String?
    var usedCash: String = ""
    var usedPoint: String = ""
    var amountToPay: Int = 0
    
    init(mvnoId: Int, rcgType: String, price: Int) {
        self.mvnoId = mvnoId
        self.rcgType = rcgType
        self.price = price
    }
}

struct AmountInfo: Equatable {
    var amount:Int
    var cash: String
    var point: String
    
    public static func ==(lhs: AmountInfo, rhs: AmountInfo) -> Bool {
        lhs.amount == rhs.amount && lhs.cash == rhs.cash && lhs.point == rhs.point
    }
}

protocol PaymentViewControllerDelegate {
    func validEloadCTN(isValid: Bool)
}

class PaymentViewController: TPBaseViewController {

    @IBOutlet weak var lblAmountTitle: TPLabel!
    @IBOutlet weak var lblCashTitle: TPLabel!
    @IBOutlet weak var lblPointTitle: TPLabel!
    @IBOutlet weak var lblAlarmTitle: TPLabel!
    
    @IBOutlet weak var lblPayTitle: TPLabel!
    @IBOutlet weak var lblPayDesc: TPLabel!
    
    @IBOutlet weak var lblAmount: TPLabel!
    @IBOutlet weak var lblCash: TPLabel!
    @IBOutlet weak var lblPoint: TPLabel!
    @IBOutlet weak var lblPay: TPLabel!
    
    @IBOutlet weak var viewCash: UIView!
    @IBOutlet weak var viewPoint: UIView!
    @IBOutlet weak var viewAlarm: UIView!
    @IBOutlet weak var viewCashCheck: UIView!
    @IBOutlet weak var viewPointCheck: UIView!
    @IBOutlet weak var viewAlarmCheck: UIView!
    @IBOutlet weak var btnCashCheck: UIButton!
    @IBOutlet weak var btnPointCheck: UIButton!
    @IBOutlet weak var btnAlarmCheck: UIButton!
    
    @IBOutlet weak var cashLayoutX: NSLayoutConstraint!
    @IBOutlet weak var viewCover: UIView!
    @IBOutlet weak var viewIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblAlarmCheckTitle: TPLabel!
    @IBOutlet weak var viewTopMargin: NSLayoutConstraint!
    
    var productData: ProductData?
    var paymentTitle: String?
    var isFirstLoaded: Bool = true
    var lastAmountInfo: AmountInfo = AmountInfo(amount: 0, cash: "", point: "")
    
    var delegate: PaymentViewControllerDelegate?
    
    var isEload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isEload {
            viewTopMargin.constant = 24
            self.view.backgroundColor = .clear
        } else {
            viewTopMargin.constant = 4
            self.view.backgroundColor = UIColor(named: "F7F7F7")
        }
        
        lblAmountTitle.text = Localized.recharge_amount.txt
        lblCashTitle.text = Localized.recharge_thepay_cash.txt
        lblPointTitle.text = Localized.recharge_point.txt
        lblAlarmTitle.text = Localized.recharge_alarm.txt
        lblAlarmCheckTitle.text = Localized.recharge_alarm_check_box.txt
        lblPayTitle.text = Localized.recharge_pay_amount.txt
        lblPayDesc.text = Localized.payment_min_amount.txt
        
    }
    
    func charge(ctn: String, lang: String? = nil) {
        self.productData?.ctn = ctn
        self.productData?.lang = lang
        
        self.applyMonthlyAlarm()
        
        // 최초 1회
        if !UserDefaultsManager.shared.loadCheckAuthBio() {
            self.showCheckAlert(title: "생체인증을 사용하시겠습니까?", message: "앞으로 결제를 위해 TouchID 또는 FaceID를 사용합니다. 설정메뉴에서 변경이 가능합니다.") {
                UserDefaultsManager.shared.saveAuthBio(value: true)
                self.authenticationWithBiometrics()
            } cancel: {
                UserDefaultsManager.shared.saveAuthBio(value: false)
                self.requestRcgFailNote()
            }
            
            UserDefaultsManager.shared.saveCheckAuthBio(value: true)
        } else {
            self.authenticationWithBiometrics()
        }
    }
    
    private func authenticationWithBiometrics() {
        Utils.authenticationWithBiometrics() {
            self.requestRcgFailNote()
        } errorHandler: {
            if let error = $0 {
                print(error)
            }
        }
    }
    
    func eloadCharge(addParams: [String:String]) {
        self.productData?.ctn = addParams["CTN"] ?? ""
        self.requestEloadPreview(addParams: addParams)
    }
    
    private func requestEloadPreview(addParams: [String:String]) {
        self.showLoadingWindow()
        
        guard let pData = self.productData else { return }
        let cash = self.btnCashCheck.isSelected ? pData.usedCash : "0"
        let point = self.btnPointCheck.isSelected ? pData.usedPoint : "0"
        
        let param = RechargeEloadRequest.Param(opCode: "NOTICE", rcgType: pData.rcgType, ctn: pData.ctn, mvnoId: String(pData.mvnoId), rcgAmt: String(pData.price), userCash: cash, userPoint: point, payAmt: String(pData.amountToPay))
        let req = RechargeEloadRequest(param: param)
        let newParam = req.getNewParam(addParams)
        API.shared.request(url: req.getAPI(), param: newParam) { [weak self] (response:Swift.Result<RechargePreviewResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                self?.processRechargePreview(data: data)
                self?.delegate?.validEloadCTN(isValid: true)
                self?.hideLoadingWindow()
            case .failure(let error):
                self?.hideLoadingWindow()
                if let p = self?.parent {
                    error.processError(target: p)
                }
            }
        }
    }
    
    private func calculateUseCash(cash: Int, amount: Int) -> Int {
        var useCash = cash
        if cash >= amount {
            useCash = amount
        } else {
            let diff = amount - cash
            
            if (diff < 1000) {
                useCash = amount - 1000;
            }
        }
        
        return useCash
    }
    
    func updateProductData(data: ProductData) {
        if isFirstLoaded {
            APIUtils.balanceCheck(target: self) { [weak self] in
                self?.isFirstLoaded = false
                self?.updateProduct(data: data)
            }
        } else {
            updateProduct(data: data)
        }
    }
    
    private func resetPointButtons() {
        self.btnCashCheck.isSelected = true
        self.btnPointCheck.isSelected = false
    }
    
    private func updateProduct(data: ProductData) {
        self.resetPointButtons()
        self.productData = data
        
        let cash: Int = Int(UserDefaultsManager.shared.loadMyCash() ?? "0") ?? 0
        let point: Int = Int(UserDefaultsManager.shared.loadMyPoint() ?? "0") ?? 0
        
        let useCash = self.calculateUseCash(cash: cash, amount: data.price)
        let usePoint = self.calculateUseCash(cash: point, amount: data.price)
        
        self.productData?.usedCash = String(useCash)
        self.productData?.usedPoint = String(usePoint)
        
        self.viewCash.isHidden = !(useCash > 0)
        self.viewPoint.isHidden = !(usePoint >= data.price)
        self.viewCashCheck.isHidden = self.viewPoint.isHidden
        
        if viewCashCheck.isHidden {
            cashLayoutX.constant = -32
        } else {
            cashLayoutX.constant = -10
        }
        
        let newAmountInfo = AmountInfo(amount: data.price, cash: data.usedCash, point: data.usedPoint)
        let diffAmount = self.lastAmountInfo != newAmountInfo
        if diffAmount {
            self.lblAmount.text = "￦\("\(data.price)".currency)"
            self.lblCash.text = "￦\("\(Int(data.usedCash) ?? 0)".currency)"
            self.lblPoint.text = "ⓟ\("\(Int(data.usedPoint) ?? 0)".currency)"
        }
        
        self.updatePaymentView(updateAmount: diffAmount)
        
        self.lastAmountInfo = newAmountInfo
    }
    
    private func updatePaymentView(updateAmount: Bool) {
        guard let pData = self.productData else { return }
        var changeValue = 0
        if self.btnCashCheck.isSelected {
            changeValue = Int(pData.usedCash) ?? 0
        } else if self.btnPointCheck.isSelected {
            changeValue = Int(pData.usedPoint) ?? 0
        }
        
        var amountToPay = pData.price - changeValue
        if amountToPay < 0 {
            amountToPay = 0
        }
        
        amountToPay = (amountToPay > 0 && amountToPay < 1000) ? 1000 : amountToPay
        
        self.productData?.amountToPay = amountToPay
        
        self.lblPay.text = "￦\(amountToPay.currency)"
        
        removeViewCover()
    }
    
    private func removeViewCover() {
        if self.viewCover != nil {
            if let _ = self.viewCover.superview {
                self.viewIndicator.stopAnimating()
                self.viewCover.removeFromSuperview()
            }
        }
    }
    
    /**
     *  캐시를 우선적으로 사용
     *  캐시 체크 박스를 해제 불가
     *  포인트를 선택시 캐시 해제
     *  포인트를 선택 해제시 자동으로 캐시 체크박스 선택
     */
    @IBAction func pressCheckBox(_ sender: UIButton) {
        if sender == self.btnCashCheck && self.btnCashCheck.isSelected {
            return
        }
        
        sender.isSelected = !sender.isSelected
        
        if sender == self.btnCashCheck && self.btnCashCheck.isSelected {
            self.btnPointCheck.isSelected = !self.btnCashCheck.isSelected
        }
        
        if sender == self.btnPointCheck {
            self.btnCashCheck.isSelected = !self.btnPointCheck.isSelected
        }
        
        updatePaymentView(updateAmount: true)
    }
    
    @IBAction func pressAlarmCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

// 프로세스 로직
extension PaymentViewController {
    
    // 1-1. 통신
    private func requestRcgFailNote() {
        guard let pData = self.productData else { return }
        var langCode = ""
        if let code = pData.lang {
            langCode = code
        } else {
            langCode = UserDefaultsManager.shared.loadNationCode()
        }
        
        self.showLoadingWindow()
        let param = RcgFailNoteRequest.Param(ctn: pData.ctn , rcgSeq: "", langCode: langCode)
        let req = RcgFailNoteRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RcgFailNoteResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                self?.hideLoadingWindow()
                self?.processRcgFailNote(data: data)
            case .failure(let error):
                print(error)
                self?.hideLoadingWindow()
                if let p = self?.parent {
                    error.processError(target: p)
                }
            }
        }
    }
    
    // 1-2. 프로세스
    private func processRcgFailNote(data: RcgFailNoteResponse) {
        guard let visible = NoteVisible(rawValue: data.O_DATA?.noteVisible?.lowercased() ?? "") else { return }
        switch visible {
        case .n:
            self.requestRechargePreview()
        case .y:
            guard let size = NoteSize(rawValue: data.O_DATA?.noteSize?.lowercased() ?? "") else { return }
            guard let data = data.O_DATA else { return }
            switch size {
            case .f:
                let sb = UIStoryboard(name: "Menu", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "PushHistory") as? PushHistoryViewController else { return }
                vc.title = data.noteTitle
                vc.contents = data.noteContents
                self.navigationController?.pushViewController(vc, animated: true)
            case .a:
                guard let type = NoteType(rawValue: data.noteType?.lowercased() ?? "") else { return }
                switch type {
                case .web:
                    self.showConfirmHTMLAlert(title: data.noteTitle, htmlString: data.noteContents ?? "") {
                        App.shared.isRemainsInfoChanged = true
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                case .text:
                    self.showConfirmAlert(title: data.noteTitle, message: data.noteContents ?? "") {
                        App.shared.isRemainsInfoChanged = true
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // 2-1. 통신
    private func requestRechargePreview() {
        guard let pData = self.productData else { return }
        print("requestRechargePreview")

        self.showLoadingWindow()
        let cash = self.btnCashCheck.isSelected ? pData.usedCash : "0"
        let point = self.btnPointCheck.isSelected ? pData.usedPoint : "0"
        
        let param = RechargePreviewRequest.Param(opCode: "NOTICE",
                                                 rcgType: pData.rcgType,
                                                 ctn: pData.ctn,
                                                 mvnoId: String(pData.mvnoId),
                                                 rcgAmt: String(pData.price),
                                                 userCash: cash,
                                                 userPoint: point,
                                                 payAmt: String(pData.amountToPay),
                                                 customLang: self.productData?.lang,
                                                 alarmFlag: pData.alarmFlag)
        let req = RechargePreviewRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RechargePreviewResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                App.shared.easyPayFlag = data.O_DATA?.easyPayFlag == "Y" ? true : false
                self?.processRechargePreview(data: data)
                self?.hideLoadingWindow()
            case .failure(let error):
                print(error)
                self?.hideLoadingWindow()
                if let p = self?.parent {
                    error.processError(target: p)
                }
            }
        }
    }
    
    // 2-2. 프로세스
    private func processRechargePreview(data: RechargePreviewResponse) {
        UserDefaultsManager.shared.saveCreditBillType(value: data.O_DATA?.O_CREDIT_BILL_TYPE)
        guard let OCHARGEFLAG = OCHARGEFLAG(rawValue: data.O_DATA?.O_CHARGE_FLAG?.lowercased() ?? "") else { return }
        switch OCHARGEFLAG {
        case .y:
            print("충전")
            guard let OPAYFLAG = OPAYFLAG(rawValue: data.O_DATA?.O_PAY_FLAG?.lowercased() ?? "") else { return }
            switch OPAYFLAG {
            case .y:
                if let ONOTIECECONTENT = data.O_DATA?.O_NOTIECE_CONTENT, ONOTIECECONTENT != "" {
                    self.showCheckHTMLAlert(title: Localized.alert_title_confirm.txt,
                                            htmlString: ONOTIECECONTENT,
                                            confirm: { [weak self] in
                                            self?.requestRcgCash(data: data)
                    }, cancel: nil)
                } else {
                    self.showCheckHTMLAlert(title: Localized.alert_title_confirm.txt,
                                        htmlString: Localized.alert_msg_recharge_preview_progress_user.txt,
                                        confirm: { [weak self] in
                                            self?.requestRcgCash(data: data)
                    }, cancel: nil)
                }
            case .n:
                guard let OCREDITBILLTYPE = OCREDITBILLTYPE(rawValue: data.O_DATA?.O_CREDIT_BILL_TYPE ?? "") else { return }
                guard let data = data.O_DATA else { return }
                guard let pData = self.productData else { return }
                switch OCREDITBILLTYPE {
                case .Bill_11, .Bill_12:
                    let pgInfo = PGInfo(pgID: data.O_PG_ID,
                                        amount: pData.amountToPay,
                                        rechargeAmount: pData.price,
                                        rcgSeq: data.O_RCG_SEQ,
                                        opCode: data.O_OP_CODE,
                                        rcgType: pData.rcgType,
                                        ctn: pData.ctn,
                                        notiContent: data.O_NOTIECE_CONTENT,
                                        oderNum: data.O_ORDERNUM,
                                        btype: data.O_CREDIT_BILL_TYPE)
                    self.resetPointButtons()
                    SegueUtils.openMenu(target: self, link: .pgwebview, params: ["pgInfo":pgInfo])
                case .Bill_13, .Bill_18:
                    let pgInfo = PayInfo(payType: .phone,
                                         amount: pData.amountToPay,
                                         rechargeAmount: pData.price,
                                         rcgSeq: data.O_RCG_SEQ,
                                         opCode: data.O_OP_CODE,
                                         rcgType: pData.rcgType,
                                         ctn: pData.ctn,
                                         notiContent: data.O_NOTIECE_CONTENT,
                                         btype: data.O_CREDIT_BILL_TYPE)
                    self.resetPointButtons()
                    SegueUtils.openMenu(target: self, link: .pay, params: ["payInfo":pgInfo])
                }
            }
        case .n:
            guard let html = data.O_DATA?.O_NOTIECE_CONTENT else { return }
            self.showConfirmHTMLAlert(title: nil, htmlString: html)
        }
        
        // TODO: [SharedUserDefault saveIsShowCreditMenu:data.OISSHOWCREDITMENU];
    }
    
    // 카드 결제 실패시 2021.03.11
    private func resetPaymentFirstLoad() {
        self.isFirstLoaded = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? ChargeViewController {
            vc.title = self.paymentTitle
        }
    }
    
    private func requestRcgCash(data: RechargePreviewResponse) {
        
        guard let rcgSeq = data.O_DATA?.O_RCG_SEQ else { return }
        guard let opCode = data.O_DATA?.O_OP_CODE else { return }
        guard let pData = self.productData else { return }
        
        self.showLoadingWindow()
        let req = RechargeCashRequest(param: RechargeCashRequest.Param(rcgSeq: rcgSeq,
                                                                       rcgMode: "CASH",
                                                                       opCode: opCode,
                                                                       rcgType: pData.rcgType,
                                                                       CTN: pData.ctn,
                                                                       rcgAmt: String(pData.price),
                                                                       payAmt: "0",
                                                                       lang: pData.lang))
        
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RechargeCashResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print(data)
                self?.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: Localized.alert_msg_recharge_progress.txt, confirm: {
                    App.shared.isRemainsInfoChanged = true
                    SegueUtils.openHistory(target: self)
                })
                if pData.rcgType != "E" {
                    Utils.saveRechargeNumber(ctn: pData.ctn)
                }
                self?.hideLoadingWindow()
            case .failure(let error):
                self?.hideLoadingWindow()
                if let p = self?.parent {
                    error.processError(target: p)
                }
            }
        }
    }
}

extension PaymentViewController {
    /**
     *  알람 현재 상태 가져오기 (충전 시도시 적용됨)
     */
    private func applyMonthlyAlarm() {
        self.productData?.alarmFlag = self.btnAlarmCheck.isSelected ? "Y":"N"
    }
    
    /**
     *  결제 진행시 알람 값 로컬에 저장
     */
    public func loadMonthlyAlarm(type: String) {
        if type == "L" {
            viewAlarm.isHidden = false
        } else {
            viewAlarm.isHidden = true
        }
    }
}
