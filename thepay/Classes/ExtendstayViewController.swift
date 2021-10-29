//
//  ExtendstayViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class ExtendstayViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var btnNext: TPButton!
    
    var data: [UserformPreResponse.O_DATA.formList]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? ExtendstayDetailViewController {
            vc.formData = self.data
        }
    }
    
    func localize() {
        lblTitle.text = Localized.request_extend_stay_title.txt
        lblDesc.text = Localized.request_extend_stay_explain.txt
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
    }
    
    func initialize() {
        // TODO: 인디케이터 필요, HTML 변환 필요
        request()
    }
}

// MARK: - 통신
extension ExtendstayViewController {
    func request() {
        let req = UserformPreRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<UserformPreResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                if let html = data.O_DATA?.formMsg?.convertHtml(fontSize: 18) {
                    self.lblDesc.attributedText = html
                }
                
                self.data = data.O_DATA?.formList
                
                print("UserformPre success: \(data)")
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
}
