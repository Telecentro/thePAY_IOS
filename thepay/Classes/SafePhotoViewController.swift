//
//  SafePhotoViewController.swift
//  thepay
//
//  Created by xeozin on 2020/08/13.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import AVFoundation

class SafePhotoViewController: TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var btnNext: TPButton!
    @IBOutlet weak var lblCameraTitle: TPLabel!
    @IBOutlet weak var lblCreditCardFront: TPLabel!
    @IBOutlet weak var lblCreditCardRear: TPLabel!
    @IBOutlet weak var lblIDCardFront: TPLabel!
    @IBOutlet weak var lblFace: TPLabel!
    
    @IBOutlet weak var imgCreditCardFront: UIImageView!
    @IBOutlet weak var imgCreditCardRear: UIImageView!
    @IBOutlet weak var imgIDCardFront: UIImageView!
    @IBOutlet weak var imgFace: UIImageView!
    
    @IBOutlet weak var ivCheckFront: UIImageView!
    @IBOutlet weak var ivCheckBack: UIImageView!
    @IBOutlet weak var ivCheckIdCard: UIImageView!
    @IBOutlet weak var ivCheckFace: UIImageView!
    @IBOutlet weak var ivFaceHolder: UIImageView!
    
    @IBOutlet weak var btnDetail1: TPButton!    // xeozin 2020/09/25 기능 추가
    @IBOutlet weak var btnDetail2: TPButton!
    @IBOutlet weak var btnDetail3: TPButton!
    @IBOutlet weak var btnDetail4: TPButton!
    @IBOutlet weak var lblTitle: TPLabel!
    
    var front: Data?
    var back: Data?
    var idCard: Data?
    var face: Data?
    
    var cardInfo: SafeCardBeforeData.SafeCardInfo?
    var imageInfo: SafeCardBeforeData.SafeCardImageInfo?
    
    var currentCameraType: CameraType = .creditCardFront
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignViewController {
            vc.signType = .card
            if let image = imageInfo, let card = cardInfo {
                vc.safeCardBeforeData = SafeCardBeforeData(card: card, image: image)
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
                vc.imgData = idCard
            case "detail4":
                vc.imgData = face
            default: break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowSign" {
            guard let frontData = front else {
                Localized.error_not_exist_safe_card_capture_credit_card.txt.showErrorMsg(target: self.view)
                return false
            }
            
            guard let idCardData = idCard else {
                Localized.error_not_exist_safe_card_capture_alien_card_front.txt.showErrorMsg(target: self.view)
                return false
            }
            
            guard let faceData = face else {
                Localized.error_not_exist_safe_card_capture_self_camera.txt.showErrorMsg(target: self.view)
                return false
            }
            
            imageInfo = SafeCardBeforeData.SafeCardImageInfo(front: frontData, back: back, idCard: idCardData, face: faceData)
        }
        
        return true
    }
    
    func initialize() {
        ivCheckFront.isHidden = true
        ivCheckBack.isHidden = true
        ivCheckIdCard.isHidden = true
        ivCheckFace.isHidden = true
    }
    
    func localize() {
        self.lblTitle.text = Localized.btn_safe_card_registration.txt
        self.lblCameraTitle.text = Localized.safe_card_do_capture.txt
        self.setupNavigationBar(type: .basic(title: Localized.btn_safe_card_registration.txt))
        self.lblCreditCardFront.text = Localized.safe_card_capture_credit_card.txt
        self.lblCreditCardRear.text = Localized.safe_card_capture_credit_card_back.txt
        self.lblIDCardFront.text = Localized.safe_card_capture_alien_card_front.txt
        self.lblFace.text = Localized.safe_card_capture_self_camera.txt
        self.btnNext.setTitle(Localized.btn_next.txt, for: .normal)
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
        showCamera(type: .creditCardFront)
    }
    
    @IBAction func captureBack(_ sender: Any) {
        showCamera(type: .creditCardBack)
    }
    
    @IBAction func captureIdCard(_ sender: Any) {
        showCamera(type: .idCardFront)
    }
    
    @IBAction func captureFace(_ sender: Any) {
        showCamera(type: .myFace)
    }
}

extension SafePhotoViewController : CaptureDelegate {
    
    /* 이미지 전용 */
    func sendImage(image: UIImage, type: CameraType?) {
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        switch type {
        case .creditCardBack:
            back = jpg
            imgCreditCardRear.image = UIImage(data: jpg)
            self.btnDetail2.isHidden = false
            self.ivCheckBack.isHidden = false
        case .idCardFront:
            idCard = jpg
            imgIDCardFront.image = UIImage(data: jpg)
            self.btnDetail3.isHidden = false
            self.ivCheckIdCard.isHidden = false
        case .myFace:
            face = jpg
            imgFace.isHidden = true
            ivFaceHolder.image = UIImage(data: jpg)
            self.btnDetail4.isHidden = false
            self.ivCheckFace.isHidden = false
        default:
            break
        }
    }
    
    /* 카드 전용 */
    func sendImage(image: UIImage, type: CameraType?, cardInfo: SafeCardBeforeData.SafeCardInfo) {
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        switch type {
        case .creditCardFront:
            front = jpg
            imgCreditCardFront.image = UIImage(data: jpg)
            self.cardInfo = cardInfo
            self.btnDetail1.isHidden = false
            self.ivCheckFront.isHidden = false
        default:
            break
        }
    }
}
