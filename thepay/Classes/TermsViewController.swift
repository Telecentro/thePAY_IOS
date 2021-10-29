//
//  TermsViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/10.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class TermsViewController: TPBaseViewController, TPLocalizedController {
    

    @IBOutlet var btnCheckAll: TPButton!
    @IBOutlet var btnCheckArray: [TPButton]!
    
    @IBOutlet weak var btnTermsAgree: TPButton!
    @IBOutlet weak var btnPrivacyAgree: TPButton!
    @IBOutlet weak var btnCollectAgree: TPButton!
    
    @IBOutlet weak var btnDetailTerms: TPButton!
    @IBOutlet weak var btnDetailPrivacy: TPButton!
    @IBOutlet weak var btnDetailCollect: TPButton!
    
    @IBOutlet weak var btnNext: TPButton!
    
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblEntireAgreement: TPLabel!
    @IBOutlet weak var lblOlder14: TPLabel!
    @IBOutlet weak var lblTermsOfUse: TPLabel!
    @IBOutlet weak var lblPrivacy: TPLabel!
    @IBOutlet weak var lblAdvertise: TPLabel!
    @IBOutlet weak var lblPrivacyCollect: TPLabel!
    
    var loginList: [PreCheckResponse.loginList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignInViewController {
            vc.loginList = self.loginList
        }
    }
    
    func localize() {
        lblTitle.text = Localized.title_join_terms.txt
        lblEntireAgreement.text = Localized.join_entire_agreement.txt
        lblOlder14.text = Localized.join_over_14_years_old.txt
        lblTermsOfUse.text = Localized.join_terms_of_use.txt
        lblPrivacy.text = Localized.join_privacy_guidelines.txt
        lblAdvertise.text = Localized.join_sms_agreement.txt
        lblPrivacyCollect.text = Localized.join_userinfo_collection_usage_agreement.txt
        
        btnNext.setTitle(Localized.join_button_terms_agree.txt, for: .normal)
    }
    
    func initialize() {
        // 퍼미션 확인
        UserDefaultsManager.shared.savePermisionConfirm(value: true)
        self.setupNavigationBar(type: .logoOnly2)
    }
    
    @IBAction func next(_ sender: Any) {
        if self.validate() == false {
            return
        }
        
        self.showLoadingWindow()
        let req = PreCheckRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<PreCheckResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                self.loginList = data.O_DATA?.loginList ?? []
                SegueUtils.openMenu(target: self, link: .signin)
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    func validate() -> Bool {
        
        if self.btnTermsAgree.isSelected == false {
            Localized.toast_notcheck_use.txt.showErrorMsg(target: self.view)            // 이용약관에 동의해주세요
            return false
        } else if self.btnPrivacyAgree.isSelected == false {
            Localized.toast_notcheck_privacy.txt.showErrorMsg(target: self.view)            // 개인정보 취급 방침에 동의해주세요
            return false
        } else if self.btnCollectAgree.isSelected == false {
            "개인정보 수집 및 이용 동의가 필요합니다.".showErrorMsg(target: self.view)
            return false
        }
        
        return true
    }
    
    @IBAction func showWebView(_ sender: UIButton) {
        guard let webViewController:TPBaseViewController = Link.webview.viewController else { return }
        
        if let vc = webViewController as? WebViewController {
            vc.needFakeButton = false
            switch sender {
            case btnDetailTerms:
                vc.titleString = Localized.join_terms_of_use.txt
                vc.urlString = ServiceURL.dev.wv_terms
                
            case btnDetailPrivacy:
                vc.titleString = Localized.join_privacy_guidelines.txt
                vc.urlString = ServiceURL.dev.wv_privacy
                
            case btnDetailCollect:
                vc.titleString = Localized.join_privacy_guidelines.txt
                vc.urlString = ServiceURL.dev.wv_collect
                
            default:
                print("Terms")
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
     *  전체 동의 버튼
     */
    @IBAction func checkAll(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for button in btnCheckArray {
            button.isSelected = sender.isSelected
        }
    }
    
    /**
     * 나머지 동의 버튼
     */
    @IBAction func checkButtons(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        var find: Bool = false
        for button in btnCheckArray {
            if !button.isSelected {
                find = true
                break
            }
        }
        
        btnCheckAll.isSelected = !find
    }
    
}
