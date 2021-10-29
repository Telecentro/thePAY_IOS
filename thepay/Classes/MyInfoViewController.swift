//
//  MyInfoViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/07.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import SPMenu

class MyInfoViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblMyInfoTitle: TPLabel!         // 내정보
    @IBOutlet weak var lblMyInfoMainTitle: TPLabel!    // 내정보
    @IBOutlet weak var lblPaymentInfoTitle: TPLabel!    // 결제정보
    @IBOutlet weak var lblMyPhoneTitle: TPLabel!        // 내연락처
    @IBOutlet weak var lblMyIdTitle: TPLabel!           // 내아이디
    @IBOutlet weak var lblMyCashTitle: TPLabel!         // 99pay 캐쉬
    @IBOutlet weak var lblMyBankTitle: TPLabel!         // 내은행
    @IBOutlet weak var lblMyAccountTitle: TPLabel!      // 내은행계좌
    @IBOutlet weak var lblMyDepositorTitle: TPLabel!    // 예금주
    
    @IBOutlet weak var lblPhoneNumber: TPLabel!
    @IBOutlet weak var lblIdentifire: TPLabel!
    @IBOutlet weak var lblAmount: TPLabel!
    @IBOutlet weak var lblAccount: TPLabel!
    @IBOutlet weak var lblDepositor: TPLabel!
    @IBOutlet weak var imgAccount: UIImageView!
    @IBOutlet weak var btnInfoChange: TPButton!
    @IBOutlet weak var btnBankChange: TPButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tfBank: TPTextField!
    
    @IBOutlet weak var ivLoginType: UIImageView!
    
    @IBOutlet weak var viewAddEasyPay: UIView!
    @IBOutlet weak var viewModifyEasyPay: UIView!
    
    @IBOutlet weak var lblEasyPayTitle: TPLabel!
    @IBOutlet weak var lblNewEasyPay: TPLabel!
    @IBOutlet weak var lblMyEasyPayment: TPLabel!
    @IBOutlet weak var btnWithdraw: TPButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func localize() {
        lblMyInfoTitle.text = Localized.menu_my_page.txt
        lblMyInfoMainTitle.text = Localized.mypage_title_my_info.txt
        lblPaymentInfoTitle.text = Localized.mypage_title_pay_info.txt
        lblMyDepositorTitle.text = Localized.com_my_depositor.txt
        lblMyPhoneTitle.text = Localized.com_my_mobile.txt
        lblMyIdTitle.text = Localized.com_my_id.txt
        lblMyCashTitle.text = Localized.com_my_cash.txt
        lblMyBankTitle.text = Localized.com_my_bank.txt
        lblMyAccountTitle.text = Localized.com_my_account.txt
        lblEasyPayTitle.text = Localized.activity_title_easy_payment_card_info.txt
        lblNewEasyPay.text = Localized.text_title_easy_payment_add.txt
        lblMyEasyPayment.text = Localized.text_title_my_easy_payment.txt
        
        btnBankChange.setTitle(Localized.btn_account_change.txt, for: .normal)
        btnInfoChange.setTitle(Localized.btn_logout.txt, for: .normal)
        btnWithdraw.setTitle(Localized.btn_withdrawal.txt, for: .normal)
        lblBlankBank.text = Localized.toast_select_bank.txt
    }
    
    func initialize() {
        updatePayInfo()
        ivLoginType.image = Utils.getLoginTypeImage()
        
        var config = SPMenuConfig()
        config.type = .fullImage
        menuManager = MenuManager(callFirst: false, config: config)
        menuManager?.menu?.selectItem = {
            self.ivBankLogo.image = UIImage(named: $0?.imgNm ?? "bank_11.png")
            self.bankCode = $0?.bankCode
            self.emptyContents = false
        }
        
        requestSubPreloading(opCode: .bankList) { [weak self] (data:[Any]?) -> Void in
            guard let self = self else { return }
            let d = App.shared.bankList
            self.menuManager?.updateData(data: MenuDataConverter.bank(value: d))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewAddEasyPay.isHidden = false
        self.viewModifyEasyPay.isHidden = false
        
        listEasy()
    }
    
    func updatePayInfo() {
        guard let ani = UserDefaultsManager.shared.loadANI() else { return }
        lblPhoneNumber.text = StringUtils.telFormat(ani)
        lblIdentifire.text = UserDefaultsManager.shared.loadUUID()
        lblAmount.text = UserDefaultsManager.shared.loadMyCash()?.currency.won
        let manager = UserDefaultsManager.shared
        guard let result = manager.loadBankImgName() else { return }
        
        if manager.loadMyBankAccount().isNilOrEmpty {
            lblAccount.text = ""
            lblDepositor.text = ""
            ivBankLogo.image = UIImage(named: result)
            imgAccount.image = UIImage(named: result)
            emptyContents = true
        } else {
            lblAccount.text = UserDefaultsManager.shared.loadMyBankAccount()
            lblDepositor.text = Localized.company_depositer.txt
            ivBankLogo.image = UIImage(named: result)
            imgAccount.image = UIImage(named: result)
            emptyContents = false
        }
    }
    
    
    
    // 계좌 복사
    @IBAction func pressCopyAccount(_ sender: Any) {
       Localized.toast_virtual_account_copy_paste.txt.showErrorMsg(target: self.view)
       UIPasteboard.general.string = self.lblAccount.text?.removeDash()
    }
    
    // 은행 변경
    @IBAction func pressBankChange(_ sender: Any) {
        tfBank.resignFirstResponder()

        if isNotSameBankCode() {
            self.showCheckAlert(title: Localized.alert_title_confirm.txt,
                                message: Localized.alert_msg_change_account_preview.txt,
                                confirm: { [weak self] in
                self?.requestChangeAccount()
            }, cancel: nil)
        }
    }
    
    
    func isNotSameBankCode() -> Bool {
        if let saveCode = UserDefaultsManager.shared.loadBankCode() {
            return saveCode != self.bankCode
        } else {
            return true
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        self.showCheckAlert(title: Localized.btn_logout.txt, message: Localized.alert_msg_logout.txt) { [weak self] in
            UserDefaultsManager.shared.clearAll()
            self?.navigationController?.backToIntro()
        } cancel: { }
    }
    
    @IBAction func showWithdrawal(_ sender: Any) {
        self.showWithdrawalAlert { [weak self] s in
            self?.withdrawal(code: s)
        } cancel: {
            print("cancel")
        }
    }
    
    private func withdrawal(code: String) {
        self.showLoadingWindow()
        let req = WithdrawalRequest(param: WithdrawalRequest.Param(withDrawResaon: code))
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<WithdrawalResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success:
                UserDefaultsManager.shared.clearAll()
                self.navigationController?.backToIntro()
            case .failure(let error):
                error.processError(target: self)
            }
            self.hideLoadingWindow()
        }
    }
    
    @IBAction func pressBankChoose(_ sender: UIView) {
        menuManager?.show(sender: sender)
    }
}

