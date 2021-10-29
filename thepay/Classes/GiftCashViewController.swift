//
//  GiftCashViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/30.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

extension GiftCashViewController: TPLocalizedController {
    func localize() {
        lblTitle.text = Localized.title_activity_gift_cash.txt
        lblCashBalance.text = Localized.contents_cash_balance.txt
        lblTitleSender.text = Localized.contents_title_sender.txt
        lblTitleAmount.text = Localized.contents_title_gift_cash_amount.txt
        lblTitleReceiver.text = Localized.contents_title_receiver.txt
        lblWarningCode.text = Localized.warning_verification_code.txt
        lblVerificationCode.text = Localized.contents_title_verification_code.txt
        
        tfSender.placeholder = Localized.hint_sender.txt
        tfAmount.placeholder = Localized.hint_gift_cash_amount.txt
        tfPhone.placeholder = "010-0000-0000"
        
        btnSMSCode.setTitle(Localized.button_send_verification_code.txt, for: .normal)
        btnConfirm.setTitle(Localized.button_send_verificaton_code_confirm.txt, for: .normal)
        btnCancel.setTitle(Localized.btn_cancel.txt, for: .normal)
        btnSend.setTitle(Localized.button_send_gift.txt, for: .normal)
        
        btnConfirm.setBackgroundColor(dis: UIColor(named: "C1C1C1") ?? .black, nor: UIColor(named: "Primary") ?? .black)
        btnSend.setBackgroundColor(dis: UIColor(named: "C1C1C1") ?? .black, nor: UIColor(named: "Primary") ?? .black)
    }
    
    func initialize() {
        requestCheckTransEvent()
        
        tfAmount.addTarget(self, action: #selector(fieldDidchanged), for: .editingChanged)
        tfPhone.delegate = self
        
        viewModel.resetTimer()
        
        bind()
    }
    
    private func bind() {
        viewModel.resetAmountText = { [weak self] in
            self?.tfAmount.text = ""
            self?.tfAmount.becomeFirstResponder()
        }
        
        viewModel.resetSenderText = { [weak self] in
            self?.tfSender.text = ""
            self?.tfSender.becomeFirstResponder()
        }
        
        viewModel.resetReceiverText = { [weak self] in
            self?.tfPhone.text = ""
            self?.tfPhone.becomeFirstResponder()
        }
    }
}

class GiftCashViewController: TPAutoCompleteViewController {
    
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var viewSend: UIView!
    
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblCashBalance: TPLabel!
    @IBOutlet weak var lblTitleSender: TPLabel!
    @IBOutlet weak var lblTitleAmount: TPLabel!
    @IBOutlet weak var lblTitleReceiver: TPLabel!
    @IBOutlet weak var lblWarningCode: TPLabel!
    @IBOutlet weak var lblVerificationCode: TPLabel!
    
    @IBOutlet weak var btnSMSCode: TPButton!
    @IBOutlet weak var btnConfirm: TPButton!
    @IBOutlet weak var btnCancel: TPButton!
    @IBOutlet weak var btnSend: TPButton!
    
    @IBOutlet weak var tfSender: TPTextField!
    @IBOutlet weak var tfAmount: TPTextField!
    @IBOutlet weak var tfAuthCode: TPTextField!
    
    @IBOutlet weak var lblCash: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    
    @IBOutlet weak var btnRecent: HistoryButton!
    @IBOutlet weak var btnContact: ContactButton!
    
    var viewModel = GiftCashViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? AddressViewController {
            self.autoComplete?.autoTableView(hidden: true)
            switch sender {
            case is HistoryButton:
                vc.currentType = .recent
            case is ContactButton:
                vc.currentType = .country
            default:
                break
            }
            vc.addressBookType = .rechargeHistory
            vc.item = { contact in
                guard let number = contact.callNumber else { return }
                self.tfPhone.text = Utils.format(phone: number)
            }
            self.view.endEditing(true)
        }
    }
    
