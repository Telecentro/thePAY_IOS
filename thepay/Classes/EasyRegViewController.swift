//
//  EasyRegViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit


class EasyRegViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var btnStep1: TPButton!
    @IBOutlet weak var btnStep2: TPButton!
    @IBOutlet weak var btnStep3: TPButton!
    @IBOutlet weak var btnStep4: TPButton!
    @IBOutlet weak var btnNext: TPButton!
    
    @IBOutlet weak var viewStep1: UIView!
    @IBOutlet weak var viewStep2: UIView!
    @IBOutlet weak var viewStep3: UIView!
    @IBOutlet weak var viewStep4: UIView!
    @IBOutlet weak var viewAuth: UIView!
    
    var prevStep2cardPhothMap:[String:String]?
    var prevStep3cardInfoMap:[String:String]?
    
    
    // Step2 사진 새로 찍었는지 체크하는 구분값
    var changedImage:[String:Bool] = [
        FILE_NAME.FILE_CREDIT_CARD_FRONT:false,
        FILE_NAME.FILE_CREDIT_CARD_BACK:false,
        FILE_NAME.FILE_ALINE_CARD_FRONT:false,
        FILE_NAME.FILE_ALINE_CARD_BACK:false,
        FILE_NAME.FILE_PASSPORT:false,
        FILE_NAME.FILE_SELF_CAMERA:false,
        FILE_NAME.FILE_SIGNATURE:false
    ]
    
    // Step3 카유비생 입력값 변경 체크하는 구분값
    var changedCardInfo:[String:Bool] = [
        CARD_INFO.NUMBER_1:false,
        CARD_INFO.NUMBER_2:false,
        CARD_INFO.NUMBER_3:false,
        CARD_INFO.NUMBER_4:false,
        CARD_INFO.NUMBER_2_EXPRESS:false,
        CARD_INFO.NUMBER_3_EXPRESS:false,
        CARD_INFO.MONTH:false,
        CARD_INFO.YEAR:false,
        CARD_INFO.PASSWORD:false,
        CARD_INFO.BIRTH:false,
    ]
    
    var firstStep: EasyStep = .step1
    var step: EasyStep = .step1
    var disabledStep:[EasyStep] = []
    
    var easyPinViewController:EasyPinViewController?
    var easyPhotoViewController:EasyPhotoViewController?
    var easyCardViewController:EasyCardViewController?
    var easyBankViewController:EasyBankViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func localize() {
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
    }
    
    func initialize() {
        EasyRegInfo.shared.seq = nil
        setupButtons()
        setTabType()
        updateDisplay()
        createBackButton()
        resetChangedImage()
        resetChangedCardInfo()
    }
    
    private func resetChangedImage() {
        for (key, _) in changedImage {
            changedImage[key] = false
        }
    }
    
    private func resetChangedCardInfo() {
        for (key, _) in changedCardInfo {
            changedCardInfo[key] = false
        }
    }
    
    private func setTabType() {
        if let step = EasyStep(rawValue: self.params?["tab_type"] as? String ?? "") {
            firstStep = step
            self.step = step
        }
        
        if let seq = self.params?[UDP.seq] as? String {
            EasyRegInfo.shared.seq = seq
        }
    }
    
    deinit {
        EasyRegInfo.shared.seq = nil
    }
    
    private func next() {
        switch step {
        case .step1:
            if let vc = easyPinViewController {
                vc.press = { [weak self] in
                    self?.step = .step2
                    self?.updateDisplay()
                }
                
                vc.pressNext()
            }
        case .step2:
            if let vc = easyPhotoViewController {
                vc.press = { [weak self] in
                    self?.step = .step3
                    self?.updateDisplay()
                }
                
                if isChangedPhoto() || EasyRegInfo.shared.isNew() {
                    vc.pressNext()
                } else {
                    self.step = .step3
                    self.updateDisplay()
                }
            }
        case .step3:
            if let vc = easyCardViewController {
                vc.press = { [weak self] in
                    self?.step = .step4
                    self?.updateDisplay()
                }
                
                vc.pressNext()
            }
        case .step4:
            if let vc = easyBankViewController {
                vc.press = { [weak self] in
                    self?.step = .step5
                    self?.updateDisplay()
                }
                vc.pressNext()
            }
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EasyPhotoViewController {
            easyPhotoViewController = vc
            vc.changedImage = { [weak self] key in
                if key.isEmpty {
                    self?.resetChangedImage()
                    self?.updateDisplay()
                } else {
                    self?.changedImage.updateValue(true, forKey: key)
                    self?.updateDisplay()
                }
            }
            
            vc.showLoading = {
                self.showLoadingWindow()
            }
            
            vc.hideLoading = {
                self.hideLoadingWindow()
            }
            
        }
        
        if let vc = segue.destination as? EasyPinViewController {
            easyPinViewController = vc
        }
        
        if let vc = segue.destination as? EasyCardViewController {
            easyCardViewController = vc
            
            vc.success = { [weak self] in
                self?.performSegue(withIdentifier: "Success", sender: nil)
            }
            
            vc.showAuth = { [weak self] in
                self?.viewAuth.isHidden = false
            }
            
            vc.changedCardInfo = { [weak self] key in
                if key.isEmpty {
                    self?.resetChangedCardInfo()
                    self?.updateDisplay()
                } else {
                    self?.changedCardInfo.updateValue(true, forKey: key)
                    self?.updateDisplay()
                }
            }
        }
        
        
        if let vc = segue.destination as? EasyBankViewController {
            easyBankViewController = vc
            vc.press = { [weak self] in
                self?.next()
            }
        }
        
        if let vc = segue.destination as? EasyAuthViewController {
            vc.success = { [weak self] in
                self?.performSegue(withIdentifier: "Success", sender: nil)
            }
        }
    }
    
    @IBAction func next(sender: TPButton) {
        print("next()")
        next()
    }
    
    @IBAction func pressStep1(_ sender: Any) {
        pressButton(newStep: .step1)
    }
    
    @IBAction func pressStep2(_ sender: Any) {
        self.easyCardViewController?.view.endEditing(true)
        pressButton(newStep: .step2)
    }
    
    @IBAction func pressStep3(_ sender: Any) {
        pressButton(newStep: .step3)
    }
    
    @IBAction func pressStep4(_ sender: Any) {
        pressButton(newStep: .step4)
    }
    
    private func pressButton(newStep: EasyStep) {
        if canOpen(step: newStep) {
            step = newStep
            updateDisplay()
        }
    }
    
    private func canOpen(step: EasyStep) -> Bool {
        for i in disabledStep {
            if i == step {
                return false
            }
        }
        
        return true
    }
    
}





















