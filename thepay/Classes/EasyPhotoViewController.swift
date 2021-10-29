//
//  EasyPhotoViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit
import Kingfisher

// Android - EasyPayCardPhotoRegFragment.java


class EasyPayPhotoView: UIView {
    @IBOutlet weak var btnCheck: TPButton!
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var ivImage: UIImageView!
    
    var hasImage = false
    var type: CameraType?
    
    var showCamera:(()->Void)?
    var showImage:(()->Void)?
    
    func setup(type: CameraType) {
        self.type = type
        self.isHidden = true
    }
    
    func updateImage(data: Data) {
        ivImage.image = UIImage(data: data)
        ivImage.contentMode = .scaleToFill
        addImage()
    }
    
    func addImage() {
        hasImage = true
        btnCheck.isSelected = true
    }
    
    @IBAction func showCamera(_ sender: Any) {
        showCamera?()
    }
    
    @IBAction func showImage(_ sender: Any) {
        showImage?()
    }
    
    func getKey() -> String {
        guard let type = self.type else { return "" }
        switch type {
        case .creditCardFront_Only:
            return FILE_NAME.FILE_CREDIT_CARD_FRONT
        case .creditCardBack:
            return FILE_NAME.FILE_CREDIT_CARD_BACK
        case .alienCardFront:
            return FILE_NAME.FILE_ALINE_CARD_FRONT
        case .alienCardBack:
            return FILE_NAME.FILE_ALINE_CARD_BACK
        case .passport:
            return FILE_NAME.FILE_PASSPORT
        case .myFace:
            return FILE_NAME.FILE_SELF_CAMERA
        case .clear:
            return FILE_NAME.FILE_SIGNATURE
        default:
            return ""
        }
    }
}


class EasyPhotoViewController: EasyStepViewController, TPLocalizedController {
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblSubTitle: TPLabel!
    
    @IBOutlet weak var svp1: EasyPayPhotoView!
    @IBOutlet weak var svp2: EasyPayPhotoView!
    @IBOutlet weak var svp3: EasyPayPhotoView!
    @IBOutlet weak var svp4: EasyPayPhotoView!
    @IBOutlet weak var svp5: EasyPayPhotoView!
    @IBOutlet weak var svp6: EasyPayPhotoView!
    @IBOutlet weak var svp7: EasyPayPhotoView!
    
    var types:[CameraType] = [.creditCardFront_Only, .creditCardBack, .alienCardFront, .alienCardBack, .passport, .myFace, .clear]
    var currentCameraType: CameraType = .creditCardFront
    
    var files: [String: Data] = [:]
    
    var changedImage:((String)->Void)?
    
    override func viewDidLoad() {
        localize()
        initialize()
    }
    
    func localize() {
        lblTitle.text = Localized.text_title_attached_file_registration.txt
        lblSubTitle.text = Localized.text_guide_please_take_picture_reg_for_easy_payment.txt
        svp1.lblTitle.text = Localized.safe_card_capture_credit_card.txt
        svp2.lblTitle.text = Localized.text_title_card_back_essential.txt
        svp3.lblTitle.text = Localized.safe_card_capture_alien_card_front.txt
        svp4.lblTitle.text = Localized.request_extend_stay_auth_foreign_card_back.txt
        svp5.lblTitle.text = Localized.request_extend_stay_auth_passport.txt
        svp6.lblTitle.text = Localized.safe_card_capture_self_camera.txt
        svp7.lblTitle.text = Localized.safe_card_input_signature.txt
    }
    
    func initialize() {
        let svp = [svp1, svp2, svp3, svp4, svp5, svp6, svp7]
        for (i, type) in types.enumerated() {
            svp[i]?.type = type
            svp[i]?.showImage = { [weak self] in
                guard let hasImage = svp[i]?.hasImage else { return }
                if hasImage {
                    // 이미지 노출
                    self?.performSegue(withIdentifier: "detail", sender: svp[i]?.getKey())
                } else {
                    if type != .clear {
                        self?.showCamera(type: type)
                    } else {
                        self?.performSegue(withIdentifier: "Sign", sender: nil)
                    }
                }
            }
            
            svp[i]?.showCamera = { [weak self] in
                if type != .clear {
                    self?.showCamera(type: type)
                } else {
                    self?.performSegue(withIdentifier: "Sign", sender: nil)
                }
            }
        }
        
        preEazy()
        loadPrevImages()
    }
    
