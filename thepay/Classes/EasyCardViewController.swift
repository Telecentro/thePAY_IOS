//
//  EasyCardViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

// Android - EasyPayCardInfoRegFragment.java

extension String {
    func append(params:[String: String]) -> String {
        for (key, value) in params {
            print(key, value)
        }
        
        return ""
    }
}


class EasyCardViewController: EasyStepViewController, TPLocalizedController {
    @IBOutlet weak var lblCardNumTitle: TPLabel!
    @IBOutlet weak var lblShowCheckBoxTitle: TPLabel!
    @IBOutlet weak var lblExpiredDateTitle: TPLabel!
    @IBOutlet weak var lblValidThruTitle: UILabel!
    @IBOutlet weak var lblPwdTitle: TPLabel!
    @IBOutlet weak var lblBirthTitle: TPLabel!
    @IBOutlet weak var lblBirthEx: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    
    @IBOutlet weak var lblImageCardNumber: TPLabel!
    @IBOutlet weak var lblImageCardExpiredDate: TPLabel!
    @IBOutlet weak var svpCard: TPCardView!
    
    @IBOutlet weak var tfMonth: TPTextField!
    @IBOutlet weak var tfYear: TPTextField!
    @IBOutlet weak var tfBirth: TPTextField!
    @IBOutlet weak var tfPasswd: TPDelegateTextField!
    @IBOutlet weak var svpPassword: UIStackView!
    @IBOutlet weak var svpBirth: UIStackView!
    
    @IBOutlet weak var btnExCardNum: TPButton!
    @IBOutlet weak var btnExValidNum: TPButton!
    @IBOutlet weak var btnForignerCard: TPButton!
    @IBOutlet weak var btnShowCardNumber: UIButton!
    private var vm = CardViewModel()
    
    
    var tabNext:(()->Void)?
    
    var success:(()->Void)?
    var showAuth:(()->Void)?
    
    var changedCardInfo:((String)->Void)?
    
    var easyPayBillType = false // false : 18 카유, true : 13 카유비생
    
    var lastString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func localize() {
        lblCardNumTitle.text = Localized.recharge_card_number.txt
        lblBirthTitle.text = Localized.alert_msg_birth_6_digit.txt
        lblPwdTitle.text = Localized.recharge_card_pwd.txt
        lblExpiredDateTitle.text = Localized.recharge_card_exp_date.txt
        lblShowCheckBoxTitle.text = Localized.checkbox_show_card_num.txt
        lblValidThruTitle.text = "VALID\nTHRU"
        lblDesc.text = Localized.warning_card.txt
        lblBirthEx.text = Localized.recharge_card_birthday_sample.txt
        
        lblImageCardNumber.text = Localized.recharge_card_number.txt
        lblImageCardExpiredDate.text = Localized.recharge_card_exp_date_guide.txt
    }
    
    func initialize() {
        preEazy()
        setupDelegate()
        updatePrevCardNumber()
        
    }
    
    @IBAction func didChanged(_ sender: Any) {
        updateNewString()
    }
    
    private func saveLastString() {
        if easyPayBillType {
            self.lastString = "\(svpCard.getCardNum())\(tfYear.text ?? "")\(tfMonth.text ?? "")\(tfPasswd.text ?? "")\(tfBirth.text ?? "")"
        } else {
            self.lastString = "\(svpCard.getCardNum())\(tfYear.text ?? "")\(tfMonth.text ?? "")"
        }
    }
    
    // 화면 노출 분기
    private func showCardBillType(btype: String) {
        vm.showDetail = btype == "13"
        self.showPanel(detail: vm.showDetail)
    }
    
    
    private func showPanel(detail: Bool) {
        if detail {
            svpPassword.isHidden = false
            svpBirth.isHidden = false
        } else {
            svpPassword.isHidden = true
            svpBirth.isHidden = true
        }
        
        self.easyPayBillType = detail
    }
    