    deinit {
        viewModel.timer?.invalidate()
    }
}

extension GiftCashViewController {
    
    private func updateDisplay(_ status: GiftCashStatus) {
        switch status {
        case .start:
            checkBalancePopup()
        case .issue(let info):
            fillData(info: info)
            startTimer()
        case .confirmed(let info):
            fillData(info: info)
        }
        
        ignoreUserInterface(status: status)
    }
    
    private func fillData(info: GiftInfo?) {
        if let seq = info?.transSeq {
            viewModel.transSeq = seq
        }
        
        tfAuthCode.text = info?.authCode
        tfSender.text = info?.sender
        tfAmount.text = info?.amount?.currency
        tfPhone.text = Utils.format(phone: info?.receiver ?? "")
    }
    
    private func ignoreUserInterface(status: GiftCashStatus) {
        switch status {
        case .start:
            viewSend.isHidden = true
            ignore(flag: true)
        case .issue:
            viewSend.isHidden = false
            lblCount.isHidden = false
            ignore(flag: true)
            ignoreBasicField(flag: false)
        case .confirmed:
            lblCount.isHidden = true
            ignore(flag: false)
        }
        
        func ignore(flag: Bool) {
            ignoreBasicField(flag: flag)
            tfAuthCode.isEnabled = flag
            
            btnConfirm.isEnabled = flag
            btnSend.isEnabled = !flag
        }
        
        func ignoreBasicField(flag: Bool) {
            tfPhone.isEnabled = flag
            tfAmount.isEnabled = flag
            tfSender.isEnabled = flag
            
            btnRecent.isEnabled = flag
            btnContact.isEnabled = flag
        }
    }
}

extension GiftCashViewController {
    
