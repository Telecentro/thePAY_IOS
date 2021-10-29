//
//  CardDetailViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/08.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class CardDetailViewController: TPBaseViewController, TPLocalizedController {

    @IBOutlet weak var ivCardImage: UIImageView!
    @IBOutlet weak var svpCard: TPCardView!
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var btnConfirm: TPButton!
    
    var cardImage: UIImage?
    var delegate: CaptureDelegate?
    var cameraType: CameraType = .creditCardFront
    
    var cm = CardManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        lblTitle.text = Localized.safe_card_capture_credit_card_input_info_title.txt
        btnConfirm.setTitle(Localized.btn_confirm.txt, for: .normal)
    }
    
    func initialize() {
        self.ivCardImage.image = cardImage
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupDelegate()
        loadSavedCardInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.svpCard.tfCard1.becomeFirstResponder()
    }
    
    /* 델리게이터 이미지 전송 */
    private func sendImage() {
        if let img = self.cardImage {
            self.delegate?.sendImage(image: img, type: self.cameraType, cardInfo: SafeCardBeforeData.SafeCardInfo(insert: svpCard.getCardNum(), detect: ""))
        }
    }
    
    /* 확인 */
    @IBAction func confirm(_ sender: Any) {
        if !checkData() {
            return
        }
        
        switch cameraType {
        case .creditCardFront:
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.sendImage()
            }
        case .cardScan:
            self.sendImage()
            guard let count = self.navigationController?.viewControllers.count else { return }
            if let prev = self.navigationController?.viewControllers[count - 3] {
                self.navigationController?.popToViewController(prev, animated: true)
            }
        default:
            break
        }
    }
    
    /* 취소 */
    @IBAction func close(_ sender: Any) {
        self.view.endEditing(true)
        switch cameraType {
        case .creditCardFront:
            self.dismiss(animated: true, completion: nil)
        case .cardScan:
            guard let count = self.navigationController?.viewControllers.count else { return }
            if let prev = self.navigationController?.viewControllers[count - 3] {
                self.navigationController?.popToViewController(prev, animated: true)
            }
        default:
            break
        }
    }
}

extension CardDetailViewController: UITextFieldDelegate, TPTextFieldDelegate {
    
    private func loadSavedCardInfo() {
        cm.cardType = UserDefaultsManager.shared.loadRecentCardType()
        if cm.isShorterCard() {
            svpCard.svpCardType1.isHidden = true
            svpCard.svpCardType2.isHidden = false
        } else {
            svpCard.svpCardType1.isHidden = false
            svpCard.svpCardType2.isHidden = true
        }
        
        if cm.isShorterCard() {
            svpCard.tfCardShort1.text = ""
            svpCard.tfCardShort2.text = ""
            svpCard.tfCardShort3.text = ""
        } else {
            svpCard.tfCard1.text = ""
            svpCard.tfCard2.text = ""
            svpCard.tfCard3.text = ""
            svpCard.tfCard4.text = ""
        }
    }
    
    private func setupDelegate() {
        
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
        textField.background = UIImage(named: "input_box_44_44")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.background = UIImage(named: "select_44")
    }
    
    func backspace(textField: TPDelegateTextField) {
        switch textField {
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
            if !jump4(textField: textField, string: string, range: range, target: nil) {
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
            switch cm.cardType {
            case .CARD_TYPE_AMERICAN_EXPRESS_SHORTER:
                if !jump5(textField: textField, string: string, range: range, target: nil) {
                    return false
                }
            case .CARD_TYPE_DINERS_CLUB_SHORT:
                if !jump4(textField: textField, string: string, range: range, target: nil) {
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
        
        if cm.isShorterCard() {
            if svpCard.tfCardShort1.text.isNilOrEmpty ||
                svpCard.tfCardShort2.text.isNilOrEmpty ||
                svpCard.tfCardShort3.text.isNilOrEmpty {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                return false
            }
            
            if svpCard.tfCardShort1.text?.count != 4 || svpCard.tfCardShort2.text?.count != 6 {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                return false
            }
            
            if (svpCard.tfCardShort3.text?.count ?? 0) < 3 {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                return false
            }
        } else {
            if svpCard.tfCard1.text.isNilOrEmpty ||
                svpCard.tfCard2.text.isNilOrEmpty ||
                svpCard.tfCard3.text.isNilOrEmpty ||
                svpCard.tfCard4.text.isNilOrEmpty {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                return false
            }
            
            if svpCard.tfCard1.text?.count != 4 || svpCard.tfCard2.text?.count != 4 || svpCard.tfCard3.text?.count != 4 {
                Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                return false
            }
            
            if cm.cardType == .CARD_TYPE_JCB_SHORT {
                if (svpCard.tfCard4.text?.count ?? 0) < 3 {
                    Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                    return false
                } else {
                    if (svpCard.tfCard4.text?.count ?? 0) != 4 {
                        Localized.toast_empty_card_number.txt.showErrorMsg(target: self.view.superview)
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    
}
