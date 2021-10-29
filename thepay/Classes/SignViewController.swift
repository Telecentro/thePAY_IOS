//
//  ExtendstaySignViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/05.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import PPSSignatureView



struct ExtendstayBeforeData {
    struct ExtendstayDetailInfo {
        var engName: String
        var mvnoId: String
    }
    
    struct ExtendstayImageInfo {
        var front: Data
        var back: Data
        var option: Data?
        var confirm: Data?
    }
    
    var detail: ExtendstayDetailInfo
    var image: ExtendstayImageInfo
    var sign: Data?
}

struct SafeCardBeforeData {
    struct SafeCardInfo {
        var insert: String
        var detect: String
    }
    
    struct SafeCardImageInfo {
        var front: Data?
        var back: Data?
        var idCard: Data?
        var face: Data?
    }
    
    var card: SafeCardInfo
    var image: SafeCardImageInfo
    var sign: Data?
}

enum SignType {
    case extend
    case card
    case open
}

protocol SignDelegate {
    func signImage(image: UIImage)
}

class SignViewController: TPBaseViewController, TPLocalizedController {
    
    var delegate: SignDelegate?
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var lblSignGuide: TPLabel!
    @IBOutlet weak var signView: PPSSignatureView!
    @IBOutlet weak var btnNext: TPButton!
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var ivTitleImage: UIImageView!
    
    
    var signType: SignType = .extend
    
    var safeCardBeforeData: SafeCardBeforeData?
    var extendstayBeforeData: ExtendstayBeforeData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
        
        initialize()
        localize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    func initialize() {
        signView.backgroundColor = .clear
        
        switch signType {
        case .card:
            ivTitleImage.image = UIImage(named: "icon_secured_sub")
        case .extend:
            ivTitleImage.image = UIImage(named: "icon_extend_sub")
        default:
            break
        }
    }
    
    func localize() {
        switch self.signType {
        case .extend:
            self.lblTitle.text = Localized.request_extend_stay_title.txt
            self.setupNavigationBar(type: .basic(title: ""))
            lblSignGuide.text = Localized.request_extend_stay_edit_sign_hint.txt
            lblDesc.text = Localized.request_extend_stay_final_guide.txt
            lblDesc.isHidden = false
        case .card, .open:
            self.lblTitle.text = Localized.safe_card_input_signature.txt
            self.setupNavigationBar(type: .basic(title: ""))
            lblSignGuide.text = Localized.request_extend_stay_edit_sign_hint.txt
            lblDesc.isHidden = true
        }
        
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
    }
    
    @IBAction func resetSign(_ sender: Any) {
        signView.erase()
        signView.setNeedsDisplay()
    }
    
    @IBAction func next(_ sender: Any) {
        if signView.signatureImage == nil {
            Localized.error_not_exist_safe_card_input_signature.txt.showErrorMsg(target: self.view)
        } else {
            sendData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SafeEndViewController {
            safeCardBeforeData?.sign = self.signView.signatureImage.pngData()
            vc.info = self.safeCardBeforeData
        }
    }
    
    private func sendData() {
        switch self.signType {
        case .extend:
            self.showLoadingWindow()
            let req = UserFormStoreRequest()
            guard let p = req.getParam() else { return }
            API.shared.upload(url: req.getAPI(), param: addParam(p: p), type: .period) { [weak self] (response:Swift.Result<UserFormStoreResponse, TPError>) -> Void in
                guard let self = self else { return }
                switch response {
                case .success(let data):
                    self.showConfirmAlertSystem(title: "", message: data.O_MSG) {
                        self.performSegue(withIdentifier: "unwindMain", sender: nil)
                    }
                case .failure(let error):
                    error.processError(target: self)
                }
                self.hideLoadingWindow()
            }
        case .card:
            self.performSegue(withIdentifier: "ShowCardEnd", sender: nil)
        case .open:
            self.delegate?.signImage(image: signView.signatureImage)
            self.navigationController?.popViewController(animated: true)
            break
        }
    }
    
    private func addParam(p: [String : Any]) -> [String : Any] {
        var param = p
        /* Detail */
        param.updateValue(extendstayBeforeData?.detail.engName ?? "", forKey: "userName")
        param.updateValue(extendstayBeforeData?.detail.mvnoId ?? "", forKey: "mvnoId")
        
        /* Image (Front) */
        param.updateValue("FNF", forKey: "fileType")
        param.updateValue(extendstayBeforeData?.image.front ?? "", forKey: "uploadFile")
        
        /* Image (Back) */
        param.updateValue("FNR", forKey: "fileType2")
        param.updateValue(extendstayBeforeData?.image.back ?? "", forKey: "uploadFile2")
        
        /* Image (Option) */
        var next = 3
        if let PN = extendstayBeforeData?.image.option {
            param.updateValue("PN", forKey: "fileType3")
            param.updateValue(PN, forKey: "uploadFile3")
            next = 4
        }
        
        /* Image (confirm) */
        if let CPA = extendstayBeforeData?.image.confirm {
            param.updateValue("CPA", forKey: "fileType\(next)")
            param.updateValue(CPA, forKey: "uploadFile\(next)")
            next = 5
        }
        
        /* Sign */
        let sign = signView.signatureImage.jpegData(compressionQuality: 0.5)
        param.updateValue("SIGN", forKey: "fileType\(next)")
        param.updateValue(sign ?? "", forKey: "uploadFile\(next)")
        
        /* 추가 */
        param.updateValue(UserDefaultsManager.shared.loadANI() ?? "", forKey: "userAni")
        
        return param
    }
}

//extension SignViewController {
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .landscapeLeft
//    }
//    
//    override var shouldAutorotate: Bool {
//        return false
//    }
//    
//}
