//
//  PreView.swift
//  thepay
//
//  Created by xeozin on 2020/08/27.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import AVFoundation

class PreView: UIView {

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("AVCaptureVideoPreviewLayer")
        }

        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
