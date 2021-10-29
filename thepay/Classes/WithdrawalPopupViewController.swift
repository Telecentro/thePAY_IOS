//
//  WithdrawalPopupViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/09/27.
//  Copyright © 2021 Duo Labs. All rights reserved.
//


import UIKit
import SPMenu

class WithdrawalPopupViewController: TPBaseViewController {
    
    @IBOutlet weak var btnCancel: TPButton!
    @IBOutlet weak var btnConfirm: TPButton!
    @IBOutlet weak var tfList: TPTextField!
    @IBOutlet weak var lblCash: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    @IBOutlet weak var lblChargeInfo: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    
    var titleText: NSAttributedString?
    var descText: NSAttributedString?
    var confirm: ((String)->())?
    var cancel: (()->())?
    var isSingleConfirm = false
    
    var menuManager:MenuManager<WithdrawalCheckResponse.O_DATA.withdraw>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
        
        var config = SPMenuConfig()
        config.font = LanguageUtils.fontWithSize(size: 14)
        menuManager = MenuManager(config: config)
        menuManager?.menu?.selectItem = { [weak self] in
            self?.tfList.text = $0?.withDrawResaon
        }
    }
    
    func localize() {
        lblDesc.text = Localized.text_guide_warning_withdrawal.txt
        btnCancel.setTitle(Localized.btn_cancel.txt, for: .normal)
        btnConfirm.setTitle(Localized.btn_withdraw.txt, for: .normal)
    }
    
    func initialize() {
        if isSingleConfirm {
            btnCancel.isHidden = true
        }
        
        self.showLoadingWindow()
        let req = WithdrawalCheckRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<WithdrawalCheckResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.lblChargeInfo.text = data.O_DATA?.rcgMsg
                self.lblCash.text = data.O_DATA?.CASH?.currency
                self.lblPoint.text = data.O_DATA?.POINT?.currency
                self.menuManager?.updateData(data: MenuDataConverter.withdraw(value: data.O_DATA?.withDraw))
            case .failure(let error):
                error.processError(target: self)
            }
            self.hideLoadingWindow()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        cancel?()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirm(_ sender: Any) {
        if let s = menuManager?.menu?.getItem()?.withDrawCD {
            confirm?(s)
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func showList(_ sender: UIView) {
        menuManager?.show(sender: sender)
    }
}
