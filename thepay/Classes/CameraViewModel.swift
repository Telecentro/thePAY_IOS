//
//  CameraViewModel.swift
//  thepay
//
//  Created by 홍서진 on 2021/09/17.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class CameraViewModel {
    
    
    let captureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let photoOutput = AVCapturePhotoOutput()
    let sessionQueue = DispatchQueue(label: "session queue")
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                                     .builtInWideAngleCamera,
                                                                                     .builtInTrueDepthCamera],
                                                                       mediaType: .video,
                                                                       position: .unspecified)
    var cameraType: CameraType = .creditCardFront
    
    var setupFrontCamera:(()->())?
    
    /* 2번 캡쳐 방지 */
    var isCapture: Bool = false
    
    var guideText: String {
        switch cameraType {
        case .alienCardFront, .idCardFront:
            return Localized.guide_preview_msg_align_card_front.txt
        case .alienCardBack:
            return Localized.guide_preview_msg_align_card_back.txt
        case .creditCardFront, .cardScan, .creditCardFront_Only:
            return Localized.guide_preview_msg_credit_card.txt
        case .creditCardBack:
            return Localized.guide_preview_msg_credit_card_back.txt
        case .a4:
            return Localized.guide_preview_msg_align_complaint_agree_confirmation.txt
        case .passport:
            return Localized.guide_preview_msg_align_passport.txt
        case .myFace, .webFace:
            return Localized.guide_preview_msg_self_camera.txt
        case .imageScan:
            return ""
        case .clear:
            return ""
        }
    }
    
    var guideImage: String? {
        // img_guide_credit
        switch cameraType {
        case .alienCardFront, .idCardFront:
            return "img_guide_arc_front"
        case .alienCardBack:
            return "img_guide_arc_back"
        case .creditCardFront, .cardScan, .creditCardFront_Only:
            return "img_guide_credit"
        case .creditCardBack:
            return "img_guide_credit_back"
        default:
            return nil
        }
    }
    
    var navText: String {
        switch cameraType {
        case .creditCardFront, .creditCardFront_Only, .cardScan:
            return Localized.safe_card_capture_credit_card.txt
        case .creditCardBack:
            return Localized.safe_card_capture_credit_card_back.txt
        case .alienCardFront, .idCardFront:
            return Localized.request_extend_stay_auth_foreign_card_front.txt
        case .alienCardBack:
            return Localized.request_extend_stay_auth_foreign_card_back.txt
        case .a4:
            return Localized.request_extend_e_complaint_agree_confirmation_title.txt
        case .passport:
            return Localized.request_extend_stay_auth_passport.txt
        case .myFace, .webFace:
            return Localized.safe_card_capture_self_camera.txt
        case .imageScan, .clear:
            return ""
        }
    }
    
    var isClearMode: Bool {
        return cameraType == .clear
    }
    
    var isFaceMode: Bool {
        return cameraType == .myFace || cameraType == .webFace
    }
    
    
    func startSession() {
        if !captureSession.isRunning {
            sessionQueue.async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            sessionQueue.async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    func addFaceDetactor(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func setupAndStart() {
        sessionQueue.async { [weak self] in
            self?.beginSession()
            self?.startSession()
            self?.setupSession()
        }
    }
    
    private func beginSession() {
        self.captureSession.sessionPreset = .photo
        self.captureSession.beginConfiguration()
    }
    
    private func setupSession() {
        do {
            var defaultVideoDevice: AVCaptureDevice?
            if cameraType.isFront {
                guard let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
                // xeozin/2020/09/22 reason: 전면 카메라일때 torch 버튼이 필요 없어서 숨김
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.setupFrontCamera?()
                }
                
                defaultVideoDevice = frontCameraDevice
                
            } else {
                guard let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
                defaultVideoDevice = backCameraDevice
            }
            
            guard let camera = defaultVideoDevice else {
                captureSession.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                captureSession.commitConfiguration()
                return
            }
            
        } catch {
            captureSession.commitConfiguration()
            return
        }
        
        // Add photo output
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            
        } else {
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.commitConfiguration()
    }
    
}