    override func pressNext() {
        if !checkData() {
            return
        }
        
        if (!isChangedCardInfo()) {
            // 은행화면으로 이동
            moveToBankStep()
        } else {
            // 통신
            let encryptCardNum = svpCard.getCardNum()
            let yy = tfYear.text.isNilOrEmpty ? "" : tfYear.text!
            let mm = tfMonth.text.isNilOrEmpty ? "" : tfMonth.text!
            let cardPsswd = tfPasswd.text.isNilOrEmpty ? "" : tfPasswd.text!
            let userSecureNum = tfBirth.text.isNilOrEmpty ? "" : tfBirth.text!
            
            if easyPayBillType {
                registerEasy(step: "3", cardNum: encryptCardNum, mm: mm, yy: yy, pwd: cardPsswd, usn: userSecureNum)
            } else {
                registerEasy(step: "3", cardNum: encryptCardNum, mm: mm, yy: yy, pwd: "", usn: "")
            }
        }
    }
    
    private func isChangedCardInfo() -> Bool {
        var new = ""
        
        if easyPayBillType {
            new = "\(svpCard.getCardNum())\(tfYear.text ?? "")\(tfMonth.text ?? "")\(tfPasswd.text ?? "")\(tfBirth.text ?? "")"
        } else {
            new = "\(svpCard.getCardNum())\(tfYear.text ?? "")\(tfMonth.text ?? "")"
        }
        
        if lastString != new {
            return true
        } else {
            return false
        }
    }
    
    private func moveToSuccess() {
        EasyRegInfo.shared.cardNum = svpCard.getCardNum()
        success?()
    }
    
    private func moveToBankStep() {
        EasyRegInfo.shared.cardNum = svpCard.getCardNum()
        self.changedCardInfo?("")
        press?()
    }
    
    private func moveToAuthStep() {
        showAuth?()
    }
    
    @IBAction func showSecureKeyboard(_ sender: Any) {
        showKeyboard()
    }
    
    private func showKeyboard() {
        guard let vc = Link.easy_pwd_auth.viewController as? EasyKeyboardViewController else { return }
        vc.useCase = "5"
        vc.password = { [weak self] pwd in
            self?.tfPasswd.text = pwd
            self?.tfBirth.becomeFirstResponder()
        }
        view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: false)
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
    
    @IBAction func showDatePicker(_ sender: Any) {
        view.endEditing(true)
        
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
    
}


extension EasyCardViewController: UITextFieldDelegate, TPTextFieldDelegate {

    fileprivate func updateShowCardNumber() {
        let showCardNumber = UserDefaultsManager.shared.loadShowCardNumber()
        
        if showCardNumber {
            self.svpCard.tfCard3.isSecureTextEntry = false
            self.svpCard.tfCardShort2.isSecureTextEntry = false
        } else {
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
            svpCard.cardNumberChange()
        }
    }
    
    fileprivate func updateRecentCardType() {
        vm.cm.cardType = .CARD_TYPE_BC
        if vm.cm.isShorterCard() {
            svpCard.svpCardType1.isHidden = true
            svpCard.svpCardType2.isHidden = false
        } else {
            svpCard.svpCardType1.isHidden = false
            svpCard.svpCardType2.isHidden = true
        }
    }
    
