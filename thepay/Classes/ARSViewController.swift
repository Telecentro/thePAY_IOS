//
//  ARSViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
// telprompt://080-31-00796
class ARSViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var btnCall: TPButton!
    
    var isAirplaneMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        initialize()
    }
    
    func localize() {
        lblTitle.text = Localized.activity_main_list_ars_charge_title.txt
        lblDesc.attributedText = Localized.ars_charge_guide_content.txt.convertHtml(fontSize: 18)
        
        if isAirplaneMode {
            setupNavigationBar(type: .basic(title: ""))
            btnCall.setTitle(Localized.ars_charge_guide_btn_text.txt, for: .normal)
        } else {
            btnCall.setTitle(Localized.ars_charge_guide_btn_text.txt, for: .normal)
        }
    }
    
    func initialize() {
        print("")
    }
    
    @IBAction func thePayCall(_ sender: Any) {
        let str: String = "telprompt://080-31-00796"
        guard let schemeURL = URL(string: str) else { return }
        UIApplication.shared.open(schemeURL, options: [:], completionHandler: nil)
    }
    
}
