//
//  ExtendstayDetailViewController.swift
//  thepay
//
//  Created by xeozin on 2020/08/05.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

class ExtendstayDetailViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tfPhoneNumber: TPTextField!
    @IBOutlet weak var tfTelecom: TPTextField!
    @IBOutlet weak var tfName: TPTextField!
    @IBOutlet weak var btnNext: TPButton!
    
    @IBOutlet weak var lblPhone: TPLabel!
    @IBOutlet weak var lblTelecom: TPLabel!
    @IBOutlet weak var lblName: TPLabel!
    @IBOutlet weak var lblChooseTelecom: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var lblKinds: TPLabel!
    @IBOutlet weak var lblTitle: TPLabel!
    
    var formData: [UserformPreResponse.O_DATA.formList]?
    var menuManager:MenuManager<UserformPreResponse.O_DATA.formList>? = MenuManager()
    
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
        lblTitle.text = Localized.request_extend_stay_title.txt
        updateTitle(title: Localized.request_extend_stay_title.txt)
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
        lblPhone.text = Localized.request_extend_stay_input_phone_number_title.txt
        lblTelecom.text = Localized.request_extend_stay_input_telco_title.txt
        lblName.text = Localized.request_extend_stay_input_name_title.txt
        lblChooseTelecom.text = Localized.request_extend_stay_select_mvno_guide_1.txt
//        lblKinds.text = Localized.request_extend_stay_select_mvno_guide_2.txt TODO: 서버, 로컬 둘 중에 언어정리 후 결정
        lblDesc.text = Localized.request_extend_stay_select_mvno_guide_3.txt
        
        guard let list = formData else { return }
        var txt = "" // 로컬 로직
        for data in list {
            guard let sortNo = data.sortNo else { return }
            guard let mvnoName = data.mvnoName else { return }
            txt.append("\(sortNo). (\(mvnoName))\n")
        }
        
        lblKinds.text = txt
    }
    
    func initialize() {
        self.tfName.delegate = self
        self.tfPhoneNumber.text = StringUtils.telFormat(UserDefaultsManager.shared.loadANI() ?? "")
        self.tfPhoneNumber.delegate = self
        menuManager?.menu?.selectItem = {
            self.tfTelecom.text = $0?.mvnoName
        }
        
        menuManager?.updateData(data: MenuDataConverter.period(value: formData))
    }
    
    @IBAction func chooseTelecom(_ sender: UIView) {
        menuManager?.show(sender: sender)
    }
    
    private func showErrorMsg() {
        Localized.toast_invalid_format_phone_for_virtual_account.txt.showErrorMsg(target: self.view)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowPhoto" {
            guard let cnt = self.tfPhoneNumber.text?.removeDash().count else {
                showErrorMsg()
                return false
            }
            
            // 11자리
            if cnt > 11 || cnt < 11 {
                showErrorMsg()
                return false
            }
            
            // 앞자리 01~
            if let prefix = self.tfPhoneNumber.text?[0..<2] {
                if prefix != "01" {
                    showErrorMsg()
                    return false
                }
            }
            
            if self.tfName.text?.count == 0 {
                Localized.request_extend_stay_error_nameless.txt.showErrorMsg(target: self.view)
                self.tfName.becomeFirstResponder()
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ExtendstayPhotoViewController {
            guard let data = menuManager?.menu?.getItem()?.mvnoId else { return }
            vc.detailInfo = ExtendstayBeforeData.ExtendstayDetailInfo(engName: self.tfName.text ?? "", mvnoId: data)
        }
    }
}

extension ExtendstayDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField {
        case self.tfPhoneNumber:
            if updatedText.isNumber {
                Utils.formatPosition(textField: textField, range: range, phone: updatedText.phoneNumber)
                if updatedText.phoneNumber.count >= 11 {
                    textField.resignFirstResponder()
                    return false
                } else {
                    return false
                }
            } else {
                "\(Localized.toast_empty_tel.txt)\n(\(updatedText))".showErrorMsg(target: self.view)
                return false
            }
        case self.tfName:
            if updatedText.count > 30 {
                return false
            }
            self.tfName.text = updatedText.uppercased()
        default:
            return false
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
