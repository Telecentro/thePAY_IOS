//
//  EasyPayInfoViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasyInfoViewController : TPBaseViewController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblStep1: TPLabel!
    @IBOutlet weak var lblStep2: TPLabel!
    @IBOutlet weak var lblStep3: TPLabel!
    @IBOutlet weak var lblStep4: TPLabel!
    @IBOutlet weak var btnNext: TPButton!
}

// MARK: 라이프 사이클
extension EasyInfoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    /**
     *  NEXT 버튼 터치
     */
    @IBAction func next(_ sender: Any) {
        preEazy()
    }
}

// MARK: 번역, 초기화
extension EasyInfoViewController: TPLocalizedController {
    func localize() {
        lblTitle.text = Localized.text_title_easy_payment_tips.txt
        lblStep1.text = Localized.text_title_select_product_you_want.txt
        lblStep2.text = Localized.text_title_easy_payment_switch_on.txt
        lblStep3.text = Localized.text_title_choose_card_you_want.txt
        lblStep4.text = Localized.text_title_pwd_enter.txt
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
    }
    
    func initialize() {
        // 싱글톤 객체 초기화
        EasyRegInfo.shared.clean()
    }
}

// MARK: 통신
extension EasyInfoViewController {
    private func preEazy() {
        let params = PreEasyRequest.Param(easyPaySubSeq: "")
        let req = PreEasyRequest(param: params)
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<PreEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    switch data.O_DATA?.msgBoxGubun?.lowercased() ?? "" {
                    case FLAG.alert:
                        self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG) {
                            if let moveLink = data.O_DATA?.moveLink {
                                SegueUtils.parseMoveLink(target: self, link: moveLink, addParams: Timemachine.pMain)
                            }
                        } cancel: {
                            if let moveLink = data.O_DATA?.moveLink {
                                SegueUtils.parseMoveLink(target: self, link: moveLink, addParams: Timemachine.pMain)
                            }
                        }
                    case FLAG.toast:
                        data.O_MSG.showErrorMsg(target: self.view)
                    default:
                        // 카드 개수 제한에 안 걸리는 경우
                        if let moveLink = data.O_DATA?.moveLink {
                            SegueUtils.parseMoveLink(target: self, link: moveLink)
                        }
                    }
                } else if data.O_CODE == FLAG.E8905 || data.O_CODE == FLAG.E8906 {
                    self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG) {
                        self.navigationController?.popViewController(animated: true)
                    } cancel: {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
}


