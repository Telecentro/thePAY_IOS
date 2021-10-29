//
//  TPTitleCheckBox.swift
//  thepay
//
//  Created by xeozin on 2020/07/14.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

import UIKit

class TPTitleCheckBox: UIView {
    @IBOutlet weak var checkbox: UIButton!
    
    var select: Bool = false {
        didSet {
            self.checkbox.isSelected = select
        }
    }
    
    @IBAction func press(_ sender: UIButton) {
        self.checkbox.isSelected = !self.checkbox.isSelected
    }
    
    func setSelect(value: Bool) {
        self.checkbox.isSelected = value
    }
    
    func isSelected() -> Bool {
        return self.checkbox.isSelected
    }
    
    func isItemSelect() -> Bool {
        return !self.checkbox.isSelected
    }
}
