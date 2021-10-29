//
//  RegisterViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/09.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum RegisterType {
    case resiter
    case modify
}

class RegisterViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblPhoneTitle: TPLabel!
    @IBOutlet weak var lblMyIdTitle: TPLabel!
    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var lblMyId: TPLabel!
    
    @IBOutlet weak var btnSMSAuth: TPButton!
    @IBOutlet weak var tfSMSAuth: UITextField!
    @IBOutlet weak var SMSView: UIView!
    @IBOutlet weak var lblPhoneUseDesc: TPLabel!
    @IBOutlet weak var svEmail: UIStackView!
    
    var sessionId: String?
    var reqPhoneNumber: String? // 인증후 전화번호 값을 수정할 수도 있기 때문에 SMS 인증문자를 받으면 reqPhoneNumber를 기록
    var authCode: String?
    var authCheck: Bool = false
    
    var type: RegisterType = .resiter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    internal func initialize() {
        setDelegate()
        updateDisplay()
    }
    
    private func updateDisplay() {
        svEmail.isHidden = true
        if type == .modify {
            svEmail.isHidden = false
            guard let ani = UserDefaultsManager.shared.loadANI() else { return }
            tfPhone.text = StringUtils.telFormat(ani)
            lblMyId.text = UserDefaultsManager.shared.loadUUID()
        }
    }
    
    internal func localize() {
        self.setupNavigationBar(type: .basic(title: nil))
        self.lblPhoneTitle.text = Localized.com_my_mobile.txt
        self.tfPhone.placeholder = Localized.hint_input_mobile.txt
        self.btnSMSAuth.setTitle(Localized.btn_send_auth.txt, for: .normal)
        self.tfSMSAuth.placeholder = Localized.hint_input_auth.txt
        self.lblPhoneUseDesc.text = Localized.warning_korea_phone.txt
//        self.lblTermsTitle.text = Localized.everytt_agreement_title.txt
//        self.lblAgreeAll.text = Localized.join_entire_agreement.txt
//        self.lblTerms.text = Localized.join_terms_of_use.txt
//        self.lblPrivacy.text = Localized.join_privacy_guidelines.txt
//        self.lblSMSAgree.text = Localized.join_sms_agreement.txt
//        self.btnDetailTerms.setTitle(Localized.join_detail.txt, for: .normal)
//        self.btnDetailPrivacy.setTitle(Localized.join_detail.txt, for: .normal)
    }
    
    private func setDelegate() {
        self.tfPhone.delegate = self
        self.tfSMSAuth.delegate = self
    }
}

extension RegisterViewController {
    /**
     *  SMS 인증
     */
    @IBAction func getSMS(_ sender: Any) {
        guard let removeDashNumber = self.tfPhone.text?.removeDash() else { return }
        self.reqPhoneNumber = removeDashNumber
        if removeDashNumber.isEmpty {
            Localized.toast_empty_phone.txt.showErrorMsg(target: self.view)
        }
        
        let req = SMSAuthRequest(phoneNumber: removeDashNumber)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<SMSAuthResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print(data)
                self.sessionId = data.O_DATA?.sessionId
                self.SMSView.isHidden = false
                self.tfSMSAuth.text = ""
                self.authCheck = true
                self.view.endEditing(true)
                self.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: Localized.alert_msg_input_authnumber.txt)
            case .failure(let error):
                error.showErrorMsg(target: self.view)
            }
        }
    }
    
    /**
     *  회원가입
     */
    @IBAction func confirm(_ sender: Any) {
        if self.validateRegisterInfo() == false {
            return
        }
        
        guard let saveNumber = tfPhone.text?.removeDash() else { return }
        if saveNumber == self.reqPhoneNumber {  // 입력됐던 휴대폰번호 == 요청한 휴대폰번호
            self.authCode = self.tfSMSAuth.text?.trim()
            guard let id = self.sessionId, let code = self.authCode else { return }
            
            let data = SMSAuthConfirmRequest.SMSAuthConfirmData(SESSION_ID: id, AUTH_CODE: code, ANI: saveNumber)
            
            // 2021.1.5 추가
            UserDefaultsManager.shared.saveSMSSessionID(value: id)
            UserDefaultsManager.shared.saveANI2(value: saveNumber)
            // 2021.1.5 추가
            
            let req = SMSAuthConfirmRequest(data: data)
            API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<SMSAuthConfirmResponse, TPError>) -> Void in
                guard let self = self else { return }
                switch response {
                case .success(let data):
                    print(data)
                    
                    // 회원가입값 저장
                    UserDefaultsManager.shared.saveJoin(value: true)
                    
                    UserDefaultsManager.shared.saveSMSFlag(value: "Y")
                    UserDefaultsManager.shared.saveANI(value: saveNumber)
                    App.shared.intro = .update
                    self.navigationController?.backToIntro()
                case .failure(let error):
                    error.showErrorMsg(target: self.view)
                }
            }
            
        } else {
            Localized.toast_invalid_format_phone.txt.showErrorMsg(target: self.view)
            return
        }
    }
    
    func validateRegisterInfo() -> Bool {
        //          TODO: 이메일 체크
        //        if tfSMSAuth.text?.isEmail ?? false {
        //            var dic = Utils.getSnsInfo()
        //            dic?.updateValue(self.tfEmail, forKey: "email")
        //            print(dic)
        //        } else {
        //            Localized.eload_email_valid_check_error.txt.showErrorMsg(target: self.view)     // 올바르지 않은 이메일 형식입니다
        //        }
        if self.authCheck == false {
            Localized.toast_do_req_authnumber.txt.showErrorMsg(target: self.view)           // 인증번호를 요청해주세요
            return false
        }
        
        if let authString = self.tfSMSAuth.text?.trim() {
            if authString.isEmpty {
                Localized.toast_empty_authnumber.txt.showErrorMsg(target: self.view)            // 인증번호 입력해주세요
                return false
            }
        }
        
        return true
    }
    
}

/**
 *  텍스트 필드 델리게이터
 */
extension RegisterViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField {
        case self.tfPhone:
            tfPhone.text = StringUtils.telFormat(updatedText)
            return false
        case self.tfSMSAuth:
            tfSMSAuth.text = Utils.format(phone: updatedText, mask: "XXXX")
            return false

        default:
            return false
        }
    }
}


