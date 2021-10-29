//
//  TPNationSelector.swift
//  thepay
//
//  Created by xeozin on 2020/08/24.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TPEloadSelector: TPSelector {
    var eload: [EloadRealResponse.item] = []
    
    // 확인
    @objc private func pressDone() {
        self.select()
        tf?.resignFirstResponder()
    }
    
    // 취소
    @objc private func pressCancel() {
        self.cancel()
        tf?.resignFirstResponder()
    }
}

// MARK: - 공개 함수
extension TPEloadSelector {
    
    // 픽커뷰 노출
    func show() {
        tf?.becomeFirstResponder()
    }
    
    // 초기화
    func initialize(tf: UITextField) {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.tf = tf
        self.tf?.tintColor = .clear
        self.tf?.inputView = self.pickerView
        self.tf?.inputAccessoryView = self.toolBar()
        self.tf?.delegate = self
        if self.eload.count > 0 {
            self.tf?.text = self.eload[rowValue].text
        }
    }
}

// MARK: - 텍스트 필드 델리게이트
extension TPEloadSelector: UITextFieldDelegate {
    
    // 텍스트 필드 시작
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.start()
        self.selectBox(select: true)
        isSelect = false
        self.lastSelectedRow = rowValue
        print("start row \(self.lastSelectedRow)")
        self.pickerView.selectRow(rowValue, inComponent: 0, animated: true)
    }
    
    // 텍스트 필드 종료
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.end()
        self.selectBox(select: false)
        if isSelect {
            if rowValue != self.lastSelectedRow {
                self.callback?(eload[rowValue])
                self.tf?.text = self.eload[rowValue].text
            }
        } else {
            rowValue = self.lastSelectedRow
        }
    }
}

// MARK: - 피커뷰 델리게이트
extension TPEloadSelector : UIPickerViewDataSource, UIPickerViewDelegate {
    private func toolBar() -> UIToolbar {
        let done = UIBarButtonItem(title: Localized.btn_confirm.txt, style: .done, target: self, action: #selector(pressDone))
        let cancel = UIBarButtonItem(title: Localized.btn_cancel.txt, style: .done, target: self, action: #selector(pressCancel))
        
        return getToolBar(done: done, cancel: cancel)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.eload.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eload[row].text
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isShow {
            rowValue = row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let text:String? = self.eload[row].text
        
        let picView: UIView = UIView()
        
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        label.font = LanguageUtils.fontWithSize(size: 20)
        label.text = text
        label.textAlignment = .center
        picView.addSubview(label)
        
        return picView
    }
}