extension EasyRegViewController {
    
    /**
     *  뒤로가기 버튼 생성
     */
    private func createBackButton() {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        btn.imageEdgeInsets = UIEdgeInsets(top: -5, left: -22, bottom: 5, right: 22)
        btn.setImage(UIImage(named: "btn_left"), for: .normal)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let backBtn = UIBarButtonItem(customView: btn)
        backBtn.title = ""
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    /**
     *  뒤로가기 액션
     */
    @objc private func goBack() {
        self.showCheckAlert(title: Localized.alert_title_easy_payment_reg_cancle.txt, message: Localized.alert_msg_easy_payment_reg_cancle.txt) {
            self.navigationController?.popToRootViewController(animated: true)
        } cancel: { }
    }
    
    private func updateDisplay() {
        switch step {
        case .step1:
            viewStep1.isHidden = false
            viewStep2.isHidden = true
            viewStep3.isHidden = true
            viewStep4.isHidden = true
            btnStep1.isSelected = true
            btnStep2.isSelected = false
            btnStep3.isSelected = false
            btnStep4.isSelected = false
            btnStep1.isUserInteractionEnabled = false
            btnStep2.isUserInteractionEnabled = false
            btnStep3.isUserInteractionEnabled = false
            btnStep4.isUserInteractionEnabled = false
        case .step2:
            viewStep1.isHidden = true
            viewStep2.isHidden = false
            viewStep3.isHidden = true
            viewStep4.isHidden = true
            btnStep1.isSelected = false
            btnStep2.isSelected = true
            btnStep3.isSelected = false
            btnStep4.isSelected = false
            btnStep1.isUserInteractionEnabled = false
            btnStep2.isUserInteractionEnabled = false
            if EasyRegInfo.shared.isNew() {
                btnStep3.isUserInteractionEnabled = false
            } else {
                btnStep3.isUserInteractionEnabled = !isChangedPhoto()
            }
            btnStep4.isUserInteractionEnabled = !isChangedPhoto() && firstStep == .step4
        case .step3:
            viewStep1.isHidden = true
            viewStep2.isHidden = true
            viewStep3.isHidden = false
            viewStep4.isHidden = true
            btnStep1.isSelected = false
            btnStep2.isSelected = false
            btnStep3.isSelected = true
            btnStep4.isSelected = false
            btnStep1.isUserInteractionEnabled = false
            btnStep2.isUserInteractionEnabled = !isChangedCardInfo()
            btnStep3.isUserInteractionEnabled = false
            btnStep4.isUserInteractionEnabled = !isChangedCardInfo() && firstStep == .step4
        case .step4:
            viewStep1.isHidden = true
            viewStep2.isHidden = true
            viewStep3.isHidden = true
            viewStep4.isHidden = false
            btnStep1.isSelected = false
            btnStep2.isSelected = false
            btnStep3.isSelected = false
            btnStep4.isSelected = true
            btnStep1.isUserInteractionEnabled = false
            btnStep2.isUserInteractionEnabled = !isChangedPhoto()
            btnStep3.isUserInteractionEnabled = !isChangedCardInfo()
            btnStep4.isUserInteractionEnabled = true
            break
        case .step5:
            viewAuth.isHidden = false
            break
        }
    }
    
    private func isChangedPhoto() -> Bool {
        for (_, value) in changedImage {
            if value == true {
                return true
            }
        }
        
        return false
    }
    
    private func isChangedCardInfo() -> Bool {
        for (_, value) in changedCardInfo {
            if value == true {
                return true
            }
        }
        
        return false
    }
    
    private func setupButtons() {
        if let defaultColor = UIColor(named: "e9e9e9") {
            btnStep1.setTitleColor(UIColor.gray, for: .normal)
            btnStep1.setTitleColor(UIColor.black, for: .selected)
            btnStep1.setBackgroundImage(UIImage(color: defaultColor), for: .normal)
            btnStep1.setBackgroundImage(UIImage(color: UIColor.white), for: .selected)
            
            btnStep2.setTitleColor(UIColor.gray, for: .normal)
            btnStep2.setTitleColor(UIColor.black, for: .selected)
            btnStep2.setBackgroundImage(UIImage(color: defaultColor), for: .normal)
            btnStep2.setBackgroundImage(UIImage(color: UIColor.white), for: .selected)
            
            btnStep3.setTitleColor(UIColor.gray, for: .normal)
            btnStep3.setTitleColor(UIColor.black, for: .selected)
            btnStep3.setBackgroundImage(UIImage(color: defaultColor), for: .normal)
            btnStep3.setBackgroundImage(UIImage(color: UIColor.white), for: .selected)
            
            btnStep4.setTitleColor(UIColor.gray, for: .normal)
            btnStep4.setTitleColor(UIColor.black, for: .selected)
            btnStep4.setBackgroundImage(UIImage(color: defaultColor), for: .normal)
            btnStep4.setBackgroundImage(UIImage(color: UIColor.white), for: .selected)
        }
    }
    
}