    private func updatePrevCardNumber() {
        if let step3 = EasyRegInfo.shared.step3 {
            if let num = Data(base64Encoded: step3.CARD_NUMBER ?? "") {
                let str = String(data: AES256.decriptionAES256NotEncDate(data: num), encoding: .utf8)
                
                if str?.count == 16 {
                    vm.cm.cardType = .CARD_TYPE_BC
                    updatePrevBasicCardNumber(num: str)
                } else {
                    vm.cm.cardType = .CARD_TYPE_AMERICAN_EXPRESS_SHORTER
                    
                    if str?.count == 14 {
                        vm.cm.cardType = .CARD_TYPE_DINERS_CLUB_SHORT
                    } else if str?.count == 15 {
                        vm.cm.cardType = .CARD_TYPE_AMERICAN_EXPRESS_SHORTER
                    }
                    updatePrevShorterCardNumber(num: str)
                }
            }
            
            if let yy = Data(base64Encoded: step3.CARD_EXPIRE_YY ?? "") {
                tfYear.text = String(data: AES256.decriptionAES256NotEncDate(data: yy), encoding: .utf8)
            }
            
            if let mm = Data(base64Encoded: step3.CARD_EXPIRE_MM ?? "") {
                tfMonth.text = String(data: AES256.decriptionAES256NotEncDate(data: mm), encoding: .utf8)
            }
            
            if let pwd = Data(base64Encoded: step3.CARD_PASSWD ?? "") {
                tfPasswd.text = String(data: AES256.decriptionAES256NotEncDate(data: pwd), encoding: .utf8)
            }
            
            if let birth = Data(base64Encoded: step3.CARD_SOCIAL_ID ?? "") {
                tfBirth.text = String(data: AES256.decriptionAES256NotEncDate(data: birth), encoding: .utf8)
            }
        } else {
            vm.cm.cardType = .CARD_TYPE_BC
        }
        
        if vm.cm.isShorterCard() {
            svpCard.svpCardType1.isHidden = true
            svpCard.svpCardType2.isHidden = false
        } else {
            svpCard.svpCardType1.isHidden = false
            svpCard.svpCardType2.isHidden = true
        }
    }
    
    private func updatePrevBasicCardNumber(num: String?) {
        svpCard.tfCard1.text = String(num?[0...3] ?? "")
        svpCard.tfCard2.text = String(num?[4...7] ?? "")
        svpCard.tfCard3.text = String(num?[8...11] ?? "")
        svpCard.tfCard4.text = String(num?[12...] ?? "")
    }
    
    private func updatePrevShorterCardNumber(num: String?) {
        svpCard.tfCardShort1.text = String(num?[0...3] ?? "")
        svpCard.tfCardShort2.text = String(num?[4...9] ?? "")
        svpCard.tfCardShort3.text = String(num?[10...] ?? "")
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
    
    private func updateNewString() {
        if isChangedCardInfo() {
            changedCardInfo?(CARD_INFO.NUMBER_1)
        } else {
            changedCardInfo?("")
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
//                    tfPasswd.becomeFirstResponder()
                    showKeyboard()
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


extension EasyCardViewController: DateDelegate {
    func dateMessage(date: String) {
        self.tfBirth.text = date
    }
}

extension EasyCardViewController {
    
    
    // 선택한 간편결제 SEQ
    // 간편결제에 필요한 값 미리받기
    private func preEazy() {
        let params = PreEasyRequest.Param(easyPaySubSeq: "")
        let req = PreEasyRequest(param: params)
        showLoading?()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<PreEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if let type = data.O_DATA?.O_CREDIT_BILL_TYPE {
                    self.showCardBillType(btype: type)
                    self.saveLastString()
                } else {
                    self.showCardBillType(btype: Bill.T18) // 값이 없을 경우 가리기
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoading?()
        }
    }
    
    
    // 간편결제 등록(PIN, 카드 이미지, 카유비생)
    // step 3
    private func registerEasy(step: String, cardNum: String, mm: String, yy: String, pwd: String, usn: String) {
        let params = RegisterEasyRequest.Param(
            easyPaySubSeq: EasyRegInfo.shared.seq ?? "",
            easyPayStep: step,
            easyPayAuthNum: emptyString,
            CREDIT_BILL_TYPE: easyPayBillType ? "13" : "18",
            cardNum: enc(str: cardNum),
            cardExpireYY: enc(str: yy),
            cardExpireMM: enc(str: mm),
            cardPsswd: enc(str: pwd),
            userSecureNum: enc(str: usn))
        
        let req = RegisterEasyRequest(param: params)
        showLoading?()
        API.shared.upload(url: req.getAPI(), param: req.getParam(), type: .easy_pay) { (response: Swift.Result<RegisterEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    self.saveLastString()
                    if data.O_DATA?.finishStepFlag == "Y" {
                        self.moveToSuccess()
                    } else {
                        if let moveLink = data.O_DATA?.moveLink {
                            if moveLink.contains("4") {
                                self.moveToBankStep()
                            } else if moveLink.contains("5") {
                                self.moveToAuthStep()
                            }
                        } else {
                            self.moveToBankStep()
                        }
                    }
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
