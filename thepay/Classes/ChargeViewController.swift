//
//  CashChargeViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/08.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum ChargeFrom {
    case cash
    case payment
}

enum ChargeType: String {
    case bank = "1"
    case card = "0"
}

class ChargeViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var btnPay: TPButton!
    @IBOutlet weak var btnPaymentHeight: NSLayoutConstraint!
    @IBOutlet weak var btnPaymentMarginHeight: NSLayoutConstraint!
    
    var cardViewController: CardViewController?
    var bankViewController: BankViewController?
    @IBOutlet weak var viewBank: UIView!
    @IBOutlet weak var viewCard: UIView!
    
    var from: ChargeFrom = .cash
    var type: ChargeType = .card
    
    var payInfo: PayInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        self.updateDisplay()
    }
    
    func localize() {
        if self.from == .payment {
            self.setupNavigationBar(type: .basic(title: self.title))
        } else {
            self.title = Link.cash.title
            self.setupNavigationBar(type: .basic(title: Link.cash.title))
        }
        
        self.btnPay.setTitle(Localized.btn_pay.txt, for: .normal)
        
        if let v = self.navigationController as? TPNavigationViewController {
            v.ok2()
        }
    }
    
    private func updateDisplay() {
        switch type {
        case .card:
            self.viewCard.isHidden = false
            self.viewBank.isHidden = true
            
            self.bankViewController?.view.endEditing(true)
            self.cardViewController?.updateTapDisplay()
        case .bank:
            self.viewBank.isHidden = false
            self.viewCard.isHidden = true
            
            self.cardViewController?.view.endEditing(true)
            self.bankViewController?.updateTapDisplay()
        }
        
        self.cardViewController?.updateButtonStatus(type: type)
        self.bankViewController?.updateButtonStatus(type: type)
    }
    
    /**
     *  결제
     */
    @IBAction func charge(_ sender: Any) {
        switch self.type {
        case .card:
            self.cardViewController?.recharge()
        case .bank:
            self.bankViewController?.recharge()
        }
    }
}

extension ChargeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let info = self.params?["payInfo"] as? PayInfo {
            self.from = .payment
            self.payInfo = info
            
            // 결제라 하더라도 opCode가 CASH면 충전으로 판단 (중국)
            if let opCode = info.opCode?.uppercased() {
                if opCode == "CASH" {
                    self.from = .cash
                }
            }
            
            // 중국 처리 2020.10.20 (카드 타입인지, 가상계좌인지)
            self.type = ChargeType(rawValue: info.tabType) ?? ChargeType.card
        } else {
            self.from = .cash
        }
        
        if let vc = segue.destination as? CardViewController {
            self.cardViewController = vc
            self.cardViewController?.title = self.title
            self.cardViewController?.changeRechargeView = { [weak self] in
                switch $0 {
                case .card:
                    self?.type = .card
                    self?.updateDisplay()
                    self?.cardViewController?.updateTapDisplay()
                case .bank:
                    self?.type = .bank
                    self?.updateDisplay()
                    self?.bankViewController?.updateTapDisplay()
                }
            }
            
            self.cardViewController?.updatePaymentType = { [weak self] in
                switch $0 {
                case .select, .none:
                    print("😈 select")
                    self?.btnPaymentHeight.constant = 56
                    self?.btnPaymentMarginHeight.constant = 16
                case .easyAndSafe, .easyOnly:
                    print("😈 easyAndSafe, easyOnly")
                    self?.btnPaymentHeight.constant = 0
                    self?.btnPaymentMarginHeight.constant = 0
                    break
                }
            }
            
            vc.setPaymentInfo(from: from, payInfo: payInfo)
        }
        
        if let vc = segue.destination as? BankViewController {
            self.bankViewController = vc
            self.bankViewController?.title = self.title
            self.bankViewController?.changeRechargeView = { [weak self] in
                switch $0 {
                case .card:
                    self?.type = .card
                    self?.updateDisplay()
                    self?.cardViewController?.updateTapDisplay()
                case .bank:
                    self?.type = .bank
                    self?.updateDisplay()
                    self?.bankViewController?.updateTapDisplay()
                }
            }
            vc.from = self.from
            vc.payInfo = self.payInfo
        }
    }
}
