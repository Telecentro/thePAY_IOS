//
//  SafeEndViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/07.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit



class SafeEndViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var btnNext: TPButton!
    @IBOutlet weak var lblTitle: TPLabel!
    
    var info: SafeCardBeforeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        localize()
    }
    
    func localize() {
        lblTitle.text = Localized.btn_safe_card_registration.txt
        self.updateTitle(title: Localized.btn_safe_card_registration.txt)
        self.btnNext.setTitle(Localized.btn_next.txt, for: .normal)
        self.lblDesc.attributedText = Localized.safe_card_registration_support_text.txt.convertHtml(fontSize: 18)
    }
    
    func initialize() {
        
    }
    
    @IBAction func next(_ sender: Any) {
        sendData()
    }
    
    private func sendData() {
        self.showLoadingWindow()
        let req = CardFormStoreRequest()
        guard let p = req.getParam() else { return }
        API.shared.upload(url: req.getAPI(), param: addParam(p: p), type: .safe_card) { [weak self] (response:Swift.Result<CardFormStoreResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.showConfirmAlert(title: "", message: data.O_MSG) {
                    self.performSegue(withIdentifier: "unwindMain", sender: nil)
                }
            case .failure(let error):
                error.processError(target: self)
            }
            self.hideLoadingWindow()
        }
    }
    
    private func addParam(p: [String : Any]) -> [String : Any] {
        var param = p
        
        /* Card Info */
        param.updateValue(encString(data: info?.card.insert.data(using: .utf8)) ?? "", forKey: Key.CARDNUM)
        param.updateValue(encString(data: info?.card.detect.data(using: .utf8)) ?? "", forKey: Key.UserFormStore.CARDNUM_APP)
        
        /* Image */
        var i = 0
        param.updateValue(encData(data: info?.image.front) ?? "", forKey: "uploadFile\(i)")
        i = i + 1
        if let back = info?.image.back {
            param.updateValue(encData(data: back) ?? "", forKey: "uploadFile\(i)")
            i = i + 1
        }
        param.updateValue(encData(data: info?.image.idCard) ?? "", forKey: "uploadFile\(i)")
        i = i + 1
        param.updateValue(encData(data: info?.image.face) ?? "", forKey: "uploadFile\(i)")
        i = i + 1
        param.updateValue(encData(data: info?.sign) ?? "", forKey: "uploadFile\(i)")
        print("🎁 \(param)")
        return param
    }
    
    private func encString(data: Data?) -> String? {
        if let d = data {
            return AES256.encryptionAES256NotEncDate(data: d).base64EncodedString()
        } else {
            return nil
        }
    }
    
    private func encData(data: Data?) -> Data? {
        if let d = data {
            return AES256.encryptionAES256NotEncDate(data: d)
        } else {
            return nil
        }
    }
    
    
}
