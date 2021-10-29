//
//  TextPopViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/25.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TextPopViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var btnCancel: TPButton!
    @IBOutlet weak var btnConfirm: TPButton!
    @IBOutlet weak var vLine: UIView!
    
    var titleText: NSAttributedString?
    var descText: NSAttributedString?
    var confirm: (()->())?
    var cancel: (()->())?
    var isSingleConfirm = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        btnCancel.setTitle(Localized.btn_cancel.txt, for: .normal)
        btnConfirm.setTitle(Localized.btn_confirm.txt, for: .normal)
    }
    
    func initialize() {
        if isSingleConfirm {
            btnCancel.isHidden = true
            vLine.isHidden = true
        }
        
        lblTitle.attributedText = titleText
        lblDesc.attributedText = descText
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