    private func loadPrevImages() {
        if let step2 = EasyRegInfo.shared.step2 {
            loadImage(path: step2.FILE_PATH_1 ?? "")
            loadImage(path: step2.FILE_PATH_2 ?? "")
            loadImage(path: step2.FILE_PATH_3 ?? "")
            loadImage(path: step2.FILE_PATH_4 ?? "")
            loadImage(path: step2.FILE_PATH_5 ?? "")
            loadImage(path: step2.FILE_PATH_6 ?? "")
            loadImage(path: step2.FILE_PATH_7 ?? "")
        }
    }
    
    private func loadImage(path:String) {
        getImageView(url: path)?.ivImage.downloadImageFrom(path, contentMode: .scaleToFill, completion: { [weak self] data in
            guard let d = data else { return }
            if let key = self?.getFileKey(path) {
                self?.files[key] = d
            }
        })
    }
    
    private func getFileKey(_ url: String) -> String? {
        if url.isEmpty {
            return nil
        }
        
        if url.contains(FILE_NAME.FILE_CREDIT_CARD_FRONT) {
            return FILE_NAME.FILE_CREDIT_CARD_FRONT
        }
        
        if url.contains(FILE_NAME.FILE_CREDIT_CARD_BACK) {
            return FILE_NAME.FILE_CREDIT_CARD_BACK
        }
        
        if url.contains(FILE_NAME.FILE_ALINE_CARD_FRONT) {
            return FILE_NAME.FILE_ALINE_CARD_FRONT
        }
        
        if url.contains(FILE_NAME.FILE_ALINE_CARD_BACK) {
            return FILE_NAME.FILE_ALINE_CARD_BACK
        }
        
        if url.contains(FILE_NAME.FILE_PASSPORT) {
            return FILE_NAME.FILE_PASSPORT
        }
        
        if url.contains(FILE_NAME.FILE_SELF_CAMERA) {
            return FILE_NAME.FILE_SELF_CAMERA
        }
        
        if url.contains(FILE_NAME.FILE_SIGNATURE) {
            return FILE_NAME.FILE_SIGNATURE
        }
        
        return nil
    }
    
    private func getImageView(url: String) -> EasyPayPhotoView? {
        if url.isEmpty {
            return nil
        }
        
        if url.contains(FILE_NAME.FILE_CREDIT_CARD_FRONT) {
            svp1.addImage()
            return svp1
        }
        
        if url.contains(FILE_NAME.FILE_CREDIT_CARD_BACK) {
            svp2.addImage()
            return svp2
        }
        
        if url.contains(FILE_NAME.FILE_ALINE_CARD_FRONT) {
            svp3.addImage()
            return svp3
        }
        
        if url.contains(FILE_NAME.FILE_ALINE_CARD_BACK) {
            svp4.addImage()
            return svp4
        }
        
        if url.contains(FILE_NAME.FILE_PASSPORT) {
            svp5.addImage()
            return svp5
        }
        
        if url.contains(FILE_NAME.FILE_SELF_CAMERA) {
            svp6.addImage()
            return svp6
        }
        
        if url.contains(FILE_NAME.FILE_SIGNATURE) {
            svp7.addImage()
            return svp7
        }
        
        print("empty image url : \(url)")
        return nil
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: currentCameraType)
            }
        }
        
        if let vc = segue.destination as? SignViewController {
            vc.delegate = self
        }
        
        if let vc = segue.destination as? ContactDetailViewController {
            if let key = sender as? String {
                vc.imgData = self.files[key]
            }
        }
        
        if let vc = segue.destination as? SignViewController {
            vc.signType = .open
        }
    }
    
    override func pressNext() {
        if checkData() {
            registerEasy(easyPayStep: "2")
        } else {
            if self.files[FILE_NAME.FILE_CREDIT_CARD_FRONT] == nil {
                Localized.error_not_exist_safe_card_capture_credit_card.txt.showErrorMsg(target: self.view)
                return
            }
            
            if self.files[FILE_NAME.FILE_CREDIT_CARD_BACK] == nil {
                Localized.toast_msg_check_card_back.txt.showErrorMsg(target: self.view)
                return
            }
            
        }
    }
    
    private func updateDisplay(options: PreEasyResponse.rcvOptionList) {
        svp1.isHidden = !(options.CREDITCARD_PIC1 == "Y")
        svp2.isHidden = !(options.CREDITCARD_PIC2 == "Y")
        svp3.isHidden = !(options.FOREIGN_PIC1 == "Y")
        svp4.isHidden = !(options.FOREIGN_PIC2 == "Y")
        svp5.isHidden = !(options.PASSPORT_PIC == "Y")
        svp6.isHidden = !(options.SELF_PIC == "Y")
        svp7.isHidden = !(options.SIGN_PIC == "Y")
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
    
    private func encData(data: Data?) -> Data? {
        if let d = data {
            return AES256.encryptionAES256NotEncDate(data: d)
        } else {
            return nil
        }
    }
    
    
    private func addParam(p: [String : Any]) -> [String : Any] {
        var param = p
        param.updateValue(encData(data: self.files[FILE_NAME.FILE_CREDIT_CARD_FRONT]) ?? "", forKey: FILE_NAME.FILE_CREDIT_CARD_FRONT)
        param.updateValue(encData(data: self.files[FILE_NAME.FILE_CREDIT_CARD_BACK]) ?? "", forKey: FILE_NAME.FILE_CREDIT_CARD_BACK)
        return param
    }
    
    private func checkData() -> Bool {
        if let _ = self.files[FILE_NAME.FILE_CREDIT_CARD_FRONT], let _ = self.files[FILE_NAME.FILE_CREDIT_CARD_BACK] {
            return true
            
        } else {
            return false
        }
        
        
    }
}


