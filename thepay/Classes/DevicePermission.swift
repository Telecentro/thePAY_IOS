//
//  DevicePermission.swift
//  thepay
//
//  Created by seojin on 2021/03/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class CameraPermission {
    static let cameraSegue: String = "ShowCamera"
    
    func showCamera(authorized:(()->Void), denied:(()->Void), notDetermined: @escaping ()->Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            authorized()
        case .denied:
            denied()
        case .restricted:
            print("권한 제한")
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        notDetermined()
                    }
                } else {
                    return
                }
            })
            
        default: break
        }
    }
    
    func showCameraPermissionAlert(vc: UIViewController) {
        let title: String = Localized.alert_title_confirm.txt
        let message: String = Localized.pre_refuse_camera_storage_permission.txt
        vc.showCheckAlert(title: title, message: message, confirm: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }, cancel: nil)
    }
}

class CameraRollPermission {
    func showAlbum(authorized:@escaping(()->Void), denied:@escaping(()->Void)) {
        if #available(iOS 14, *) {
            let requiredAccessLevel: PHAccessLevel = .readWrite
            
            PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
                switch authorizationStatus {
                case .limited, .authorized:
                    authorized()
                    break
                default:
                    DispatchQueue.main.async {
                        denied()
                    }
                    break
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    authorized()
                    break
                case .denied:
                    DispatchQueue.main.async {
                        denied()
                    }
                default:
                    break
                }
            }
        }
    }
    
    func showAlbumPermissionAlert(vc: UIViewController) {
        let title: String = Localized.alert_title_confirm.txt
        let message: String = Localized.alert_msg_photo_setting.txt
        vc.showCheckAlert(title: title, message: message, confirm: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }, cancel: nil)
    }
}
