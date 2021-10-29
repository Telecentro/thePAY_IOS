//
//  TPDataSelector.swift
//  thepay
//
//  Created by xeozin on 2020/08/07.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

enum SelectorType {
    case cashList
    case intlAmount
    case intlLang
    case regularAmount
    case monthlyAmount
    case telecom
    case period
}

class TPDataSelector: TPSelector {
    var type: SelectorType = .cashList
    
    // 금액선택 (CardViewController)
    var cashList: [SubPreloadingResponse.cashList] = []
    
    // 금액선택 (InternationalCallViewController)
    var intlAmount: [SubPreloadingResponse.intl.amounts] = []
    
    // 언어선택 (InternationalCallViewController)
    var intlLang: [SubPreloadingResponse.intl.arsLang] = []
    
    // 일반선불
    var regularAmount: [PreloadingResponse.mvnoList.pps.rcgList] = [] {
        didSet {
            reset()
        }
    }
    
    // 월정액
    var monthlyAmount: [SubPreloadingResponse.amounts] = [] {
        didSet {
            reset()
        }
    }
    
    // 통신사
    var telecom: [SubPreloadingResponse.mthRate] = []
    
    // 체류연장
    var period: [UserformPreResponse.O_DATA.formList] = []
    
    @objc private func pressDone() {
        self.select()
        tf?.resignFirstResponder()
    }
    
    @objc private func pressCancel() {
        self.cancel()
        tf?.resignFirstResponder()
    }
}

extension TPDataSelector {
    
    func show() {
        tf?.becomeFirstResponder()
    }
    
    /**
     *  초기화
     */
    func reset() {
        print("🤬 RESET ! \(type)")
        resetIndex()
        dataUpdate()
        self.pickerView.reloadComponent(0)
        self.pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    func initialize(type: SelectorType, tf: UITextField) {
        pickerView.delegate = self
        pickerView.dataSource = self
        self.tf = tf
        self.tf?.tintColor = .clear
        self.tf?.inputView = self.pickerView
        self.tf?.inputAccessoryView = self.toolBar()
        self.tf?.delegate = self
        self.type = type
        switch type {
        case .cashList:
            if cashList.count > 0 {
                tf.text = cashList.first?.amounts?.currency.won
            }
        case .intlAmount:
            if intlAmount.count > 0 {
                tf.text = intlAmount.first?.amount?.currency.won
            }
        case .intlLang:
            if intlLang.count > 0 {
                tf.text = intlLang.first?.langName
            }
        case .regularAmount:
            if regularAmount.count > 0 {
                tf.text = regularAmount.first?.amounts?.currency.won
            }
        case .monthlyAmount:
            if monthlyAmount.count > 0 {
                tf.text = monthlyAmount.first?.prodName
            }
        case .telecom:
            if telecom.count > 0 {
                tf.text = telecom.first?.mvnoName
            }
        case .period:
            if period.count > 0 {
                tf.text = period.first?.mvnoName
            }
        }
    }
    
    /**
     *  데이터 반환
     *  1. 캐쉬 금액
     *  2. 국제전화 금액
     *  3. 국제전화 언어
     *  4. 종량제 타입
     *  5. 정액제 금액 (문자열 변환)
     *  6. 텔레콤 종류
     *  7. 체류기간 종류
     */
    func getData() -> String {
        switch type {
        case .cashList:
            if let item = cashList[exist: rowValue] {
                return item.amounts ?? "0"
            } else {
                return "0"
            }
        case .intlAmount:
            if let item = intlAmount[exist: rowValue] {
                return item.amount ?? "0"
            } else {
                return "0"
            }
        case .intlLang:
            if let item = intlLang[exist: rowValue] {
                return item.langCd ?? "USA"
            } else {
                return "USA"
            }
        case .regularAmount:
            if let item = regularAmount[exist: rowValue] {
                return item.rcgType ?? ""
            } else {
                return ""
            }
        case .monthlyAmount:
            if let item = monthlyAmount[exist: rowValue] {
                return String(item.amount ?? 0).currency.won
            } else {
                return "0"
            }
        case .telecom:
            if let item = telecom[exist: rowValue] {
                return item.mvnoName ?? ""
            } else {
                return ""
            }
        case .period:
            if let item = period[exist: rowValue] {
                return item.mvnoId ?? ""
            } else {
                return ""
            }
        }
    }
    
    /**
     *  데이터 업데이트
     *  1. reset
     *  2. 픽커뷰 선택시
     */
    private func dataUpdate() {
        switch type {
        case .cashList:
            if let item = cashList[exist: rowValue] {
                self.callback?(item)
                if item.amounts == "etc" {
                    self.tf?.text = item.cashName
                } else {
                    self.tf?.text = item.amounts?.currency.won
                }
            }
        case .intlAmount:
            if let item = intlAmount[exist: rowValue] {
                self.callback?(item)
                self.tf?.text = item.amount?.currency.won
            }
        case .intlLang:
            if let item = intlLang[exist: rowValue] {
                self.callback?(item)
                self.tf?.text = item.langName
            }
        case .regularAmount:
            if let item = regularAmount[exist: rowValue] {
                self.callback?(item)
                self.tf?.text = item.mvnoName
            }
        case .monthlyAmount:
            if let item = monthlyAmount[exist: rowValue] {
                self.callback?(item)
                self.tf?.text = String(item.amount ?? 0).currency.won
            }
        case .telecom:
            if let item = telecom[exist: rowValue] {
                self.callback?(item)
                self.tf?.text = item.mvnoName
            }
        case .period:
            if let item = period[exist: rowValue] {
                self.callback?(item)
                self.tf?.text = item.mvnoName
            }
        }
    }
}

extension TPDataSelector: UITextFieldDelegate {
    
