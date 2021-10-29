//
//  BankViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/31.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

enum PayType {
    case phone
    case international
    case opening
}

class BankViewController: TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var lblAmountTitle: TPLabel!
    @IBOutlet weak var lblBankTitle: TPLabel!
    @IBOutlet weak var lblAccountTitle: TPLabel!
    @IBOutlet weak var lblDepositorTitle: TPLabel!
    @IBOutlet weak var lblPhoneTitle: TPLabel!
    @IBOutlet weak var lblWarning: TPLabel!
    @IBOutlet weak var tfPhone: TPTextField!
    @IBOutlet weak var svpAmount: UIView!
    @IBOutlet weak var svpBankName: UIStackView!
    @IBOutlet weak var svpBankAccount: UIStackView!
    @IBOutlet weak var svpDepositor: UIStackView!
    @IBOutlet weak var svpPhone: UIStackView!
    @IBOutlet weak var lblAmount: TPLabel!
    @IBOutlet weak var tfBankAccount: TPTextField!
    @IBOutlet weak var tfDepositor: TPTextField!
    @IBOutlet weak var tfBank: TPTextField!
    
    @IBOutlet weak var btnChargeCard: UIButton!
    @IBOutlet weak var btnChargeBank: UIButton!
    @IBOutlet weak var lblNavTitle: TPLabel!
    @IBOutlet weak var ivBankLogo: UIImageView!
    @IBOutlet weak var lblBlankBank: TPLabel!
    var menuManager:MenuManager<SubPreloadingResponse.bankList>?
    var emptyContents:Bool = true {
        didSet {
            lblBlankBank.isHidden = !emptyContents
            ivBankLogo.isHidden = emptyContents
        }
    }
    private var bankCode: String?
    
    var changeRechargeView:((ChargeType)->Void)?
    
    var from: ChargeFrom?
    var payInfo: PayInfo?
    var bankList: [SubPreloadingResponse.bankList]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        updateDisplay()
        fill()
        
        tfPhone.delegate = self
        let ani = UserDefaultsManager.shared.loadANI() ?? ""
        tfPhone.text = StringUtils.telFormat(ani)
        
        var config = SPMenuConfig()
        config.type = .fullImage
        menuManager = MenuManager(callFirst: false, config: config)
        menuManager?.menu?.selectItem = {
            self.ivBankLogo.image = UIImage(named: $0?.imgNm ?? "bank_11.png")
            self.bankCode = $0?.bankCode
            self.emptyContents = false
            self.requestChangeAccountOnly()
        }
        
        requestSubPreloading(opCode: .bankList) { [weak self] (data:[Any]?) -> Void in
            guard let self = self else { return }
            let d = App.shared.bankList
            self.menuManager?.updateData(data: MenuDataConverter.bank(value: d))
            
            self.bankCode = UserDefaultsManager.shared.loadBankCode()
            if let imgName = UserDefaultsManager.shared.loadBankImgName() {
                self.ivBankLogo.image = UIImage(named: imgName)
            }
            
            for item in d ?? [] {
                if self.bankCode == item.bankCode {
                    self.menuManager?.menu?.reset(idx: item.sortNo ?? 0)
                }
            }
        }
    }
    
    func localize() {
        lblAmountTitle.text = Localized.recharge_pay_amount.txt
        lblBankTitle.text = Localized.recharge_bank_name.txt
        lblAccountTitle.text = Localized.recharge_bank_account.txt
        lblDepositorTitle.text = Localized.recharge_depositor.txt
        lblPhoneTitle.text = Localized.faq_contact.txt
        tfPhone.placeholder = Localized.hint_receive_tel_input.txt
        
        self.btnChargeCard.setTitle(Localized.tab_creditcard.txt, for: .normal)
        self.btnChargeBank.setTitle(Localized.tab_account.txt, for: .normal)
        
        self.lblNavTitle.text = self.title
    }
    
    private func fill() {
        tfBankAccount.text = UserDefaultsManager.shared.loadMyBankAccount()
        tfDepositor.text = Localized.company_depositer.txt
    }
    
    private func updateDisplay() {
        guard let from = self.from else { return }
        switch from {
        case .cash:
            svpAmount.isHidden = true
            svpPhone.isHidden = true
        case .payment:
            print("payment")
        }
        
        // TODO: 사용 않하는지 확인
        lblWarning.isHidden = true
    }
    
    @IBAction func showPicker(_ sender: UIButton) {
        // self?.requestChangeAccountOnly()
        menuManager?.show(sender: sender)
    }
    
    @IBAction func copyAccount(_ sender: Any) {
        Localized.toast_virtual_account_copy_paste.txt.showErrorMsg(target: self.view)
        UIPasteboard.general.string = self.tfBankAccount.text?.removeDash()
    }
    
    
    @IBAction func chargeCard(_ sender: Any) {
        self.changeRechargeView?(.card)
    }
    
    @IBAction func chargeBank(_ sender: Any) {
        self.changeRechargeView?(.bank)
    }
}

