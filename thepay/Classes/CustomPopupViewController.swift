//
//  CustomPopupViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/02.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class CustomPopupViewController: UIViewController {
    
    enum PopupType {
        case success
        case error
        case classic
        case retry
    }
    
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var btnCancel: TPButton!
    @IBOutlet weak var btnConfirm: TPButton!
    @IBOutlet weak var ivTypeImage: UIImageView!
    
    var titleText: NSAttributedString?
    var descText: NSAttributedString?
    var confirm: (()->())?
    var cancel: (()->())?
    var isSingleConfirm = false
    var type = PopupType.error
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        switch type {
        case .retry:
            btnCancel.setTitle(Localized.btn_app_close.txt, for: .normal)
            btnConfirm.setTitle(Localized.btn_network_retry.txt, for: .normal)
        default:
            btnCancel.setTitle(Localized.btn_cancel.txt, for: .normal)
            btnConfirm.setTitle(Localized.btn_confirm.txt, for: .normal)
        }
    }
    
    func initialize() {
        if isSingleConfirm {
            btnCancel.isHidden = true
        }
        
        lblDesc.attributedText = descText
        
        switch type {
        case .success:
            ivTypeImage.image = UIImage(named: "icon_alert_success")
        case .error, .retry:
            ivTypeImage.image = UIImage(named: "icon_alert_error")
        case .classic:
            break
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        cancel?()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirm(_ sender: Any) {
        confirm?()
        self.dismiss(animated: false, completion: nil)
    }
}
