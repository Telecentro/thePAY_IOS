//
//  EasyPinViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

// Android - EasyPayPwdRegFragment.java

class EasyPinViewController: EasyStepViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblPinTitle: TPLabel!
    @IBOutlet weak var svp1: UIView!
    @IBOutlet weak var svp2: UIView!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var lblCheck: TPLabel!
    @IBOutlet weak var btnReplay: UIButton!
    @IBOutlet weak var viewPin1: UIStackView!
    @IBOutlet weak var viewPin2: UIStackView!
    
    @IBOutlet var chars: [UILabel]!
    
    var pinCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func localize() {
        lblTitle.text = Localized.activity_title_auth_num_enter.txt
        lblPinTitle.text = Localized.text_guide_please_enter_easy_payment_pwd_for_payment.txt
        lblDesc.text = Localized.text_guide_please_remeber_the_pwd_you_registered.txt
        lblCheck.text = Localized.text_title_replay.txt
    }
    
    func initialize() {
        updateDisplay()
    }
    
    
    // MARK: Override
    override func pressNext() {
        registerEasy(easyPayStep: "1", easyPayAuthNum: pinCode)
    }
    
    private func updateDisplay() {
        if let pin = pinCode {
            for (i, item) in pin.enumerated() {
                chars[i].text = String(item)
            }
            svp1.isHidden = true
            svp2.isHidden = false
            lblDesc.isHidden = false
        } else {
            svp1.isHidden = false
            svp2.isHidden = true
            lblDesc.isHidden = true
        }
        
        btnReplay.isSelected = false
    }
    
    @IBAction func checkPincode(_ sender: UIButton) {
        if sender.isSelected {
            showKeypadViewController()
            lblCheck.text = Localized.text_title_replay.txt
            sender.isSelected = false
            viewPin1.isHidden = false
            viewPin2.isHidden = true
            return
        }
        
        sender.isSelected = !sender.isSelected
        viewPin1.isHidden = sender.isSelected
        viewPin2.isHidden = !sender.isSelected
        
        if sender.isSelected {
            lblCheck.text = Localized.text_title_register_again.txt
        } else {
            lblCheck.text = Localized.text_title_replay.txt
        }
    }
    
    @IBAction func showKeypad() {
        showKeypadViewController()
    }
    
    /**
     *  키패드 노출
     */
    private func showKeypadViewController() {
        guard let vc = Link.easy_pwd_auth.viewController as? EasyKeyboardViewController else { return }
        vc.useCase = "1"
        vc.password = { [weak self] pwd in
            self?.lblTitle.text = Localized.text_title_pwd_reg_complete.txt
            self?.pinCode = pwd
            self?.updateDisplay()
        }
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: 통신
    private func registerEasy(easyPayStep: String, easyPayAuthNum: String?) {
        guard let pin = easyPayAuthNum else {
            Localized.text_guide_please_enter_easy_payment_pwd_for_payment.txt.showErrorMsg(target: self.view)
            return
        }
        let params = RegisterEasyRequest.Param(
            easyPaySubSeq: emptyString,
            easyPayStep: easyPayStep,
            easyPayAuthNum: enc(str: pin),
            CREDIT_BILL_TYPE: emptyString,
            cardNum: emptyString,
            cardExpireYY: emptyString,
            cardExpireMM: emptyString,
            cardPsswd: emptyString,
            userSecureNum: emptyString
        )
        
        let req = RegisterEasyRequest(param: params)
        API.shared.upload(url: req.getAPI(), param: req.getParam(), type: .easy_pay) { (response: Swift.Result<RegisterEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    EasyRegInfo.shared.seq = String(data.O_DATA?.easyPaySubSeq ?? 0)
                    self.press?()
                } else if data.O_CODE == FLAG.E8905 || data.O_CODE == FLAG.E8906 {
                    self.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG)
                }
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
}