// MARK: - 확장, 통신
extension MyInfoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        if let vc = segue.destination as? RegisterViewController {
//            vc.type = .modify
//        }
    }
    
    // 통신
    func requestChangeAccount() {
        tfBank.resignFirstResponder()
        let req = ChangeAccountRequest(bankCd: menuManager?.menu?.getItem()?.bankCode ?? "")
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<ChangeAccountResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                App.shared.isRemainsInfoChanged = true
                UserDefaultsManager.shared.saveBankCode(value: data.O_DATA?.bankCode)
                UserDefaultsManager.shared.saveMyBankAccount(value: data.O_DATA?.virAccountId)
                UserDefaultsManager.shared.saveBankImgName(value: data.O_DATA?.imgNm)
                
                guard let img = data.O_DATA?.imgNm else { return }
                self.imgAccount.image = UIImage(named: img)
                self.ivBankLogo.image = UIImage(named: img)
                self.lblAccount.text = data.O_DATA?.virAccountId
                self.showConfirmAlert(title: "", message: Localized.alert_msg_change_account.txt)
                
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
}

// MARK: - EasyPay
extension MyInfoViewController {
    // data missmatch (확인)
    // 간편결제 등록정보 보기
    private func listEasy() {
        let params = ListEasyRequest.Param(opCode: FLAG.A)
        let req = ListEasyRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<ListEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                self.successEasyPayList(list: data.O_DATA?.easyPayList)
            case .failure(let error):
                switch error {
                case .expired(let code, _):
                    self.failureEasyPayList(code)
                default: break
                }
            }
        }
    }
    
    private func successEasyPayList(list: [ListEasyResponse.easyPayList]?) {
        if list?.count == 0 {
            self.visiableCardStatus(hasCard: false)
        } else {
            for item in list ?? [] {
                if self.hasCardProccessStatus(status: item.cardStatus) {
                    self.visiableCardStatus(hasCard: true)
                } else {
                    print("???")
                }
            }
        }
    }
    
    private func failureEasyPayList(_ code: String) {
        if code == "8905" || code == "8906" {
            self.visiableCardStatus(hasCard: true)
        }
    }
    
    private func visiableCardStatus(hasCard: Bool) {
        self.viewAddEasyPay.isHidden = hasCard
        self.viewModifyEasyPay.isHidden = !hasCard
    }
    
    private func hasCardProccessStatus(status: String?) -> Bool {
        guard let s = status else { return false }
        guard let code = CardStatus(rawValue: s) else { return false }
        switch code {
        case .typing, .complete, .waiting, .processing:
            return true
        case .failure:
            return false
        }
    }
    
    @IBAction func addNewCard() {
        performSegue(withIdentifier: Segue.EasyPayInfo, sender: nil)
    }
    
    @IBAction func showCardList() {
        preEazy()
    }
    
    
    
    // 선택한 간편결제 SEQ
    // 간편결제에 필요한 값 미리받기
    private func preEazy() {
        let params = PreEasyRequest.Param(easyPaySubSeq: "")
        let req = PreEasyRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<PreEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                // - 최초 : 약관 페이지 호출
                // - 두번째 : 비번인증 페이지 호출
                // - 카드 5개 초과시 팝업표시 -> 내정보로 이동
                if data.O_CODE == "0000" {
                    SegueUtils.parseMoveLink(target: self, link: "thepay://page.easypay_pwd_auth?use_case=3")
                    return
                }

                // 카드 개수 제한에 걸리는 경우 팝업표시 후 서버에서 내려주는 스키마 값대로 이동(내정보)
                switch data.O_DATA?.msgBoxGubun?.lowercased() ?? "" {
                case "alert":
                    self.showCheckAlert(title: "Notice", message: data.O_MSG) {
                        if let moveLink = data.O_DATA?.moveLink {
//                            SegueUtils.parseMoveLink(target: self, link: moveLink)
                            App.shared.moveLink = moveLink
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    } cancel: {
                        if let moveLink = data.O_DATA?.moveLink {
                            App.shared.moveLink = moveLink
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                case "toast":
                    data.O_MSG.showErrorMsg(target: self.view)
                default:
                    // 카드 개수 제한에 안 걸리는 경우
                    if let moveLink = data.O_DATA?.moveLink {
                        SegueUtils.parseMoveLink(target: self, link: moveLink)
                    }
                    break
                }
            case .failure(let error):
                print(error)
                // 8905, 8906 에러처리
            }
        }
    }
}
