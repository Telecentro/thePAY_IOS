//
//  BirthViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/19.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

protocol DateDelegate {
    func dateMessage(date: String)
}

class BirthViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblSubTitle: TPLabel!
    @IBOutlet weak var btnCancel: TPButton!
    @IBOutlet weak var btnDone: TPButton!
    
    var delegate: DateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        lblTitle.text = Localized.recharge_card_birthday.txt
        lblSubTitle.text = Localized.alert_msg_birth_6_digit.txt
        btnCancel.setTitle(Localized.btn_cancel.txt, for: .normal)
        btnDone.setTitle(Localized.btn_confirm.txt, for: .normal)
    }
    
    func initialize() {
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        datePicker.datePickerMode = .date
        datePicker.date = getDefaultDate()
        
        // iOS 14 Calendar UI
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        datePicker.locale = LanguageUtils.getCalendarLocale()
    }
    
    private func getDefaultDate() -> Date {
        var dtComp = DateComponents()
        dtComp.day = 1
        dtComp.month = 1
        dtComp.year = 1990
        let cal = Calendar(identifier: .gregorian)
        return cal.date(from: dtComp) ?? Date()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
                                                                             
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyMMdd"
            dateFormatter.locale = App.shared.locale
            let selectedDate: String = dateFormatter.string(from: self.datePicker.date)
            self.delegate?.dateMessage(date: selectedDate)
        }
    }
}
