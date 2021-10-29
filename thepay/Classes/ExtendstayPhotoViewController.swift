//
//  ExtendstayPhotoViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/03.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import BSImagePicker

class ExtendstayPhotoViewController: TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var lblGuide: TPLabel!
    @IBOutlet weak var lblRequireTitle: TPLabel!
    @IBOutlet weak var lblOptionTitle: TPLabel!
    
    @IBOutlet weak var lblFront: TPLabel!
    @IBOutlet weak var lblBack: TPLabel!
    
    @IBOutlet weak var lblOption: TPLabel!
    @IBOutlet weak var lblOptionDetail: TPLabel!
    
    @IBOutlet weak var lblConfirm: TPLabel!
    @IBOutlet weak var lblConfirmDetail: TPLabel!
    
    @IBOutlet weak var ivFront: UIImageView!
    @IBOutlet weak var ivBack: UIImageView!
    @IBOutlet weak var ivOption: UIImageView!
    @IBOutlet weak var ivConfirm: UIImageView!
    
    @IBOutlet weak var ivCheckFront: UIImageView!
    @IBOutlet weak var ivCheckBack: UIImageView!
    @IBOutlet weak var ivCheckOption: UIImageView!
    @IBOutlet weak var ivCheckConfirm: UIImageView!
    
    @IBOutlet weak var btnDetail1: TPButton!    // xeozin 2020/09/26 기능 추가
    @IBOutlet weak var btnDetail2: TPButton!
    @IBOutlet weak var btnDetail3: TPButton!
    @IBOutlet weak var btnDetail4: TPButton!
    @IBOutlet weak var btnNext: TPButton!
    @IBOutlet weak var lblTitle: TPLabel!
    
    // 2021.4.3
    
    @IBOutlet weak var btnDetailPrivacy: TPButton!
    @IBOutlet weak var lblPrivacy: TPLabel!
    @IBOutlet weak var btnPrivacyAgree: TPButton!
    
    var detailInfo: ExtendstayBeforeData.ExtendstayDetailInfo?
    
    var front: Data?
    var back: Data?
    var option: Data?
    var confirm: Data?
    
    var imageInfo: ExtendstayBeforeData.ExtendstayImageInfo?
    
    var currentCameraType: CameraType = .alienCardFront
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    
    func localize() {
        lblTitle.text = Localized.request_extend_stay_title.txt
        updateTitle(title: Localized.request_extend_stay_title.txt)
        btnNext.setTitle(Localized.btn_next.txt, for: .normal)
        lblGuide.text = Localized.request_extend_stay_guide_capture_auth.txt
        lblRequireTitle.text = Localized.request_extend_stay_required.txt
        lblFront.text = Localized.request_extend_stay_auth_foreign_card_front.txt
        lblBack.text = Localized.request_extend_stay_auth_foreign_card_back.txt
        lblOptionTitle.text = Localized.request_extend_stay_not_required.txt
        lblOption.text = Localized.request_extend_stay_auth_passport.txt
        lblOptionDetail.text = Localized.request_extend_stay_guide_for_passport.txt
        
        // 2020.4.3
        lblConfirm.text = Localized.request_extend_e_complaint_agree_confirmation_title.txt
        lblConfirmDetail.text = Localized.request_extend_e_complaint_agree_confirmation_contents.txt
        btnDetailPrivacy.setTitle(Localized.join_detail.txt, for: .normal)
        lblPrivacy.text = Localized.checkbox_consent_to_use_of_personal_information.txt
    }
    
    func initialize() {
        
        self.ivCheckFront.isHidden = true
        self.ivCheckBack.isHidden = true
        self.ivCheckOption.isHidden = true
        self.ivCheckConfirm.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignViewController {
            vc.signType = .extend
            if let detail = detailInfo, let image = imageInfo {
                vc.extendstayBeforeData = ExtendstayBeforeData(detail: detail, image: image)
            }
        }
        
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: currentCameraType)
            }
        }
        
        // xeozin 2020/09/26 photo detail
        if let vc = segue.destination as? ContactDetailViewController {
            vc.hiddenCloseButton = false
            switch segue.identifier {
            case "detail1":
                vc.imgData = front
            case "detail2":
                vc.imgData = back
            case "detail3":
                vc.imgData = option
            case "detail4":
                vc.imgData = confirm
            default: break
            }
        }
    }
    
    //    xeozin 2020/09/26 reason: 카메라 권한 로직 추가
    func showCamera(type: CameraType) {
        currentCameraType = type
        
        let permission = CameraPermission()
        permission.showCamera {
            performSegue(withIdentifier: CameraPermission.cameraSegue, sender: nil)
        } denied: {
            permission.showCameraPermissionAlert(vc: self)
        } notDetermined: {
            self.performSegue(withIdentifier: CameraPermission.cameraSegue, sender: nil)
        }
    }
    
    @IBAction func captureFront(_ sender: Any) {
        showCamera(type: .alienCardFront)
    }
    
    @IBAction func captureBack(_ sender: Any) {
        showCamera(type: .alienCardBack)
    }
    
    @IBAction func captureOption(_ sender: Any) {
        showCamera(type: .passport)
    }
    
    @IBAction func captureConfirm(_ sender: Any) {
        showCamera(type: .a4)
    }
    
    @IBAction func checkAgreePrivacy(_ sender: UIButton) {
        // toast_notcheck_use
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func showWebView(_ sender: Any) {
        guard let webViewController:TPBaseViewController = Link.webview.viewController else { return }
        
        if let vc = webViewController as? WebViewController {
            vc.needFakeButton = false
            vc.titleString = Localized.join_privacy_guidelines.txt
            vc.urlString = ServiceURL.dev.wv_privacy_extendstay
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func cameraRoll(type: CameraType, min:Int, max: Int) {
        let permission = CameraRollPermission()
        permission.showAlbum { [weak self] in
            self?.imagePicker(type: type, min: min, max: max)
        } denied: {
            permission.showAlbumPermissionAlert(vc: self)
        }
    }
    
    private func imagePicker(type: CameraType, min:Int, max: Int) {
        self.currentCameraType = type
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = max
        imagePicker.settings.selection.min = min
        imagePicker.settings.selection.unselectOnReachingMax = true
        self.presentImagePicker(imagePicker, animated: true, select: nil, deselect: nil, cancel: nil, finish: { [weak self] assets in
            if assets.count > 0 {
                self?.sendImage(image: assets[0].getAssetThumbnail(), type: type)
            }
        })
    }
    
    @IBAction func cameraRollFront(_ sender: Any) {
        cameraRoll(type: .alienCardFront, min: 1, max: 1)
    }
    
    @IBAction func cameraRollBack(_ sender: Any) {
        cameraRoll(type: .alienCardBack, min: 1, max: 1)
    }
    
    @IBAction func cameraRollOption(_ sender: Any) {
        cameraRoll(type: .passport, min: 1, max: 1)
    }
    
    @IBAction func cameraRollConfirm(_ sender: Any) {
        cameraRoll(type: .a4, min: 1, max: 1)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowSign" {
            if btnPrivacyAgree.isSelected == false {
                Localized.toast_consent_to_use_of_personal_information_agreement.txt.showErrorMsg(target: self.view)
                return false
            }
            
            guard let frontData = front else {
                Localized.request_extend_stay_auth_foreign_card_front.txt.showErrorMsg(target: self.view)
                return false
            }
            
            guard let backData = back else {
                Localized.request_extend_stay_auth_foreign_card_back.txt.showErrorMsg(target: self.view)
                return false
            }
            
            
            
            imageInfo = ExtendstayBeforeData.ExtendstayImageInfo(front: frontData, back: backData, option: option, confirm: confirm)
        }
        
        return true
    }
}

extension ExtendstayPhotoViewController : CaptureDelegate {
    
    func sendImage(image: UIImage, type: CameraType?) {
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        switch type {
        case .alienCardFront:
            front = jpg
            ivFront.image = UIImage(data: jpg)
            self.btnDetail1.isHidden = false
            self.ivCheckFront.isHidden = false
        case .alienCardBack:
            back = jpg
            ivBack.image = UIImage(data: jpg)
            self.btnDetail2.isHidden = false
            self.ivCheckBack.isHidden = false
        case .passport:
            option = jpg
            ivOption.image = UIImage(data: jpg)
            self.btnDetail3.isHidden = false
            self.ivCheckOption.isHidden = false
        case .a4:
            confirm = jpg
            ivConfirm.image = UIImage(data: jpg)
            self.btnDetail4.isHidden = false
            self.ivCheckConfirm.isHidden = false
        default:
            break
        }
    }
    
}
