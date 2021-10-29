//
//  TPNavigationViewController.swift
//  thepay
//
//  Created by xeozin on 2020/06/26.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class TPNavigationViewController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let _ = self.topViewController as? MainViewController {
            return .lightContent
        } else {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                // Fallback on earlier versions
                return .default
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ok()
        
        let backButtonBackgroundImage = UIImage(named: "btn_left")
        let barAppearance =
            UINavigationBar.appearance(whenContainedInInstancesOf: [TPNavigationViewController.self])
        barAppearance.backIndicatorImage = backButtonBackgroundImage
        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        barAppearance.shadowImage = UIImage()
        
        let barButtonAppearance =
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [TPNavigationViewController.self])
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: .default)
        barButtonAppearance.tintColor = UIColor(named: "Primary")
    }
    
    func ok() {
        self.navigationBar.barTintColor = UIColor(named: "Primary")
        self.navigationBar.isTranslucent = false
        
        
    }
    
    func ok2() {
        self.navigationBar.barTintColor = UIColor(named: "F7F7F7")
        self.navigationBar.isTranslucent = false
    }
    
    
}
