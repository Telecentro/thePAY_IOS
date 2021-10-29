//
//  TPAutoCompleteViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/18.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TPAutoCompleteViewController: TPBaseViewController {
    /* AutoComplete */
    @IBOutlet weak var tfPhone: TPTextField!
    private var autoCompleteHeight: NSLayoutConstraint?
    private var autoCompleteLeft: NSLayoutConstraint?
    private var autoCompleteRight: NSLayoutConstraint?
    private var autoCompleteTop: NSLayoutConstraint?
    private var autoCompleteBottom: NSLayoutConstraint?
    var autoComplete: AutoCompleteViewController?
    var paste = ""
    /* AutoComplete End */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAutoComplete()
        actionKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        autoComplete?.updateData(type: ACType.num, code: Tel.kr)
    }
    
    func createAutoComplete() {
        let sb = UIStoryboard(name: Storyboard.Contact, bundle: nil)
        autoComplete = sb.instantiateViewController(withIdentifier: "AutoCompleteViewController") as? AutoCompleteViewController
        autoComplete?.view.layer.borderWidth = 0
        autoComplete?.view.layer.borderColor = UIColor.clear.cgColor
        autoComplete?.view.layer.shadowOffset = CGSize(width: 3, height: 3)
        autoComplete?.view.layer.shadowOpacity = 0.4
        autoComplete?.view.layer.shadowRadius = 10
        autoComplete?.delegate = self
    }
    
    private func actionKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(noti:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillHide(noti: NSNotification) {
        autoComplete?.autoTableView(hidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func updatePhoneNumber(ctn: String) {}
}

extension TPAutoCompleteViewController: AutoCompleteDelegate, UIScrollViewDelegate {
    func updateAutoCompleteHeight(height: Int) {
        autoCompleteHeight?.constant = CGFloat(height)
    }
    
    func selectItem(phoneNumber: String) {
        self.tfPhone.text = Utils.format(phone: phoneNumber)
        self.tfPhone.resignFirstResponder()
        if let ctn = self.tfPhone.text {
            updatePhoneNumber(ctn: ctn)
        }
    }
    
    func hiddenAutoComplete(hidden: Bool) {
        self.autoComplete?.view?.isHidden = hidden
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.autoComplete?.autoTableView(hidden: true)
    }
}

extension TPAutoCompleteViewController: UITextFieldDelegate {
    
    private func addAutoCompleteView(auto:AutoCompleteViewController ,stackView: UIView) {
        print("🔺 \(stackView.convert(stackView.frame, to: self.view))")
        self.view.addSubview(auto.view)
        self.autoCompleteTop?.isActive = false
        self.autoCompleteLeft?.isActive = false
        self.autoCompleteRight?.isActive = false
        self.autoCompleteBottom?.isActive = false
        auto.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.autoCompleteLeft = auto.view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        self.autoCompleteLeft?.isActive = true
        self.autoCompleteRight = auto.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        self.autoCompleteRight?.isActive = true
        self.autoCompleteTop = auto.view.topAnchor.constraint(equalTo: stackView.bottomAnchor)
        self.autoCompleteTop?.isActive = true
        
        if let _ = autoCompleteHeight {
        } else {
            self.autoCompleteHeight = auto.view.heightAnchor.constraint(equalToConstant: 0)
            self.autoCompleteHeight?.isActive = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        paste = UIPasteboard.general.string ?? ""
        
        if let auto = autoComplete {
            self.addAutoCompleteView(auto: auto, stackView: textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case tfPhone:
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // 백스페이스 허용
            if string == "" {
                autoComplete?.processingAutoTable(text: updatedText, type: ACType.num, code: Tel.kr)
                return true
            }
            // ০১২৩৪৫৬৭৮৯০১২৩৪৫৬৭৮৯
            if paste == string {
                if paste.isNumber {
                    let newString = LanguageUtils.getArabianSentence(string: paste)
                    if newString.count >= 11 {
                        updatePhoneNumber(ctn: newString.phoneNumber)
                    }
                    Utils.formatPosition(textField: textField, range: range, phone: newString.phoneNumber)
                    textField.resignFirstResponder()
                    return false
                } else {
                    "\(Localized.toast_empty_tel.txt)\n(\(paste))".showErrorMsg(target: self.view)
                    return false
                }
            } else {
                if updatedText.isNumber {
                    updatedText = LanguageUtils.getArabianSentence(string: updatedText)
                    autoComplete?.processingAutoTable(text: updatedText, type: ACType.num, code: Tel.kr)
                    Utils.formatPosition(textField: textField, range: range, phone: updatedText.phoneNumber)
                    if updatedText.phoneNumber.count >= 11 {
                        updatePhoneNumber(ctn: updatedText.phoneNumber)
                        autoComplete?.timer?.invalidate()
                        textField.resignFirstResponder()
                        return false
                    } else {
                        return false
                    }
                } else {
                    "\(Localized.toast_empty_tel.txt)\n(\(updatedText))".showErrorMsg(target: self.view)
                    return false
                }
            }
        default:
            return true
        }
    }
}
