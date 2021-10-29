//
//  TPButton.swift
//  thepay
//
//  Created by xeozin on 2020/07/15.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class TPButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.font = LanguageUtils.fontWithSize(size: self.titleLabel?.font.pointSize ?? 17, oldFont: self.titleLabel?.font)
        self.isExclusiveTouch = true
    }
    
    // DEBOUNCE
    private var workItem: DispatchWorkItem?
    private var delay: Double = 0
    private var callback: (() -> Void)? = nil
    
    func debounce(delay: Double, callback: @escaping (() -> Void)) {
        self.delay = delay
        self.callback = callback
        self.workItem?.cancel()
        let workItem = DispatchWorkItem(block: { [weak self] in
          self?.callback?()
        })
        self.workItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + self.delay, execute: workItem)
    }
}

class TPEloadHistoryButton: UIButton {
    var indexPath: IndexPath?
}

class TPEloadContractButton: UIButton {
    var indexPath: IndexPath?
}

class HistoryButton: UIButton { }
class ContactButton: UIButton { }
