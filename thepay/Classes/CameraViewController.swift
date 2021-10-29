//
//  CameraViewController.swift
//  thepay
//
//  Created by xeozin on 2020/08/27.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Vision
import Photos
import TOCropViewController

protocol CaptureDelegate {
    func sendImage(image: UIImage, type: CameraType?)
    func sendImage(image: UIImage, type: CameraType?, cardInfo: SafeCardBeforeData.SafeCardInfo)
}

extension CaptureDelegate {
    func sendImage(image: UIImage, type: CameraType?) {}
    func sendImage(image: UIImage, type: CameraType?, cardInfo: SafeCardBeforeData.SafeCardInfo) {}
}

class CameraViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var preView: PreView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var btnCapture: TPButton!
    @IBOutlet weak var bottomGuide: UIView!
    @IBOutlet weak var lblGuide375x341: TPLabel!
    @IBOutlet weak var lblGuide375x361: TPLabel!
    @IBOutlet weak var lblGuide375x553: TPLabel!
    @IBOutlet weak var lblGuideSelf: TPLabel!
    @IBOutlet weak var preview375x341: UIView!
    @IBOutlet weak var preview375x361: UIView!
    @IBOutlet weak var preview375x553: UIView!
    @IBOutlet weak var previewSelf: UIView!
    @IBOutlet weak var btnTorch: TPButton!
    @IBOutlet weak var constraintsAspect: NSLayoutConstraint!
    
    @IBOutlet weak var ivCardimage: UIImageView!
    @IBOutlet weak var lblCardDesc: TPLabel!
    @IBOutlet weak var lblDetect: TPLabel!
    
    @IBOutlet weak var lblNav: TPLabel!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var viewPassport: UIView!
    @IBOutlet weak var viewA4: UIView!
    @IBOutlet weak var viewSelf: UIView!
    
    var previewFrame: CGRect?
    
    var delegate: CaptureDelegate?
    var vm = CameraViewModel()
}

extension CameraViewController {
    public func setupDelegate(delegate:CaptureDelegate, type: CameraType) {
        self.delegate = delegate
        vm.cameraType = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.stopSession()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CardDetailViewController {
            vc.delegate = delegate
            vc.cameraType = vm.cameraType
            vc.cardImage = sender as? UIImage
        }
    }
}

// MARK: - 확장
extension CameraViewController {
    
    private func setupGuide(lbl: TPLabel) {
        lbl.textAlignment = .center
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOffset = .zero
        lbl.layer.shadowRadius = 2.0
        lbl.layer.shadowOpacity = 1
        lbl.layer.masksToBounds = false
        lbl.layer.shouldRasterize = true
    }
    
    private func setupMask() {
        btnCapture.layer.cornerRadius = btnCapture.bounds.height/2
        btnCapture.layer.masksToBounds = true
        blurView.layer.cornerRadius = blurView.bounds.height/2
        blurView.layer.masksToBounds = true
    }
    
    func initialize() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupGuide(lbl: lblGuide375x341)
        setupGuide(lbl: lblGuide375x361)
        setupGuide(lbl: lblGuide375x553)
        setupGuide(lbl: lblGuideSelf)
        setupMask()
        
        preView.session = vm.captureSession
        
        vm.setupAndStart()
        vm.setupFrontCamera = {
            print("front camera... [2021.10.19 미처리]")
        }
        
        if vm.isFaceMode {
            vm.addFaceDetactor(delegate: self)
        }
        
        if vm.isClearMode {
            lblGuide375x341.text = ""
            lblGuide375x361.text = ""
            lblGuide375x553.text = ""
            lblGuideSelf.text = ""
        }
        