    /**
     *  초기값 설정
     */
    private func requestCheckTransEvent() {
        self.showLoadingWindow()
        let req = GiftTransCheckRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<GiftTransCheckResponse, TPError>) in
            switch response {
            case .success(let data):
                if let oData = data.O_DATA {
                    self.transCheckSuccess(data: oData)
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    /**
     *  requestCheckTransEvent 성공
     */
    private func transCheckSuccess(data: GiftTransCheckResponse.O_DATA) {
        self.checkBalance(cash: data.cash ?? 0)
        
        // start, issue, confirmed
        switch self.viewModel.getCurrentStatus(data: data) {
        case .start:
            self.updateDisplay(.start)
        case .issue:
            guard let info = GiftInfo.create(by: data) else { return }
            viewModel.changeTimer(authTime: data.authTime)
            self.updateDisplay(.issue(info: info))
        case .confirmed:
            guard let info = GiftInfo.create(by: data) else { return }
            let data = info.builder(authCode: data.authCode).builder(transSeq: data.transSeq)
            self.updateDisplay(.confirmed(info: data))
        }
    }
    
    /**
     *  - req : 대상 설정
     *  - res : 인증번호 입력
     *  - cancel : 취소
     *  - trans : 전송
     */
    private func requestTransEvent(opcode: GiftCash.OperationCode) {
        
        let data = getBasicInfo().builder(authCode: tfAuthCode.text)
        
        guard let param = viewModel.createOperationData(data: data, opcode: opcode) else {
            print("Failed Creation")
            return
        }
        self.showLoadingWindow()
        let req = GiftTransRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<GiftTransResponse, TPError>) in
            switch response {
            case .success(let data):
                if let oData = data.O_DATA {
                    self.transSuccess(data: oData)
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    /**
     *  requestTransEvent 성공
     */
    private func transSuccess(data: GiftTransResponse.O_DATA) {
        guard let type = GiftCash.OperationCode(rawValue: data.transType ?? "") else {
            return
        }
        switch type {
        case .req:
            let data = self.getBasicInfo().builder(transSeq: data.transSeq)
            viewModel.resetTimer()
            self.updateDisplay(.issue(info: data))
        case .res:
            self.showConfirmAlert(popupType: .success, title: nil, message: Localized.text_verification_complete.txt, confirm: nil)
            let data = self.getBasicInfo().builder(transSeq: self.viewModel.transSeq).builder(authCode: self.tfAuthCode.text)
            self.updateDisplay(.confirmed(info: data))
        case .cancel:
            self.navigationController?.popViewController(animated: true)
        case .trans:
            self.showConfirmAlert(popupType: .success, title: nil, message: Localized.text_success_gift_cash.txt, confirm: {
                
                // 전화번호 저장
                if let ctn = self.tfPhone.text?.removeDash() {
                    Utils.saveRechargeNumber(ctn: ctn)
                }
                
                // 히스토리 이동
                App.shared.isRemainsInfoChanged = true
                SegueUtils.openHistory(target: self, option: .cash_history)
            })
        }
    }
    
    private func startTimer() {
        countDown(isFirst: true)
        viewModel.createTimer(timer: Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true))
    }

    @objc func countDown(isFirst: Bool = false) {
        if viewModel.isOver() {
            let data = self.getBasicInfo().builder(transSeq: viewModel.transSeq)
            viewModel.resetTimer()
            self.updateDisplay(.issue(info: data))
            self.viewSend.isHidden = true
            viewModel.timer?.invalidate()
            lblCount.text = ""
        } else {
            lblCount.text = viewModel.decreaseTimer(isFirst: isFirst)
        }
    }
}

// MARK: Utilities
extension GiftCashViewController {
    
    @objc func fieldDidchanged(_ textField:UITextField) {
        textField.text = viewModel.getValidAmount(text: textField.text)
    }
    
    private func getBasicInfo() -> GiftInfo {
        
        return GiftInfo (
            sender: tfSender.text,
            amount: tfAmount.text?.replacingOccurrences(of: ",", with: ""),
            receiver: tfPhone.text?.removeDash()
        )
    }
    
    private func checkBalance(cash: Int) {
        self.viewModel.myCash = cash
        self.lblCash.text = self.viewModel.myCash.currency.won
    }
    
    private func checkBalancePopup() {
        if viewModel.noCash {
            self.showCheckAlert(popupType: .error, title: nil, message: Localized.text_gift_cash_not_enough_cash.txt) {
                // 결제화면 이동
                SegueUtils.openMenu(target: self, link: .cash, params: ["Timemachine":Timemachine.main])
            } cancel: {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func runTimer(_ time: String? = "3000") {
        print(time ?? "X")
    }
    
    private func refreshTimer() {
        viewModel.timer?.invalidate()
        viewModel.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] t in
            self?.updateCount()
        })
    }
    
    private func updateCount() {
        print("0")
    }
    
}

// MARK: IBActions
extension GiftCashViewController {
    
    /**
     *  시퀀스 생성
     */
    @IBAction func sendVerificationCode(_ sender: TPButton) {
        sender.debounce(delay: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
            
            if self.viewModel.checkData(data: self.getBasicInfo(), view: self.view) {
                self.requestTransEvent(opcode: .req)
            }
        }
    }
    
    /**
     *  코드 확인
     */
    @IBAction func confirmCode(_ sender: Any) {
        self.view.endEditing(true)
        requestTransEvent(opcode: .res)
    }
    
    /**
     *  취소
     */
    @IBAction func cancelGift() {
        self.view.endEditing(true)
        self.showCheckAlert(popupType:.error ,title: nil, message: Localized.text_check_leave_gift_page.txt) { [weak self] in
            self?.requestTransEvent(opcode: .cancel)
        } cancel: { }
    }
    
    /**
     *  전송
     */
    @IBAction func sendGift(_ sender: Any) {
        self.view.endEditing(true)
        requestTransEvent(opcode: .trans)
    }
    
    @IBAction func showContact(_ sender: Any) {
        Utils.getContactPermissions(vc: self, segue: "goContact", sender: sender)
    }
}