    /**
     *  텍스트 필드 선택
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.start()
        self.selectBox(select: true)
        self.lastSelectedRow = rowValue
        print("start row \(self.lastSelectedRow)")
        self.pickerView.selectRow(rowValue, inComponent: 0, animated: true)
    }
    
    /**
     *  픽커뷰 선택 종료
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.end()
        self.selectBox(select: false)
        if isSelect {
            print("data update")
            if rowValue != self.lastSelectedRow {
                dataUpdate()
            } else {
                if let tx = textField.text {
                    updateMontlyCheck(tx: tx)
                }
            }
        } else {
            print("roll back data")
            rowValue = self.lastSelectedRow
        }
    }
    
    /**
     *  월정액 판단 (특수)
     */
    private func updateMontlyCheck(tx: String) {
        switch type {
        case .monthlyAmount:
            if tx.contains("~") {
                dataUpdate()
            }
        default:
            break
        }
    }
    
}



//MARK: - 피커뷰 델리게이트
extension TPDataSelector : UIPickerViewDataSource, UIPickerViewDelegate {
    
    /**
     *  툴바 설정
     */
    private func toolBar() -> UIToolbar {
        let done = UIBarButtonItem(title: Localized.btn_confirm.txt, style: .done, target: self, action: #selector(pressDone))
        let cancel = UIBarButtonItem(title: Localized.btn_cancel.txt, style: .done, target: self, action: #selector(pressCancel))
        
        return getToolBar(done: done, cancel: cancel)
    }
    
    /**
     *  픽커뷰 컬럼 1 고정
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     *  픽커뷰 컴포넌트 갯수 반환
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch type {
        case .cashList:
            return self.cashList.count
        case .intlAmount:
            return self.intlAmount.count
        case .intlLang:
            return self.intlLang.count
        case .regularAmount:
            return self.regularAmount.count
        case .monthlyAmount:
            return self.monthlyAmount.count
        case .telecom:
            return self.telecom.count
        case .period:
            return self.period.count
        }
    }
    
    /**
     *  픽커뷰 선택
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isShow {
            rowValue = row
            print("data update \(rowValue)")
        }
    }
    
    /**
     *  픽커뷰 높이
     */
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    /**
     *  픽커뷰 텍스트 뷰 반환
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var text:String? = ""
        switch type {
        case .cashList:
            if cashList[row].amounts == "etc" {
                text = cashList[row].cashName
            } else {
                text = cashList[row].amounts?.currency.won
            }
        case .intlAmount:
            text = intlAmount[row].amount?.currency.won
        case .intlLang:
            text = intlLang[row].langName
        case .regularAmount:
            text = regularAmount[row].mvnoName
        case .monthlyAmount:
            text = String(monthlyAmount[row].amount ?? 0).currency.won
        case .telecom:
            text = telecom[row].mvnoName
        case .period:
            text = period[row].mvnoName
        }
        
        
        let picView: UIView = UIView()
        
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        label.font = LanguageUtils.fontWithSize(size: 20)
        label.text = text
        label.textAlignment = .center
        picView.addSubview(label)
        
        return picView
    }
}