        setupFrame()
    }
    
    private func setupFrame() {
        viewCard.isHidden = true
        viewPassport.isHidden = true
        viewA4.isHidden = true
        viewSelf.isHidden = true
        
        switch vm.cameraType {
        case .myFace, .webFace:
            viewSelf.isHidden = false
            previewFrame = previewSelf.frame
            lblNav.text = "셀피 등록"
        case .passport:
            viewPassport.isHidden = false
            previewFrame = preview375x361.frame
        case .alienCardBack, .alienCardFront, .idCardFront:
            lblCardDesc.text = ""
            viewCard.isHidden = false
            previewFrame = preview375x341.frame
        case .creditCardFront, .cardScan, .creditCardFront_Only, .creditCardBack:
            lblCardDesc.text = Localized.text_guide_warning_use_other_card.txt
            viewCard.isHidden = false
            previewFrame = preview375x341.frame
        case .a4:
            viewA4.isHidden = false
            previewFrame = preview375x553.frame
        case .clear:
            break
        default:
            break
        }
        
        updateCardImage()
    }
    
    private func updateCardImage() {
        if let imageName = vm.guideImage {
            ivCardimage.image = UIImage(named: imageName)
        }
    }
    
    func localize() {
        // 본인명의 카드만 사용가능합니다.
        lblGuide375x341.text = vm.guideText
        lblGuide375x361.text = vm.guideText
        lblGuide375x553.text = vm.guideText
        lblGuideSelf.text = vm.guideText
        lblNav.text = vm.navText
    }
    
    override func leftMenu() {
        self.dismiss(animated: false, completion: nil)
    }
    
    // 하단 검은 영역 제거
    private func hideGuide(hide: Bool) {
        self.bottomGuide.isHidden = hide
    }
    
    //    xeozin 2020/09/26 reason: 디바이스에 사진 저장되는 로직 삭제
    private func savePhotoLibrary(image: UIImage) {
        switch vm.cameraType {
        case .myFace:
            /* 전면 화면 */
            self.dismiss(animated: true, completion: { [weak self] in
                self?.delegate?.sendImage(image: image, type: self?.vm.cameraType)
                self?.vm.stopSession()
            })
            
        case .webFace:
            delegate?.sendImage(image: image, type: vm.cameraType)
            navigationController?.popViewController(animated: true)
            
        case .creditCardFront, .cardScan:
            /* 카드 화면 */
            let cropImage = self.getRectImage(image: image, rect: previewFrame ?? CGRect.zero)
            performSegue(withIdentifier: "ShowCard", sender: cropImage)
        case .clear:
            delegate?.sendImage(image: image, type: vm.cameraType)
            dismiss(animated: true)
            
        default:
            /* 일반 스캔화면 */
            let cropImage = self.getRectImage(image: image, rect: previewFrame ?? CGRect.zero)
            let cropController = CropViewController(croppingStyle: .default, image: cropImage)
            cropController.aspectRatioPickerButtonHidden = true
            cropController.delegate = self
            self.navigationController?.pushViewController(cropController, animated: true)
        }
    }
    
    private func getRectImage(image: UIImage, rect: CGRect) -> UIImage {
        let outputRect = self.preView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        let cgImage = image.cgImage
        let width:CGFloat = CGFloat(cgImage?.width ?? 0)
        let height:CGFloat = CGFloat(cgImage?.height ?? 0)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        
        if let cropImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage.init(cgImage: cropImage).rotate(radians: .pi / 2)
        } else {
            return image.rotate(radians: .pi / 2)
        }
    }
    
}

// MARK: - CropViewControllerDelegate
extension CameraViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        switch vm.cameraType {
        case .imageScan, .cardScan, .webFace:
            guard let count = self.navigationController?.viewControllers.count else { return }
            if let prev = self.navigationController?.viewControllers[count - 3] {
                self.navigationController?.popToViewController(prev, animated: true)
            }
            
        default:
            vm.stopSession()
            dismiss(animated: true, completion: nil)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        switch vm.cameraType {
        case .imageScan, .cardScan, .webFace:
            guard let count = self.navigationController?.viewControllers.count else { return }
            if let prev = self.navigationController?.viewControllers[count - 3] {
                delegate?.sendImage(image: image, type: vm.cameraType)
                self.navigationController?.popToViewController(prev, animated: true)
            }
            
        default:
            dismiss(animated: true) { [weak self] in
                self?.delegate?.sendImage(image: image, type: self?.vm.cameraType)
                self?.vm.stopSession()
            }
        }
        
    }
}


// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        self.savePhotoLibrary(image: image)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            if let err = err {
                print("Failed to detect faces:", err)
                return
            }
            
            DispatchQueue.main.async {
                if let results = req.results {

                    if results.count == 1 {
                        self.lblDetect.isHidden = true
                    } else {
                        self.lblDetect.text = Localized.error_cant_detect_face.txt
                        self.lblDetect.isHidden = false
                    }
                }
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("Failed to perform request:", reqErr)
            }
        }
    }
}

// MARK: - Torch
extension CameraViewController {
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
            
        } catch {
            print("Torch could not be used")
        }
    }
}

extension CameraViewController {
    
    @IBAction func close(_ sender: UIButton) {
        if self.isModal {
            dismiss(animated: false) { [weak self] in
                self?.vm.stopSession()
            }
        } else {
            vm.stopSession()
            navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func pressTorch(_ sender: UIButton) {
        sender.isSelected.toggle()
        switch sender.isSelected {
        case true:
            toggleTorch(on: true)
        case false:
            toggleTorch(on: false)
        }
    }
    
    @IBAction func pressCapture(_ sender: Any) {
        if !lblDetect.isHidden { return }
        if vm.isCapture == true { return }
        let videoPreviewLayerOrientation = self.preView.videoPreviewLayer.connection?.videoOrientation
        vm.sessionQueue.async {
            let connection = self.vm.photoOutput.connection(with: .video)
            connection?.videoOrientation = videoPreviewLayerOrientation!
            let setting = AVCapturePhotoSettings()
            self.vm.photoOutput.capturePhoto(with: setting, delegate: self)
        }
        
         vm.isCapture = true
    }
}