extension BankViewController {
    func updateTapDisplay() {
        if let info = self.payInfo {
            lblAmount.text = info.amount?.currency.won
        }
        
        if UserDefaultsManager.shared.loadMyBankAccount().isNilOrEmpty {
            Localized.toast_select_bank.txt.showErrorMsg(target: self.view)
            emptyContents = true
        } else {
            emptyContents = false
        }
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
        
        guard let from = self.from else { return }
        
        switch from {
        case .cash:
            rechargeCash()
        case .payment:
            rechargePayment()
        }
    }
    
    private func rechargeCash() {
        if !self.lblBlankBank.isHidden {
            Localized.toast_select_bank.txt.showErrorMsg(target: self.view)
        } else {
            if isSameCode() {
                self.showConfirmAlert(title: Localized.alert_title_confirm.txt,
                                      message: Localized.alert_msg_request_amount_progress.txt)
            } else {
                self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: Localized.alert_msg_change_account_preview.txt, confirm: { [weak self] in
                    self?.requestChangeAccount()
                }, cancel: nil)
            }
        }
    }
    
    private func rechargePayment() {
        let um = UserDefaultsManager.shared
        
        if um.loadMyBankAccount().isNilOrEmpty
            && um.loadBankCode().isNilOrEmpty
            && self.bankCode.isNilOrEmpty {
            Localized.toast_select_bank.txt.showErrorMsg(target: self.view)
        } else if um.loadMyBankAccount().isNilOrEmpty
            && um.loadBankCode().isNilOrEmpty
            && !self.bankCode.isNilOrEmpty {
            showChangeAccountDialog()
        } else if !um.loadMyBankAccount().isNilOrEmpty
            && !um.loadBankCode().isNilOrEmpty
            && !isSameCode() {
            showChangeAccountDialog()
        } else if !um.loadMyBankAccount().isNilOrEmpty
            && !um.loadBankCode().isNilOrEmpty
            && isSameCode() {
            showAlertRechargeBefore()
        }
    }
    
    // 2. 현재 발급받은 계좌가 없지만 선택된 은행은 있는 경우
    // 3. 현재 발급받은 계좌가 있지만 선택한 은행과 다른 경우
    private func showChangeAccountDialog() {
        self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: Localized.alert_msg_change_account_preview.txt, confirm: { [weak self] in
            self?.requestChangeAccount()
        }, cancel: nil)
    }
    
    // 4. 현재 발급 받은 계좌도 있고, 선택한 은행과 같은 경우
    private func showAlertRechargeBefore() {
        
        guard let info = payInfo else { return }
        
        var content = ""
        
        switch info.payType {
        case .phone:
            content = Localized.alert_msg_recharge_preview_progress_user.txt
        case .international:
            content = Localized.alert_msg_recharge_preview_progress_call.txt
        default :
            content = ""
        }
        
        if content.isEmpty {
            self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: info.notiContent ?? "", confirm: { [weak self] in
                self?.requestRechargeAccount()
            }, cancel: nil)
        } else {
            self.parent?.showCheckHTMLAlert(title: nil, htmlString: info.notiContent ?? "", confirm: { [weak self] in
                self?.requestRechargeAccount()
            }, cancel: nil)
        }
    }
    
    // 완료 팝업
    private func showAlertRechargeComplete() {
        
        guard let info = self.payInfo else { return }
        
        let v1 = Localized.alert_title_confirm.txt
        let v2 = Localized.recharge_bank_name.txt
        let bankCode = menuManager?.menu?.getItem()?.bankCode
        let bankEng = menuManager?.menu?.getItem()?.bankNameUs ?? ""
        let v3 = Localized.recharge_bank_account.txt
        let bankAccount = UserDefaultsManager.shared.loadMyBankAccount() ?? ""
        let v4 = Localized.recharge_pay_amount.txt
        let payAmount = String(info.amount ?? 0).currency
        let v5 = Localized.won.txt
        let v6 = Localized.alert_msg_request_amount_progress.txt
        
        let contents = "\(v1)<br/><br/><b>1.\(v2): <font color=red><b>\(bankCode ?? "")(\(bankEng))</b></font></b><br/><b>2.\(v3): <font color=red><b>\(bankAccount)</b></font></b><br/><b>3.\(v4): <font color=red><b>\(payAmount)\(v5)</b></font></b><br/><br/><b>\(v6)</b>"
        
        self.showConfirmHTMLAlert(title: nil, htmlString: contents) {
            SegueUtils.openHistory(target: self)
        }
    }
    
    // 결제 요청
    private func requestRechargeAccount() {
        guard let info = self.payInfo else { return }
        guard let rcgSeq = info.rcgSeq else { return }
        guard let opCode = info.opCode else { return }
        guard let rcgType = info.rcgType else { return }
        let rechargeAmount = String(info.rechargeAmount ?? 0)
        let amount = String(info.amount ?? 0)
        let ctn = getPhoneNumber()
        
        let param = RechargeAccountRequest.Param(rcgSeq: rcgSeq,
                                                 rcgMode: "VBA",
                                                 opCode: opCode,
                                                 rcgType: rcgType,
                                                 ctn: ctn,
                                                 rcgAmt: rechargeAmount,
                                                 payAmt: amount)
        let req = RechargeAccountRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RechargeAccountResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success:
                App.shared.isRemainsInfoChanged = true
                if let type = info.payType, type == .international {
                    App.shared.isKtposRemainsInfoChange = true
                }
                
                if rcgType != "E" {
                    if let ctn = info.ctn {
                        Utils.saveRechargeNumber(ctn: ctn)
                    }
                }
                self.showAlertRechargeComplete()
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
    
    private func requestChangeAccountOnly() {
        self.showLoadingWindow()
        let req = ChangeAccountRequest(bankCd: menuManager?.menu?.getItem()?.bankCode ?? "")
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<ChangeAccountResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print(data)
                App.shared.isRemainsInfoChanged = true
                UserDefaultsManager.shared.saveBankCode(value: data.O_DATA?.bankCode)
                UserDefaultsManager.shared.saveMyBankAccount(value: data.O_DATA?.virAccountId)
                UserDefaultsManager.shared.saveBankImgName(value: data.O_DATA?.imgNm)
                
                self.fill()
                self.bankCode = data.O_DATA?.bankCode
                self.hideLoadingWindow()
            case .failure(let error):
                self.hideLoadingWindow()
                error.processError(target: self)
            }
        }
    }
    
    // 계좌 변경 요청
    private func requestChangeAccount() {
        let req = ChangeAccountRequest(bankCd: menuManager?.menu?.getItem()?.bankCode ?? "")
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<ChangeAccountResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print(data)
                App.shared.isRemainsInfoChanged = true
                UserDefaultsManager.shared.saveBankCode(value: data.O_DATA?.bankCode)
                UserDefaultsManager.shared.saveMyBankAccount(value: data.O_DATA?.virAccountId)
                UserDefaultsManager.shared.saveBankImgName(value: data.O_DATA?.imgNm)
                
                self.fill()
                self.bankCode = data.O_DATA?.bankCode
                
                guard let from = self.from else { return }
                
                switch from {
                case .cash:
                    self.showConfirmAlert(title: Localized.alert_title_confirm.txt,
                                          message: "\(Localized.alert_msg_change_account.txt)\n\(Localized.alert_msg_request_amount_progress.txt)")
                case .payment:
                    self.showAlertRechargeBefore()
                }
                
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
}

extension BankViewController {
    
    // 저장된 은행코드와 현재 픽커뷰에서 선택한 코드가 같은지 확인
    private func isSameCode() -> Bool {
        
        let um = UserDefaultsManager.shared
        
        if let savedBankCode = um.loadBankCode() {
            if let myCode = menuManager?.menu?.getItem()?.bankCode {
                return savedBankCode == myCode
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // 전화 번호 추출 (tfPhone 텍스트 필드 우선)
    private func getPhoneNumber() -> String {
        if let info = self.payInfo {
            if tfPhone.text.isNilOrEmpty {
                return info.ctn ?? ""
            } else {
                return tfPhone.text?.removeDash() ?? ""
            }
        } else {
            return ""
        }
    }
}

extension BankViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField {
        case self.tfPhone:
            tfPhone.text = StringUtils.telFormat(updatedText)
            return false
        default:
            return false
        }
    }
}

