//
//  EasyBankViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

class EasyBankViewController: EasyStepViewController, TPLocalizedController {
    
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblDepositorTitle: TPLabel!
    @IBOutlet weak var lblBankTitle: TPLabel!
    @IBOutlet weak var lblAccountTitle: TPLabel!
    @IBOutlet weak var tfBankAccount: TPTextField!
    @IBOutlet weak var tfDepositor: TPTextField!
    @IBOutlet weak var tfBank: TPTextField!
    @IBOutlet weak var lblDesc: TPLabel!
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
    
    var isFirst = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirst {
            isFirst = false
            initialize()
        }
    }
    
    func localize() {
        lblTitle.text = Localized.text_title_payment_info_enter.txt
        lblDepositorTitle.text = Localized.com_my_depositor.txt
        lblBankTitle.text = Localized.com_my_bank.txt
        lblAccountTitle.text = Localized.recharge_bank_account.txt
        lblDesc.text = Localized.text_guide_warning_for_use_other_account.txt
        
        tfDepositor.placeholder = Localized.hint_account_holder.txt
        tfBankAccount.placeholder = Localized.hint_account_num.txt
    }
    
    func initialize() {
        preEazy()
        
        var config = SPMenuConfig()
        config.type = .fullImage
        menuManager = MenuManager(config: config)
        menuManager?.menu?.selectItem = {
            self.ivBankLogo.image = UIImage(named: $0?.imgNm ?? "bank_11.png")
            self.bankCode = $0?.bankCode
            self.emptyContents = false
        }
    }
    
    @IBAction func showPicker(_ sender: UIButton) {
        menuManager?.show(sender: sender)
    }
    
    private func validateParams() -> Bool{
        if !validateDepositor() {
            return false
        }
        
        if !validateAccount() {
            return false
        }
        
        return true
    }
    
    private func validateDepositor() -> Bool {
        if self.tfDepositor.text.isNilOrEmpty {
            "toast_msg_check_account_holder".showErrorMsg(target: self.view)
            return false
        } else {
            return true
        }
    }
    
    private func validateAccount() -> Bool {
        if self.tfBankAccount.text.isNilOrEmpty {
            "toast_check_account_num".showErrorMsg(target: self.view)
            return false
        } else {
            return true
        }
    }
    
    override func pressNext() {
        if validateParams() {
            self.requesthAuthAccount()
        }
    }
    
}

extension EasyBankViewController {
    
    // 선택한 간편결제 SEQ
    // 간편결제에 필요한 값 미리받기
    private func preEazy() {
        let params = PreEasyRequest.Param(easyPaySubSeq: "")
        let req = PreEasyRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<PreEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print(data.O_DATA?.bankList ?? "")
                var list:[SubPreloadingResponse.bankList] = []
                for i in data.O_DATA?.bankList ?? [] {
                    list.append(SubPreloadingResponse.bankList(sortNo: i.sortNo, bankCode: i.bankCode, bankNameKr: i.bankNameKr, bankNameJp: i.bankNameJp, imgNm: i.imgNm, bankNameCn: i.bankNameCn, bankNameUs: i.bankNameUs))
                }
                self.menuManager?.updateData(data: MenuDataConverter.bank(value: list))
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
    
    
    private func requesthAuthAccount() {
        guard let bankCd = menuManager?.menu?.getItem()?.bankCode else { return }
        let account = tfBankAccount.text ?? ""
        let depositor = tfDepositor.text ?? ""
        let params = AuthAccountRequest.Param(
            opCode: "req",
            acctBankCd: bankCd,             // 은행코드값
            acctBankNum: enc(str: account),            // 계좌번호
            acctHolder: depositor,             // 예금주명
            acctAuthCd: ""              // 은행인증시에는 인증문자 값 빈 값으로 처리
        )
        
        showLoading?()
        let req = AuthAccountRequest(param: params)
        API.shared.upload(url: req.getAPI(), param: req.getParam(), type: .easy_pay) { (response: Swift.Result<AuthAccountResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    self.press?()
                } else if data.O_CODE == FLAG.E8905 || data.O_CODE == FLAG.E8906 {
                    self.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG)
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoading?()
        }
    }
    
}
