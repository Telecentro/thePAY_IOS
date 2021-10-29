//
//  TPNationSelector.swift
//  thepay
//
//  Created by xeozin on 2020/08/24.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TPNationSelector: TPSelector {
    var nations: [SubPreloadingResponse.eLoad] = []
    
    private var imageView:UIImageView?
    
    @objc private func pressDone() {
        self.select()
        tf?.resignFirstResponder()
    }
    
    @objc private func pressCancel() {
        self.cancel()
        tf?.resignFirstResponder()
    }
}

extension TPNationSelector {
    func show() {
        tf?.becomeFirstResponder()
    }
    
    func initialize(tf: UITextField, imageView: UIImageView) {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.tf = tf
        self.imageView = imageView
        self.tf?.tintColor = .clear
        self.tf?.inputView = self.pickerView
        self.tf?.inputAccessoryView = self.toolBar()
        self.tf?.delegate = self
        if self.nations.count > 0 {
            self.updateDisplay(row: rowValue)
        }
    }
}


extension TPNationSelector: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.start()
        self.selectBox(select: true)
        isSelect = false
        self.lastSelectedRow = rowValue
        print("start row \(self.lastSelectedRow)")
        self.pickerView.selectRow(rowValue, inComponent: 0, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.end()
        self.selectBox(select: false)
        if isSelect {
            if rowValue != self.lastSelectedRow {
                self.callback?(nations[rowValue])
                self.updateDisplay(row: rowValue)
            }
        } else {
            rowValue = self.lastSelectedRow
        }
    }
    
    private func updateDisplay(row: Int) {
        if let code = nations[row].countryCode {
            self.imageView?.image = UIImage(named: "flag_\(code)")
        }
        self.tf?.text = nations[row].mvnoName
    }
}


//MARK: - 피커뷰 델리게이트
extension TPNationSelector : UIPickerViewDataSource, UIPickerViewDelegate {
    private func toolBar() -> UIToolbar {
        let done = UIBarButtonItem(title: Localized.btn_confirm.txt, style: .done, target: self, action: #selector(pressDone))
        let cancel = UIBarButtonItem(title: Localized.btn_cancel.txt, style: .done, target: self, action: #selector(pressCancel))
        
        return getToolBar(done: done, cancel: cancel)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.nations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isShow {
            rowValue = row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let picView: UIView = UIView()
        if let flagCode = nations[row].countryCode {
            let flagCenter = UIScreen.main.bounds.size.width / 9
            let imgView: UIImageView = UIImageView(frame: CGRect(x: flagCenter, y: 0, width: 50, height: 44))
            imgView.contentMode = .scaleAspectFit
            imgView.image = UIImage(named: "flag_\(flagCode)")
            picView.addSubview(imgView)
        }
        
        if let CountryText = nations[row].mvnoName {
            let textCenter = UIScreen.main.bounds.size.width / 3
            let label: UILabel = UILabel(frame: CGRect(x: textCenter, y: 0, width: 200, height: 44))
            label.text = CountryText
            picView.addSubview(label)
        }
        
        return picView
    }
}
