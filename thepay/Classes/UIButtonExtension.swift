//
//  ButtonExtension.swift
//  thepay
//
//  Created by seojin on 2020/12/03.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundColor(sel: UIColor, nor: UIColor) {
        self.setBackgroundImage(UIImage(color: nor), for: .normal)
        self.setBackgroundImage(UIImage(color: sel), for: .highlighted)
        self.setBackgroundImage(UIImage(color: sel), for: .selected)
    }
    
    func setBackgroundColor(dis: UIColor, nor: UIColor) {
        self.layer.masksToBounds = true
        self.setBackgroundImage(UIImage(color: nor), for: .normal)
        self.setBackgroundImage(UIImage(color: dis), for: .disabled)
    }
    
    func setImage(sel: String, nor: String) {
        self.setImage(UIImage(named: nor), for: .normal)
        self.setImage(UIImage(named: sel), for: .highlighted)
        self.setImage(UIImage(named: sel), for: .selected)
    }
}
