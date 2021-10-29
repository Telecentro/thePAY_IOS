//
//  SafeCardViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import AVFoundation

class SafeCardViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var btnNext: TPButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        let tipText = Localized.safe_card_ragistration_tip.txt
        let howToText = Localized.safe_card_ragistration_how_to.txt
        let combinedText = "\(tipText)<br /><br />\(howToText)"
        lblTitle.text = Localized.btn_safe_card_registration.txt
        lblDesc.attributedText = combinedText.convertHtml(fontSize: 18)
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
    }
    
    func initialize() {}
    
}
