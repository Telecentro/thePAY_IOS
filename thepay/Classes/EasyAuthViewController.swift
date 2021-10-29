//
//  EasyAuthViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasyAuthViewController: EasyStepViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblSubTitle: TPLabel!
    @IBOutlet weak var lblDescTitle: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    
    var success:(()->Void)?
    let viewModel = PasscodeViewModel()
    @IBOutlet var rounds: [UILabel]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var keypad: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localize()
        initialize()
    }
    
    func localize() {
        lblTitle.text = Localized.text_title_transferred_1_won.txt
        lblSubTitle.text = Localized.text_guide_please_enter_account_auth_num.txt
        lblDescTitle.text = Localized.text_title_how_to_check_auth_num.txt
        lblDesc.text = Localized.text_content_how_to_check_auth_num.txt
    }
    
    
    @IBAction func showKeypad(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        keypad.isHidden = !sender.isSelected
    }
    
    func initialize() {
        keypad.isHidden = true
        addButtonTargets()
        bind()
        redraw()
    }
    
    private func bind() {
        viewModel.errorCount.subscribe { [weak self] value in
            guard let count = value.element else { return }
            self?.errorLabel.isHidden = count == "0/0"
            self?.errorLabel.text = count
            self?.viewModel.keyString.onNext("")
        }.disposed(by: viewModel.db)
        
        viewModel.keyString.subscribe {
            let cnt = $0.element?.count ?? 0
            for i in 0..<self.viewModel.keyLength {
                self.rounds[i].textColor = .lightGray
            }
            for i in 0..<cnt {
                self.rounds[i].textColor = .black
            }
        }.disposed(by: viewModel.db)
    }
    
    /**
     *  키 렌더링
     */
    private func redraw() {
        let items = viewModel.keys.shuffled()
        
        for (index, btn) in self.buttons.enumerated() {
            btn.setTitle(items[index].title, for: .normal)
        }
    }
    
    
    private func addButtonTargets() {
        for btn in buttons {
            btn.addTarget(self, action: #selector(pressButton(sender:)), for: .touchUpInside)
        }
    }
    
    
    @objc func pressButton(sender: UIButton) {
        guard let pressedKey = sender.titleLabel?.text else { return }
        if !viewModel.canEdit { return }
        
        if !viewModel.max() {
            viewModel.appendString(key: pressedKey)
        }
        
        if let pin = try? viewModel.keyString.value() {
            print(pin)
        } else {
            print("NO DATA")
        }
        
        if viewModel.max() {
            viewModel.canEdit = false
            perform(#selector(updateState), with: nil, afterDelay: 0.2)
        }
    }
    
    @objc func updateState() {
        requesthAuthAccount()
    }
    
    @IBAction func pressBackButton(sender: UIButton) {
        viewModel.removeString()
    }
}

extension EasyAuthViewController {
    
    private func requesthAuthAccount() {
        guard let pin = try? viewModel.keyString.value() else { return }
        let params = AuthAccountRequest.Param(
            opCode: "res",
            acctBankCd: "",
            acctBankNum: "",
            acctHolder: "",
            acctAuthCd: pin
        )
        
        let req = AuthAccountRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<AuthAccountResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    self.success?()
                } else if data.O_CODE == FLAG.E0001 {
                    self.viewModel.increaseErrorCount(failCnt: data.O_DATA?.failCnt ?? "")
                    self.viewModel.canEdit = true
                } else if data.O_CODE == FLAG.E8905 {
                    self.viewModel.resetErrorCount()
                    
                    self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG) {
                        self.navigationController?.popToRootViewController(animated: true)
                    } cancel: {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
}
