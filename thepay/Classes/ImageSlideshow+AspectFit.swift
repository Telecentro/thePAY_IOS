//
//  UIImage+AspectFit.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//  
//

import UIKit

#if swift(>=4.2)
public typealias UIViewContentMode = UIView.ContentMode
public typealias UIActivityIndicatorViewStyle = UIActivityIndicatorView.Style
typealias UIControlState = UIControl.State
typealias UIViewAnimationOptions = UIView.AnimationOptions
typealias UIControlEvents = UIControl.Event
typealias UIViewAutoresizing = UIView.AutoresizingMask
#else
#endif

extension UIImage {

    func tgr_aspectFitRectForSize(_ size: CGSize) -> CGRect {
        let targetAspect: CGFloat = size.width / size.height
        let sourceAspect: CGFloat = self.size.width / self.size.height
        var rect: CGRect = CGRect.zero

        if targetAspect > sourceAspect {
            rect.size.height = size.height
            rect.size.width = ceil(rect.size.height * sourceAspect)
            rect.origin.x = ceil((size.width - rect.size.width) * 0.5)
        } else {
            rect.size.width = size.width
            rect.size.height = ceil(rect.size.width / sourceAspect)
            rect.origin.y = ceil((size.height - rect.size.height) * 0.5)
        }

        return rect
    }
}

extension UIImageView {

    func aspectToFitFrame() -> CGRect {

        guard let image = image else {
            assertionFailure("No image found!")
            return CGRect.zero
        }

        let imageRatio: CGFloat = image.size.width / image.size.height
        let viewRatio: CGFloat = frame.size.width / frame.size.height

        if imageRatio < viewRatio {
            let scale: CGFloat = frame.size.height / image.size.height
            let width: CGFloat = scale * image.size.width
            let topLeftX: CGFloat = (frame.size.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: frame.size.height)
        } else {
            let scale: CGFloat = frame.size.width / image.size.width
            let height: CGFloat = scale * image.size.height
            let topLeftY: CGFloat = (frame.size.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: frame.size.width, height: height)
        }
    }
}
