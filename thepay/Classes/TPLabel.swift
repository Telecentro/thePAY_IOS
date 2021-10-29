//
//  TPLabel.swift
//  thepay
//
//  Created by xeozin on 2020/07/15.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class TPLabel: UILabel {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.lineBreakMode = .byWordWrapping
        self.font = LanguageUtils.fontWithSize(size: self.font.pointSize, oldFont: self.font)
    }
}