extension EasyPhotoViewController : CaptureDelegate {
    
    /* 이미지 전용 */
    func sendImage(image: UIImage, type: CameraType?) {
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        switch type {
        case .creditCardFront_Only:
            self.files[FILE_NAME.FILE_CREDIT_CARD_FRONT] = jpg
            svp1.updateImage(data: jpg)
            changedImage?(FILE_NAME.FILE_CREDIT_CARD_FRONT)
            break
        case .creditCardBack:
            self.files[FILE_NAME.FILE_CREDIT_CARD_BACK] = jpg
            svp2.updateImage(data: jpg)
            changedImage?(FILE_NAME.FILE_CREDIT_CARD_BACK)
            break
        case .alienCardFront:
            self.files[FILE_NAME.FILE_ALINE_CARD_FRONT] = jpg
            svp3.updateImage(data: jpg)
            changedImage?(FILE_NAME.FILE_ALINE_CARD_FRONT)
            break
        case .alienCardBack:
            self.files[FILE_NAME.FILE_ALINE_CARD_BACK] = jpg
            svp4.updateImage(data: jpg)
            changedImage?(FILE_NAME.FILE_ALINE_CARD_BACK)
            break
        case .passport:
            self.files[FILE_NAME.FILE_PASSPORT] = jpg
            svp5.updateImage(data: jpg)
            changedImage?(FILE_NAME.FILE_PASSPORT)
            break
        case .myFace:
            self.files[FILE_NAME.FILE_SELF_CAMERA] = jpg
            svp6.updateImage(data: jpg)
            changedImage?(FILE_NAME.FILE_SELF_CAMERA)
            break
        default:
            break
        }
    }
}

extension EasyPhotoViewController: SignDelegate {
    func signImage(image: UIImage) {
        guard let jpg = image.jpegData(compressionQuality: 0.5) else { return }
        svp7.updateImage(data: jpg)
        changedImage?(FILE_NAME.FILE_SIGNATURE)
    }
}

extension EasyPhotoViewController {
    
    
    private func preEazy() {
        let params = PreEasyRequest.Param(easyPaySubSeq: "")
        let req = PreEasyRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<PreEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if let options = data.O_DATA?.rcvOptionList {
                    self.updateDisplay(options: options)
                }
            case .failure(let error):
                error.processError(target: self)
                // 8905, 8906 에러처리
            }
        }
    }
    
    
    // 간편결제 등록(PIN, 카드 이미지, 카유비생)
    private func registerEasy(easyPayStep: String) {
        let params = RegisterEasyRequest.Param(
            easyPaySubSeq: EasyRegInfo.shared.seq ?? "",
            easyPayStep: easyPayStep,
            easyPayAuthNum: emptyString,
            CREDIT_BILL_TYPE: emptyString,
            cardNum: emptyString,
            cardExpireYY: emptyString,
            cardExpireMM: emptyString,
            cardPsswd: emptyString,
            userSecureNum: emptyString
        )
        
        let req = RegisterEasyRequest(param: params)
        showLoading?()
        guard let p = req.getParam() else { return }
        API.shared.upload(url: req.getAPI(), param: addParam(p: p), type: .easy_pay) { (response: Swift.Result<RegisterEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    EasyRegInfo.shared.seq = String(data.O_DATA?.easyPaySubSeq ?? 0)
                    self.changedImage?("")
                    self.press?()
                } else if data.O_CODE == FLAG.E8905 || data.O_CODE == FLAG.E8906 {
                    self.showConfirmAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG)
                }
                
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoading?()
        }
    }
}
