//
//  EasyTermsViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasyTermsViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblAgree: TPLabel!
    @IBOutlet weak var lblReq1: TPLabel!
    @IBOutlet weak var lblReq2: TPLabel!
    @IBOutlet weak var lblReq3: TPLabel!
    @IBOutlet weak var lblTitle1: TPLabel!
    @IBOutlet weak var lblTitle2: TPLabel!
    @IBOutlet weak var lblTitle3: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    
    @IBOutlet weak var btnNext: TPButton!
    var isChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    @IBAction func agreeTerms(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isChecked = sender.isSelected
    }
    
    func localize() {
        lblTitle.text = Localized.text_guide_please_reg_easy_payment.txt
        lblAgree.text = Localized.checkbox_title_easy_payment_essential_terms_agree.txt
        lblReq1.text = Localized.text_title_essential.txt
        lblReq2.text = Localized.text_title_essential.txt
        lblReq3.text = Localized.text_title_essential.txt
        lblTitle1.text = Localized.text_title_terms_of_service.txt
        lblTitle2.text = Localized.text_title_terms_of_personal_infomation.txt
        lblTitle3.text = Localized.text_title_terms_of_financial_transactions.txt
        lblDesc.text = Localized.text_guide_easy_payment_terms_read_and_agree.txt
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
    }
    
    func initialize() { }
    
    @IBAction func next(_ sender: Any) {
        if isChecked {
            SegueUtils.parseMoveLink(target: self, link: "\(Link.easy_pay.rawValue)?tab_type=1");
        } else {
            Localized.text_guide_please_reg_easy_payment.txt.showErrorMsg(target: self.view)
        }
    }
    
    @IBAction func showEasyTerms(_ sender: Any) {
        guard let webViewController:TPBaseViewController = Link.webview.viewController else { return }
        
        if let vc = webViewController as? WebViewController {
            vc.needFakeButton = false
            vc.urlString = ServiceURL.dev.wv_easy_terms
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func showEasyPrivate(_ sender: Any) {
        guard let webViewController:TPBaseViewController = Link.webview.viewController else { return }
        
        if let vc = webViewController as? WebViewController {
            vc.needFakeButton = false
            vc.urlString = ServiceURL.dev.wv_easy_privacy
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func showEasyBasic(_ sender: Any) {
        guard let webViewController:TPBaseViewController = Link.webview.viewController else { return }
        
        if let vc = webViewController as? WebViewController {
            vc.needFakeButton = false
            vc.urlString = ServiceURL.dev.wv_easy_basic
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
