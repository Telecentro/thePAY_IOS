//
//  CardViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/31.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

class CardViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblSafeCardTitle: TPLabel!
    @IBOutlet weak var lblChargeAmountTitle: TPLabel!
    @IBOutlet weak var lblAmountTitle: TPLabel!
    @IBOutlet weak var lblCardNumberTitle: TPLabel!
    @IBOutlet weak var lblSaveCheckBoxTitle: TPLabel!
    @IBOutlet weak var lblShowCheckBoxTitle: TPLabel!
    @IBOutlet weak var lblDescKorean: TPLabel!
    @IBOutlet weak var lblExpiredDateTitle: TPLabel!
    @IBOutlet weak var lblValidThru: TPLabel!
    @IBOutlet weak var lblPasswordTitle: TPLabel!
    @IBOutlet weak var lblBirthTitle: TPLabel!
    @IBOutlet weak var lblBirthEx: TPLabel!
    @IBOutlet weak var lblDescWarning: TPLabel!
    
    @IBOutlet weak var lblImageCardNumber: TPLabel!
    @IBOutlet weak var lblImageCardExpiredDate: TPLabel!
    
    @IBOutlet weak var swEazy: UISwitch!
    @IBOutlet weak var svpEasyPayment: EasyPayView!
    @IBOutlet weak var svpCardPayment: UIStackView!
    @IBOutlet weak var svpSafeCard: UIView!
    @IBOutlet weak var svpChargeAmount: UIStackView!
    @IBOutlet weak var svpManualAmount: UIStackView!
    @IBOutlet weak var svpPayAmount: UIView!
    @IBOutlet weak var svpCard: TPCardView!
    @IBOutlet weak var svpExpiredDate: UIStackView!
    @IBOutlet weak var svpPassword: UIStackView!
    @IBOutlet weak var svpBirth: UIStackView!
    @IBOutlet weak var svpAlienCard: UIView!
    @IBOutlet weak var svpSampleCard: UIView!
    @IBOutlet weak var lblAmount: TPLabel!
    
    @IBOutlet weak var tfAmount: TPTextField!
    @IBOutlet weak var tfMonth: TPTextField!
    @IBOutlet weak var tfYear: TPTextField!
    @IBOutlet weak var tfBirth: TPTextField!
    @IBOutlet weak var tfPasswd: TPTextField!
    @IBOutlet weak var tfManualAmount: TPTextField!
    
    @IBOutlet weak var btnExCardNum: TPButton!
    @IBOutlet weak var btnExValidNum: TPButton!
    @IBOutlet weak var btnForignerCard: TPButton!
    @IBOutlet weak var btnSaveCardNumber: TPButton!
    @IBOutlet weak var btnShowCardNumber: UIButton!
    
    @IBOutlet weak var btnChargeCard: UIButton!
    @IBOutlet weak var btnChargeBank: UIButton!
    
    @IBOutlet weak var lblNavTitle: TPLabel!
    
    
    var changeRechargeView:((ChargeType)->Void)?
    var updatePaymentType:((EasyPaymentType?)->Void)?
    
    private var vm = CardViewModel()
    
    var menuManager:MenuManager<SubPreloadingResponse.cashList>?
    
    public func setPaymentInfo(from: ChargeFrom, payInfo: PayInfo?) {
        vm.from = from
        vm.payInfo = payInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        self.createCashList()
        self.updateDisplay()
        self.updateTapDisplay()   // 최초 1회 실행 (Amount 롤링)
        
        updateSafeCardVisible()
        showCardBillType()
        setupDelegate()
        loadSavedCardInfo()
        
        requestSubPreloading(opCode: .cashList) { [weak self] (data:[Any]?) -> Void in
            guard let self = self else { return }
            self.menuManager?.updateData(data: MenuDataConverter.cashList(value: App.shared.cashList))
        }
        
        tfManualAmount.addTarget(self, action: #selector(fieldDidchanged), for: .editingChanged)
        
        svpEasyPayment.vm = self.vm
        
        if App.shared.easyPayFlag {
            swEazy.isOn = true
            listEasy()
        }
    }
    
    fileprivate func createCashList() {
        var config = SPMenuConfig()
        config.maxWidth = 300
        menuManager = MenuManager(config: config)
        
        menuManager?.menu?.selectItem = { [weak self] in
            if let data = $0 {
                
                self?.tfAmount.text = data.cashName
                if let f = self?.vm.from {
                    if f == .cash {
                        if self?.vm.amount == "etc" {
                            self?.svpManualAmount.isHidden = false
                        } else {
                            self?.svpManualAmount.isHidden = true
                        }
                    }
                }
                
                self?.vm.amount = data.amounts ?? ""
                if let selectedItem = data.amounts, selectedItem == "etc" {
                    self?.tfManualAmount.placeholder = data.hint
                    self?.svpManualAmount.isHidden = false
                    self?.vm.lastSelectAmountInfo = data
                } else {
                    self?.svpManualAmount.isHidden = true
                }
            }
        }
    }
    
    @objc func fieldDidchanged(_ textField:UITextField) {
        if let amountString = textField.text?.replacingOccurrences(of: ",", with: "") {
            // Max로 입력
            if let ls = vm.lastSelectAmountInfo {
                let max = Int(ls.maxVal ?? "100000") ?? 100000
                if Int(amountString) ?? 0 > max {
                    textField.text = max.currency
                    // 금액 0원은 입력 제한
                } else if Int(amountString) ?? 0 == 0{
                    textField.text = ""
                } else {
                    textField.text = amountString.currency
                }
            }
        }
    }
    
    @IBAction func chargeCard(_ sender: Any) {
        self.changeRechargeView?(.card)
    }
    
    @IBAction func chargeBank(_ sender: Any) {
        self.changeRechargeView?(.bank)
    }
    
    @IBAction func showDatePicker(_ sender: Any) {
        let sb = UIStoryboard(name: "PopUp", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "BirthViewController") as? BirthViewController else { return }
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func showCardImage(_ sender: UIButton) {
        let sb = UIStoryboard(name: "PopUp", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "CardGuideViewController") as? CardGuideViewController else { return }
        switch sender {
        case btnExCardNum:
            vc.cardImageType = .cardnum
            vc.cardImageString = "ex_card_cardnum.png"
        case btnExValidNum:
            vc.cardImageType = .valid
            vc.cardImageString = "ex_card_valid.png"
        case btnForignerCard:
            vc.cardImageType = .sample
            vc.cardImageString = "aleincard_sample.png"
        default: break
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func saveCardNumber(_ sender: Any) {
        self.btnSaveCardNumber.isSelected = !self.btnSaveCardNumber.isSelected
        if self.btnSaveCardNumber.isSelected {
            if svpCard.isValidCardNumber() {
                UserDefaultsManager.shared.saveRecentCardNumber(value: svpCard.getCardNum())
                UserDefaultsManager.shared.saveRecentCardType(value: vm.cm.cardType.rawValue)
            } else {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                self.btnSaveCardNumber.isSelected = false
                UserDefaultsManager.shared.saveRecentCardNumber(value: "")
            }
        } else {
            UserDefaultsManager.shared.saveRecentCardNumber(value: "")
        }
    }
    
    @IBAction func showCardNumber(_ sender: Any) {
        self.btnShowCardNumber.isSelected = !self.btnShowCardNumber.isSelected
        UserDefaultsManager.shared.saveShowCardNumber(value: self.btnShowCardNumber.isSelected)
        
        self.svpCard.tfCard3.isSecureTextEntry = !self.btnShowCardNumber.isSelected
        self.svpCard.tfCardShort2.isSecureTextEntry = !self.btnShowCardNumber.isSelected
        self.tfMonth.isSecureTextEntry = !self.btnShowCardNumber.isSelected
        self.tfYear.isSecureTextEntry = !self.btnShowCardNumber.isSelected
        self.tfPasswd.isSecureTextEntry = !self.btnShowCardNumber.isSelected
    }
    
    @IBAction func showChargeList(_ sender: UIButton) {
        menuManager?.show(sender: sender)
    }
    
    @IBAction func goSafeCard(_ sender: Any) {
        SegueUtils.push(target: self, link: .request_easypay)
    }
    
    func localize() {
        self.lblChargeAmountTitle.text = Localized.recharge_pay_amount.txt
        self.lblAmountTitle.text = Localized.recharge_pay_amount.txt
        self.lblCardNumberTitle.text = Localized.recharge_card_number.txt
        self.lblBirthTitle.text = Localized.alert_msg_birth_6_digit.txt
        self.lblPasswordTitle.text = Localized.recharge_card_pwd.txt
        self.lblDescWarning.text = Localized.warning_card.txt
        self.lblExpiredDateTitle.text = Localized.recharge_card_exp_date.txt
        self.lblSaveCheckBoxTitle.text = Localized.recharge_card_number_save.txt
        self.lblShowCheckBoxTitle.text = Localized.checkbox_show_card_num.txt
        self.lblDescKorean.text = Localized.warnig_use_card.txt
        self.lblBirthEx.text = Localized.recharge_card_birthday_sample.txt
        self.lblSafeCardTitle.text = Localized.text_title_easy_payment_switch.txt
        
        self.lblImageCardNumber.text = Localized.recharge_card_number.txt
        self.lblImageCardExpiredDate.text = Localized.recharge_card_exp_date_guide.txt
        
        self.lblValidThru.text = "VALID\nTHRU"
        
        self.btnChargeCard.setTitle(Localized.tab_creditcard.txt, for: .normal)
        self.btnChargeBank.setTitle(Localized.tab_account.txt, for: .normal)
        
        self.lblNavTitle.text = self.title
        
        svpEasyPayment.localize()
    }
    
    private func updateDisplay() {
        guard let from = self.vm.from else { return }
        switch from {
        case .cash:
            svpPayAmount.isHidden = true
            svpAlienCard.isHidden = true
            svpBirth.isHidden = true
            svpPassword.isHidden = true
        case .payment:
            svpChargeAmount.isHidden = true
            svpAlienCard.isHidden = true
            svpBirth.isHidden = true
            svpPassword.isHidden = true
        }
        
        self.initPaymentSwitch()
    }
}

// FROM 분기 목록
extension CardViewController {
    
    // 화면 노출 분기
    private func showCardBillType() {
        switch vm.from {
        case .cash:
            let btype = vm.oCreditBillType
            vm.showDetail = btype == "13"
            self.showPanel(detail: vm.showDetail)
        case .payment:
//            guard let info = payInfo else { return }  // 2020.10.13 제거
            let btype = vm.oCreditBillType
            vm.showDetail = btype == "13"
            self.showPanel(detail: vm.showDetail)
        default:
            print("NONE")
        }
    }
    
    private func showPanel(detail: Bool) {
        if detail {
            svpPassword.isHidden = false
            svpBirth.isHidden = false
            svpAlienCard.isHidden = false
            svpSampleCard.isHidden = true
        } else {
            svpPassword.isHidden = true
            svpBirth.isHidden = true
            svpAlienCard.isHidden = true
            svpSampleCard.isHidden = false
        }
    }
    
    // 안전결제 노출
    private func updateSafeCardVisible() {
        let lang = UserDefaultsManager.shared.loadNationCode()
        
        switch vm.from {
        case .cash:
            if lang == CodeLang.CodeLangKOR.nationCode {
                vm.ezPaymentType = .easyOnly
            } else {
                vm.ezPaymentType = .easyAndSafe
            }
        case .payment:
            if lang == CodeLang.CodeLangKOR.nationCode {
                vm.ezPaymentType = .easyOnly
            } else {
                guard let info = vm.payInfo else { return }
                guard let payType = info.payType else { return }
                if payType == .opening {
                    vm.ezPaymentType = .easyOnly
                } else {
                    vm.ezPaymentType = .easyAndSafe
                }
            }
        case .none:
            print("NONE")
        }
    }
    
    func updateTapDisplay() {
        guard let info = vm.payInfo else { return }
        self.lblAmount.text = info.amount?.currency.won
    }
    
    func updateButtonStatus(type:ChargeType = .card) {
        switch type {
        case .card:
            btnChargeCard.isSelected = true
            btnChargeBank.isSelected = false
        case .bank:
            btnChargeBank.isSelected = true
            btnChargeCard.isSelected = false
        }
    }
    
    func recharge() {
        switch self.vm.paymentType {
        case .cardpay:
            rechargeNormal()
        case .easypay:
            rechargeEasypay()
        }
    }
    
    private func rechargeEasypay() {
        if confirmManualAmount() {
            return
        }
        
        switch vm.from {
        case .cash:
            self.showKeypadViewController()
        case .payment:
            
            guard let info = vm.payInfo else { return }
            
            self.showCheckHTMLAlert(title: getRechargeTitle(), htmlString: info.notiContent ?? "", confirm: { [weak self] in
                self?.showKeypadViewController()
            }, cancel: nil)
        case .none:
            print("NONE")
        }
    }
    
    private func rechargeNormal() {
        if confirmManualAmount() {
            return
        }
        
        switch vm.from {
        case .cash:
            self.requestCardLimiteV3()
        case .payment:
            if !checkData() {
                return
            }
            
            guard let info = vm.payInfo else { return }
            
            self.showCheckHTMLAlert(title: getRechargeTitle(), htmlString: info.notiContent ?? "", confirm: { [weak self] in
                self?.requestCardLimiteV3()
            }, cancel: nil)
        case .none:
            print("NONE")
        }
        
    }
    
    private func confirmManualAmount() -> Bool {
        // 직접입력시 값 변경
        if !self.svpManualAmount.isHidden {
            vm.amount = self.tfManualAmount.text?.removeCurrency ?? "0"
            if let ls = vm.lastSelectAmountInfo {
                let min = Int(ls.minVal ?? "1000") ?? 1000
                let minString = ls.minVal ?? "1000"
                let maxString = ls.maxVal ?? "100000"
                if Int(vm.amount) ?? 0 < min {
                    let msg = Localized.toast_cash_min_to_max.txt.replacingOccurrences(of: "%d", with: "%@")
                    let rMsg = String(format: msg, minString.currency, maxString.currency)
                    rMsg.showErrorMsg(target: self.view)
                    return true
                }
            } else {
                Localized.toast_cash_min_to_max.txt.showErrorMsg(target: self.view)
                return true
            }
        }
        
        return false
    }
    
    private func getRechargeTitle() -> String {
        
        var title = ""
        
        guard let info = vm.payInfo else { return title }
        guard let payType = info.payType else { return title }
        
        switch payType {
        case .phone:
            title = Localized.alert_msg_recharge_preview_progress_user.txt
        case .international:
            title = Localized.alert_msg_recharge_preview_progress_call.txt
        default:
            print("NO")
        }
        
        return title
    }
    
    
    // 한도 체크
    private func requestCardLimiteV3() {
        if !checkData() {
            return
        }
        
        
        let c = getCardInfo()
        guard let r = vm.getRechargeLimitInfo() else { return }
        let param = RcgCardLimiteV3Request.Param(cardNum: c.encryptCardNum,
                                                 cardExpireYY: c.yy,
                                                 cardExpireMM: c.mm,
                                                 cardPsswd: c.cardPwd,
                                                 userSecureNum: c.userSecureNum,
                                                 rcgAmt: r.rcgAmt,
                                                 payAmt: r.payAmt,
                                                 rcgType: r.rcgType,
                                                 rcgSeq: r.rcgSeq,
                                                 O_CREDIT_BILL_TYPE: r.billtype,
                                                 ctn: r.ctn)
        
        let req = RcgCardLimiteV3Request(param: param)
        
        print("☹️ 111")
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RcgCardLimiteV3Response, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.vm.limitSeq = data.O_DATA?.limiteSeq ?? ""
                print("☹️ 222")
                self.hideLoadingWindow()
                if let usable = RcgCardUsable(rawValue: data.O_DATA?.rcgCardUsable?.lowercased() ?? "") {
                    if usable == .y {
                        if r.billtype == Bill.T13 {   // 기존 빌타입이 13이면 바로 결제
                            self.requestRechargeCredit()
                        } else {    // 기존에 18이면
                            guard let newb = data.O_DATA?.O_CREDIT_BILL_TYPE else { return }
                            if newb.count > 0 {
                                self.vm.oCreditBillType = newb
                            }
                            
                            if newb == Bill.T13 {
                                self.vm.showDetail = true          // 필요 없을 듯 2020.10.07
                                self.showCardBillType()         // 카드 타입 수정
                            } else {
                                self.requestRechargeCredit()    // 결제
                            }
                        }
                    } else if usable == .n {
                        if let contents = data.O_DATA?.rcgCardContents {
                            if let type = data.O_DATA?.rcgCardType {
                                if type.lowercased() == Content.web {
                                    self.showConfirmHTMLAlert(title: nil, htmlString: contents) {
                                        /* 2021.03.29 에러 로직 제거 .ccd_v2 처럼 처리 */
                                    }
                                } else if type.lowercased() == Content.txt {
                                    self.showConfirmAlert(title: data.O_DATA?.rcgCardTitle, message: contents) {
                                        /* 2021.03.29 에러 로직 제거 .ccd_v2 처럼 처리 */
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("☹️ 333")
                error.processError(target: self)
                self.hideLoadingWindow()
            }
        }
        
    }
    
    // 결제
    private func requestRechargeCredit() {
        let c = getCardInfo()
        guard let r = vm.getRechargeInfo() else { return }
        
        self.showLoadingWindow()
        let param = RechargeCreditV2Request.Param(rcgSeq: r.rcgSeq,
                                                  rcgMode: "CCD",
                                                  opCode: r.opCode,
                                                  rcgType: r.rcgType,
                                                  CTN: r.ctn,
                                                  rcgAmt: r.rcgAmt,
                                                  payAmt: r.payAmt,
                                                  cardName: "",
                                                  cardNum: c.encryptCardNum,
                                                  cardExpireYY: c.yy,
                                                  cardExpireMM: c.mm,
                                                  cardPsswd: c.cardPwd,
                                                  cardCvc: "",
                                                  userSecureNum: c.userSecureNum,
                                                  limiteSeq: vm.limitSeq)
        
        let req = RechargeCreditV2Request(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RechargeCreditV2Response, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print(data, self)
                App.shared.isRemainsInfoChanged = true
                if let f = self.vm.from {
                    switch f {
                    case .cash:     // 충전
                        self.showConfirmHTMLAlert(title: Localized.alert_title_confirm.txt, htmlString: data.O_MSG) {
                            self.performSegue(withIdentifier: "unwindMain", sender: nil)
                        }
                    case .payment:  // 결제
                        if let p = self.vm.payInfo?.payType {
                            
                            if p == .international {
                                App.shared.isKtposRemainsInfoChange = true
                            }
                            
                            switch p {
                            case .opening:
                                NotificationCenter.default.post(name: NSNotification.Name("callbackPayment"), object: true)
                            default:
                                self.showRechargeSuccessDialog()
                                break
                            }
                        }
                    }
                }
                
                if r.rcgType != "E" {
                    Utils.saveRechargeNumber(ctn: r.ctn)
                }
                self.hideLoadingWindow()
            case .failure(let error):
                error.processError(target: self, type: .ccd_v2)
                self.hideLoadingWindow()
                // 카드번호 (유효기간 틀리면 발생)
                // TODO: 에러 로직 추가 (PayCardViewController 참고)
            }
        }
    }
    
    private func showRechargeSuccessDialog() {
        var msg = ""
        
        if let p = vm.payInfo?.payType {
            switch p {
            case .phone:
                msg = Localized.alert_msg_recharge_progress.txt
            case .international:
                msg = Localized.alert_msg_recharge_progress.txt
            default:
                break
            }
        }
        
        self.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: msg) {
            SegueUtils.openHistory(target: self)
        }
    }
    
}




extension CardViewController: UITextFieldDelegate, TPTextFieldDelegate {

    fileprivate func updateShowCardNumber() {
        let showCardNumber = UserDefaultsManager.shared.loadShowCardNumber()
        
        if showCardNumber {
            self.btnShowCardNumber.isSelected = true
            self.svpCard.tfCard3.isSecureTextEntry = false
            self.svpCard.tfCardShort2.isSecureTextEntry = false
        } else {
            self.btnShowCardNumber.isSelected = false
            self.svpCard.tfCard3.isSecureTextEntry = true
            self.svpCard.tfCardShort2.isSecureTextEntry = true
        }
    }
    
    fileprivate func updateSaveCardNumber() {
        let savedCardNumbers = UserDefaultsManager.shared.loadRecentCardNumber()
        
        if savedCardNumbers.isNilOrEmpty {
            if vm.cm.isShorterCard() {
                svpCard.tfCardShort1.text = ""
                svpCard.tfCardShort2.text = ""
                svpCard.tfCardShort3.text = ""
                svpCard.tfCardShort3.placeholder = vm.cm.getLastCardPlaceholder()
            } else {
                svpCard.tfCard1.text = ""
                svpCard.tfCard2.text = ""
                svpCard.tfCard3.text = ""
                svpCard.tfCard4.text = ""
            }
            self.btnSaveCardNumber.isSelected = false
        } else {
            if vm.cm.isShorterCard() {
                svpCard.tfCardShort1.text = vm.cm.loadCardNumber1()
                svpCard.tfCardShort2.text = vm.cm.loadCardNumber2()
                svpCard.tfCardShort3.text = vm.cm.loadCardNumber3()
                svpCard.tfCardShort3.placeholder = vm.cm.getLastCardPlaceholder()
            } else {
                svpCard.tfCard1.text = vm.cm.loadCardNumber1()
                svpCard.tfCard2.text = vm.cm.loadCardNumber2()
                svpCard.tfCard3.text = vm.cm.loadCardNumber3()
                svpCard.tfCard4.text = vm.cm.loadCardNumber4()
            }
            
            self.btnSaveCardNumber.isSelected = true
            svpCard.cardNumberChange()
        }
    }
    
    fileprivate func updateRecentCardType() {
        vm.cm.cardType = UserDefaultsManager.shared.loadRecentCardType()
        if vm.cm.isShorterCard() {
            svpCard.svpCardType1.isHidden = true
            svpCard.svpCardType2.isHidden = false
        } else {
            svpCard.svpCardType1.isHidden = false
            svpCard.svpCardType2.isHidden = true
        }
    }
    
    private func loadSavedCardInfo() {
        updateRecentCardType()
        updateSaveCardNumber()
        updateShowCardNumber()
    }
    
    private func setupDelegate() {
        tfMonth.delegate = self
        tfMonth.newDelegate = self
        tfYear.delegate = self
        tfYear.newDelegate = self
        tfPasswd.delegate = self
        tfPasswd.newDelegate = self
        tfBirth.delegate = self
        tfBirth.newDelegate = self
        
        svpCard.tfCard1.delegate = self
        svpCard.tfCard1.newDelegate = self
        svpCard.tfCard2.delegate = self
        svpCard.tfCard2.newDelegate = self
        svpCard.tfCard3.delegate = self
        svpCard.tfCard3.newDelegate = self
        svpCard.tfCard4.delegate = self
        svpCard.tfCard4.newDelegate = self
        
        svpCard.tfCardShort1.delegate = self
        svpCard.tfCardShort1.newDelegate = self
        svpCard.tfCardShort2.delegate = self
        svpCard.tfCardShort2.newDelegate = self
        svpCard.tfCardShort3.delegate = self
        svpCard.tfCardShort3.newDelegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.tfPasswd == textField {
            textField.background = nil
        } else {
            textField.background = UIImage(named: "input_box_44_44")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.background = UIImage(named: "select_44")
    }
    
    func backspace(textField: TPDelegateTextField) {
        switch textField {
        case tfMonth:
          break
          // 2021.04.26 제거요청
//            if cm.isShorterCard() {
//                svpCard.tfCardShort3.becomeFirstResponder()
//            } else {
//                svpCard.tfCard4.becomeFirstResponder()
//            }
        case tfYear:
            tfMonth.becomeFirstResponder()
        case tfPasswd:
            tfYear.becomeFirstResponder()
        case tfBirth:
            tfPasswd.becomeFirstResponder()
        case svpCard.tfCard1:
            self.view.endEditing(true)
        case svpCard.tfCard2:
            svpCard.tfCard1.becomeFirstResponder()
        case svpCard.tfCard3:
            svpCard.tfCard2.becomeFirstResponder()
        case svpCard.tfCard4:
            svpCard.tfCard3.becomeFirstResponder()
        case svpCard.tfCardShort1:
            self.view.endEditing(true)
        case svpCard.tfCardShort2:
            svpCard.tfCardShort1.becomeFirstResponder()
        case svpCard.tfCardShort3:
            svpCard.tfCardShort2.becomeFirstResponder()
        default:
            print(textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    private func jump4(textField: UITextField, string: String, range:NSRange, target: UITextField?) -> Bool {
        jump(length: DIGIT.L4, textField: textField, string: string, range: range, target: target)
    }
    
    private func jump5(textField: UITextField, string: String, range:NSRange, target: UITextField?) -> Bool {
        jump(length: DIGIT.L5, textField: textField, string: string, range: range, target: target)
    }
    
    private func jump6(textField: UITextField, string: String, range:NSRange, target: UITextField?) -> Bool {
        jump(length: DIGIT.L6, textField: textField, string: string, range: range, target: target)
    }
    
    private func jump(length: Int, textField: UITextField, string: String, range:NSRange, target: UITextField?) -> Bool {
        
        var cursorPosition = 0
        
        if let selectedRange = textField.selectedTextRange {
            cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            print("1️⃣ [STRING \(textField.text ?? "nil")] [NEW \(string)] [R.LOC \(range.location)] [R.LEN \(range.length)] [CUR \(cursorPosition)]")
        } else {
            print("1️⃣ [STRING \(textField.text ?? "nil")] [NEW \(string)] [R.LOC \(range.location)] [R.LEN \(range.length)]")
        }
        
        let maxLocation = length - 1
        
        if textField.text?.count ?? 0 == length && range.length == 0 && string != "" {
            becomeNext(target: target)
            return false
        } else if (range.location == maxLocation && cursorPosition == maxLocation && range.length != 0 && string != "") {    // 마지막 글자 수정
            var text = textField.text ?? ""
            if text.count > 0 {
                text.removeLast()
            }
            textField.text = "\(text)\(string)"
            becomeNext(target: target)
            return false
        } else if range.location == maxLocation && string != "" {
            textField.text = "\(textField.text ?? "")\(string)"
            becomeNext(target: target)
            return false
        } else {
            return true
        }
    }
    
    private func becomeNext(target: UITextField?) {
        var firstCardInput = svpCard.tfCardShort1!
        if svpCard.svpCardType1.isHidden {
            firstCardInput = svpCard.tfCard1!
        }
        svpCard.cardNumberChange()
        if let t = target {
            switch t {
            case svpCard.tfCardShort2, svpCard.tfCard2:
                if !firstCardInput.isFirstResponder {
                    t.becomeFirstResponder()
                }
            default:
                t.becomeFirstResponder()
            }
        } else {
            view.endEditing(true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if !string.isArabianNumber && string != "" {
            return false
        }
        
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                if let tp = textField as? TPDelegateTextField {
                    tp.lastBackspace = true
                }
            }
        }
        
        switch textField {
        case tfMonth:
            if range.location >= 1 && string != "" {
                if range.location == 1 {
                    tfMonth.text = "\(tfMonth.text ?? "")\(string)"
                }
                
                tfYear.becomeFirstResponder()
                return false
            }
        case tfYear:
            if range.location >= 1 && string != "" {
                if range.location == 1 {
                    tfYear.text = "\(tfYear.text ?? "")\(string)"
                }
                if (vm.showDetail) {
                    tfPasswd.becomeFirstResponder()
                } else {
                    self.view.endEditing(true)
                }
                return false
            }
        case tfPasswd:
            if range.location >= 1 && string != "" {
                if range.location == 1 {
                    tfPasswd.text = "\(tfPasswd.text ?? "")\(string)"
                }
                tfBirth.becomeFirstResponder()
                return false
            }
        case tfBirth:
            if range.location >= 5 && string != "" {
                if range.location == 5 {
                    tfBirth.text = "\(tfBirth.text ?? "")\(string)"
                }
                self.view.endEditing(true)
                return false
            }
        case svpCard.tfCard1:
            if !jump4(textField: textField, string: string, range: range, target: svpCard.tfCard2) {
                return false
            }
        case svpCard.tfCard2:
            if !jump4(textField: textField, string: string, range: range, target: svpCard.tfCard3) {
                return false
            }
        case svpCard.tfCard3:
            if !jump4(textField: textField, string: string, range: range, target: svpCard.tfCard4) {
                return false
            }
        case svpCard.tfCard4:
            if !jump4(textField: textField, string: string, range: range, target: tfMonth) {
                return false
            }
        case svpCard.tfCardShort1:
            if !jump4(textField: textField, string: string, range: range, target: svpCard.tfCardShort2) {
                return false
            }
        case svpCard.tfCardShort2:
            if !jump6(textField: textField, string: string, range: range, target: svpCard.tfCardShort3) {
                return false
            }
        case svpCard.tfCardShort3:
            switch vm.cm.cardType {
            case .CARD_TYPE_AMERICAN_EXPRESS_SHORTER:
                if !jump5(textField: textField, string: string, range: range, target: tfMonth) {
                    return false
                }
            case .CARD_TYPE_DINERS_CLUB_SHORT:
                if !jump4(textField: textField, string: string, range: range, target: tfMonth) {
                    return false
                }
            default:
                break
            }
        default:
            break
        }
        
        return true
    }
    
    
    
    private func checkData() -> Bool {
        
        if vm.cm.isShorterCard() {
            if svpCard.tfCardShort1.text.isNilOrEmpty ||
                svpCard.tfCardShort2.text.isNilOrEmpty ||
                svpCard.tfCardShort3.text.isNilOrEmpty {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if svpCard.tfCardShort1.text?.count != 4 || svpCard.tfCardShort2.text?.count != 6 {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if (svpCard.tfCardShort3.text?.count ?? 0) < 3 {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                return false
            }
        } else {
            if svpCard.tfCard1.text.isNilOrEmpty ||
                svpCard.tfCard2.text.isNilOrEmpty ||
                svpCard.tfCard3.text.isNilOrEmpty ||
                svpCard.tfCard4.text.isNilOrEmpty {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if svpCard.tfCard1.text?.count != 4 || svpCard.tfCard2.text?.count != 4 || svpCard.tfCard3.text?.count != 4 {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if vm.cm.cardType == .CARD_TYPE_JCB_SHORT {
                if (svpCard.tfCard4.text?.count ?? 0) < 3 {
                    Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                    return false
                } else {
                    if (svpCard.tfCard4.text?.count ?? 0) != 4 {
                        Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
                    }
                    return false
                }
            }
        }
        
        if tfYear.text.isNilOrEmpty {
            Localized.toast_empty_card_yy.txt.showErrorMsg(target: self.view)
            return false
        }
        
        if tfMonth.text.isNilOrEmpty {
            Localized.toast_empty_card_yy.txt.showErrorMsg(target: self.view)
            return false
        }
        
        if tfYear.text?.count != 2 {
            Localized.toast_expyear_length.txt.showErrorMsg(target: self.view)
            return false
        }
        
        if tfMonth.text?.count != 2 {
            Localized.toast_expmonth_length.txt.showErrorMsg(target: self.view)
            return false
        }
        
        if vm.showDetail {
            if tfPasswd.text.isNilOrEmpty {
                Localized.toast_empty_card_pwd.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if tfPasswd.text?.count != 2 {
                Localized.toast_pwd_length.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if tfBirth.text.isNilOrEmpty {
                Localized.toast_empty_card_birth.txt.showErrorMsg(target: self.view)
                return false
            }
            
            if tfBirth.text?.count != 6 {
                Localized.toast_birth_length.txt.showErrorMsg(target: self.view)
                return false
            }
        }
        
        if tfMonth.text?.toInt() ?? 0 < 1 || tfMonth.text?.toInt() ?? 0 > 12 {
            Localized.toast_expmonth_error.txt.showErrorMsg(target: self.view)
            return false
        }
        
        return true
    }
}

extension CardViewController: DateDelegate {
    func dateMessage(date: String) {
        self.tfBirth.text = date
    }
}

// EasyPayment
extension CardViewController {
    private func initPaymentSwitch() {
        switch vm.paymentType {
        case .cardpay:
            swEazy.isOn = false
        case .easypay:
            swEazy.isOn = true
        }
        
        updatePaymentView(paymentType: vm.paymentType)
    }
    
    @IBAction func pressSwitch(_ sender: UISwitch) {
        if sender.isOn {
            listEasy()
        } else {
            vm.paymentType = .cardpay
            self.updatePaymentView(paymentType: self.vm.paymentType)
        }
    }
    
    private func updatePaymentView(paymentType: PaymentType) {
        switch paymentType {
        case .cardpay:
            svpCardPayment.isHidden = false
            svpEasyPayment.isHidden = true
            updatePaymentType?(nil)
        case .easypay:
            svpCardPayment.isHidden = true
            svpEasyPayment.isHidden = false
            svpEasyPayment.updateEazyPaymentView(type: vm.ezPaymentType)
            updatePaymentType?(vm.ezPaymentType)
        }
    }
    
}

extension CardViewController {
    
    // data missmatch (확인)
    // 간편결제 등록정보 보기
    private func listEasy() {
        let params = ListEasyRequest.Param(opCode: FLAG.U)
        let req = ListEasyRequest(param: params)
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<ListEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print(data)
                if data.O_CODE == FLAG.SUCCESS {
                    if data.O_DATA?.easyPayList?.count ?? 0 > 0 {
                        self.vm.ezPaymentType = .select
                        self.svpEasyPayment.updateEasyPayData(data: data.O_DATA?.easyPayList)
                    } else {
                        self.updateSafeCardVisible()
                    }
                    
                    self.vm.paymentType = .easypay
                    self.updatePaymentView(paymentType: self.vm.paymentType)
                    
                } else if data.O_CODE == FLAG.E8905 || data.O_CODE == FLAG.E8906 {
                    self.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG) {
                        self.swEazy.isOn = false
                        self.vm.paymentType = .cardpay
                        self.updatePaymentView(paymentType: self.vm.paymentType)
                    }
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    /**
     *  키패드 노출
     */
    private func showKeypadViewController() {
        self.svpEasyPayment.ableToSavePosition = false
        guard let vc = Link.easy_pwd_auth.viewController as? EasyKeyboardViewController else { return }
        vc.useCase = "2"
        vc.password = { [weak self] pwd in
            if !pwd.isEmpty {
                if self?.svpEasyPayment.easyPayData?.count ?? 0 > 0 {
                    let data = self?.svpEasyPayment.getSelectData()
                    self?.requestRechargeEasyPayment(data: data, pwd: pwd)
                } else {
                    self?.showCardPayView()
                }
            } else {
                self?.showCardPayView()
            }
            
            self?.svpEasyPayment.ableToSavePosition = true
        }
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    private func showCardPayView() {
        vm.paymentType = .cardpay
        swEazy.isOn = false
        updatePaymentView(paymentType: vm.paymentType)
    }
    
    private func requestRechargeEasyPayment(data: ListEasyResponse.easyPayList?, pwd: String) {
        guard let seq = data?.easyPaySubSeq else {
            Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view)
            return
        }
        
        print("\(seq) \(data?.cardnum ?? "") \(pwd)")
        self.svpEasyPayment.resetPosition()
        
        guard let r = vm.getRechargeLimitInfo() else { return }
        
        let params = RechargeEasyLimteRequest.Param(
            rcgSeq: r.rcgSeq,
            rcgType: r.rcgType,
            rcgAmt: r.rcgAmt,
            payAmt: r.payAmt,
            easyPaySubSeq: String(seq),
            ctn: r.ctn
        )
        
        let req = RechargeEasyLimteRequest(param: params)
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<RechargeEasyLimteResponse, TPError>) in
            switch response {
            case .success(let data):
                if let usable = RcgCardUsable(rawValue: data.O_DATA?.rcgCardUsable?.lowercased() ?? "") {
                    if usable == .y {
                        let limiteSeq = data.O_DATA?.limiteSeq
                        self.requestRechargeEasyPay(limitSeq: limiteSeq, seq: String(seq), pwd: pwd)
                    } else if usable == .n {
                        if let contents = data.O_DATA?.rcgCardContents {
                            if let type = data.O_DATA?.rcgCardType {
                                if type.lowercased() == Content.web {
                                    self.showConfirmHTMLAlert(title: nil, htmlString: contents) {
                                        /* 2021.03.29 에러 로직 제거 .ccd_v2 처럼 처리 */
                                    }
                                } else if type.lowercased() == Content.txt {
                                    self.showConfirmAlert(title: data.O_DATA?.rcgCardTitle, message: contents) {
                                        /* 2021.03.29 에러 로직 제거 .ccd_v2 처럼 처리 */
                                    }
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    
    private func getCardInfo() -> CardInfo {
        return CardInfo(
            encryptCardNum: svpCard.getCardNum(),
            yy: tfYear.text.isNilOrEmpty ? "" : tfYear.text!,
            mm: tfMonth.text.isNilOrEmpty ? "" : tfMonth.text!,
            cardPwd: tfPasswd.text.isNilOrEmpty ? "" : tfPasswd.text!,
            userSecureNum: tfBirth.text.isNilOrEmpty ? "" : tfBirth.text!)
    }
    
    private func requestRechargeEasyPay(limitSeq:String?, seq:String, pwd:String) {
        
        guard let r = vm.getRechargeInfo() else { return }
        
        let params = RechargeEasyRequest.Param(
            rcgSeq: r.rcgSeq,
            rcgMode: "CCD",
            opCode: r.opCode,
            rcgType: r.rcgType,
            ctn: r.ctn,
            rcgAmt: r.rcgAmt,
            payAmt: r.payAmt,
            easyPayAuthNum: pwd,
            easyPaySubSeq: seq,
            limiteSeq: limitSeq ?? ""
        )
        
        let req = RechargeEasyRequest(param: params)
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<RechargeEasyResponse, TPError>) in
            switch response {
            case .success(let data):
                print(data, self)
                App.shared.isRemainsInfoChanged = true
                if let f = self.vm.from {
                    switch f {
                    case .cash:     // 충전
                        self.showConfirmHTMLAlert(title: Localized.alert_title_confirm.txt, htmlString: data.O_MSG) {
                            self.performSegue(withIdentifier: "unwindMain", sender: nil)
                        }
                    case .payment:  // 결제
                        if let p = self.vm.payInfo?.payType {
                            
                            if p == .international {
                                App.shared.isKtposRemainsInfoChange = true
                            }
                            
                            switch p {
                            case .opening:
                                NotificationCenter.default.post(name: NSNotification.Name("callbackPayment"), object: true)
                            default:
                                self.showRechargeSuccessDialog()
                                break
                            }
                        }
                    }
                }
                
                if r.rcgType != "E" {
                    Utils.saveRechargeNumber(ctn: r.ctn)
                }
                self.hideLoadingWindow()
            case .failure(let error):
                error.processError(target: self, type: .ccd_v2)
                self.hideLoadingWindow()
                // 카드번호 (유효기간 틀리면 발생)
                // TODO: 에러 로직 추가 (PayCardViewController 참고)
            }
        }
    }
}
