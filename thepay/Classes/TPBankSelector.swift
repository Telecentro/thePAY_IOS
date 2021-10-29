//
//  TPBankSelector.swift
//  thepay
//
//  Created by xeozin on 2020/08/04.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TPBankSelector: TPSelector {
    
    @IBOutlet weak var ivBankLogo: UIImageView!
    @IBOutlet weak var lblBlankBank: TPLabel!
    
    private var bankData: [SubPreloadingResponse.bankList]? = []
    private var bankCode: String?
    
    // 선택된 아이템이 없을때 블랭크 레이블 노출, 이미지 가림
    var emptyContents:Bool = true {
        didSet {
            lblBlankBank.isHidden = !emptyContents
            ivBankLogo.isHidden = emptyContents
        }
    }
    
    @objc private func pressDone() {
        
        self.select()
        tf?.resignFirstResponder()
    }
    
    @objc private func pressCancel() {
        self.cancel()
        tf?.resignFirstResponder()
    }

}

/**
 * 공개 함수 (Public)
 */
extension TPBankSelector {
    
    private func toolBar() -> UIToolbar {
        let done = UIBarButtonItem(title: Localized.btn_confirm.txt, style: .done, target: self, action: #selector(pressDone))
        let cancel = UIBarButtonItem(title: Localized.btn_cancel.txt, style: .done, target: self, action: #selector(pressCancel))
        
        return getToolBar(done: done, cancel: cancel)
    }
    
    func initialize(data:[SubPreloadingResponse.bankList]?, tf: UITextField, dynamic: Bool = false) {
        bankData = data
        pickerView.delegate = self
        pickerView.dataSource = self
        self.tf = tf
        self.tf?.tintColor = .clear
        self.tf?.inputView = self.pickerView
        self.tf?.inputAccessoryView = toolBar()
        self.tf?.delegate = self
        
        if !dynamic {
            bankCode = UserDefaultsManager.shared.loadBankCode()
            if let imgName = UserDefaultsManager.shared.loadBankImgName() {
                ivBankLogo.image = UIImage(named: imgName)
            }
            if let data = App.shared.bankList {
                self.bankData = data
            }
        } else {
            lblBlankBank.isHidden = true
        }
        
        for item in bankData ?? [] {
            if bankCode == item.bankCode {
                rowValue = (item.sortNo ?? 0) - 1
                
                if rowValue < 0 {
                    rowValue = 0
                }
            }
        }
        
        localize()
    }
    
    func localize() {
        // 선택된 아이템이 없을때 블랭크 레이블 노출
        lblBlankBank.text = Localized.toast_select_bank.txt
    }
    
    public func setupData(list:[SubPreloadingResponse.bankList]) {
        self.bankData = list
        ivBankLogo.image = UIImage(named: list[0].imgNm ?? "bank_11.png")
    }
    
    func show() {
        tf?.becomeFirstResponder()
    }
    
    // 영문 은행명
    func bankEng() -> String {
        return bankData?[rowValue].bankNameUs ?? ""
    }
    
    func hasBank() -> Bool {
        return lblBlankBank.isHidden
    }
    
    func setBankCd(bankCode: String?) {
        self.bankCode = bankCode
    }
     
    // 은행코드 반환
    func bankCd() -> String? {
        return bankData?[rowValue].bankCode ?? ""
    }
    
    func isNotSameBankCode() -> Bool {
        if let saveCode = UserDefaultsManager.shared.loadBankCode() {
            return saveCode != self.bankCode
        } else {
            return true
        }
    }
    
    private func dataUpdate() {
        self.callback?(rowValue)
    }
}


extension TPBankSelector: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.start()
        self.selectBox(select: true)
        isSelect = false
        self.lastSelectedRow = rowValue
        pickerView.selectRow(rowValue, inComponent: 0, animated: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.end()
        self.selectBox(select: false)
        if isSelect {
            if rowValue != self.lastSelectedRow {
                guard let img = bankData?[rowValue].imgNm else { return }
                self.ivBankLogo.image = UIImage(named: img)
                emptyContents = false
                dataUpdate()
            }
        } else {
            rowValue = self.lastSelectedRow
        }
        
    }
    
}

//MARK: - 피커뷰 델리게이트
extension TPBankSelector : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.bankData?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let picView: UIView = UIView()
        if let img = bankData?[row].imgNm {
            if let code = bankData?[row].bankCode {
                bankCode = code
                let width = UIScreen.main.bounds.size.width
                let imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: 34))
                imgView.contentMode = .scaleAspectFit
                imgView.image = UIImage(named: img)
                picView.addSubview(imgView)
            }
        }
        
        return picView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isShow {
            rowValue = row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
