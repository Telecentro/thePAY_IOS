//
//  PushHistoryViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/07.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class PushHistoryViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblContents: TPLabel!
    @IBOutlet weak var btnConfirm: TPButton!
    
    var contents: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func localize() {
        self.btnConfirm.setTitle(Localized.btn_confirm.txt, for: .normal)
    }
    
    func initialize() {
        guard let text = contents else { return }
        print("사용 값: \(text)")
        self.lblContents.attributedText = text.convertHtml(fontSize: 20)
    }
    
    @IBAction func pressConfirm(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
