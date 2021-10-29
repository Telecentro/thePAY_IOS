//
//  TPTextField.swift
//  thepay
//
//  Created by xeozin on 2020/07/11.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

protocol TPTextFieldDelegate {
    func backspace(textField:TPDelegateTextField)
}

class TPDelegateTextField: TPFontTextfield {
    var lastBackspace = false
    var newDelegate: TPTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        if lastBackspace {
            lastBackspace = false
        } else {
            self.newDelegate?.backspace(textField:self)
            print("Backspace!!")
        }
    }
}

protocol TPTextViewDelegate {
    func backspace(textView:TPDelegateTextView)
}

class TPDelegateTextView: UITextView {
    
    var lastBackspace = false
    var newDelegate: TPTextViewDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        if lastBackspace {
            lastBackspace = false
        } else {
            self.newDelegate?.backspace(textView: self)
            print("Backspace!!")
        }
    }
}

class TPFontTextfield: UITextField {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.font = LanguageUtils.fontWithSize(size: self.font?.pointSize ?? 17, oldFont: self.font)
    }
}

class TPTextField: TPDelegateTextField {
    var indexPath: IndexPath?
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension TPTextField {
    
    
    @IBInspectable var doneAccessory: Bool {
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        v.backgroundColor = UIColor(named: "Primary")
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        btn.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        btn.setTitle("OK", for: .normal)
        v.addSubview(btn)
        self.inputAccessoryView = v
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
