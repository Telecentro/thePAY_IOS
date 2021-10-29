//
//  TPSelector.swift
//  thepay
//
//  Created by xeozin on 2020/08/25.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TPSelector: UIView {
    var tf: UITextField?
    var iv: UIImageView?
    var callback: ((Any)->())?
    
    var isSelect: Bool = false
    var isShow: Bool = false
    
    internal var rowValue = 0
    internal var lastSelectedRow = 0
    
    internal var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .white
        
        return picker
    } ()
    
    func resetIndex(index: Int = 0) {
        self.rowValue = index
        self.lastSelectedRow = index
    }
    
    internal func selectBox(select: Bool) {
        if let subViews = tf?.superview?.subviews {
            for s in subViews {
                if s is UIImageView {
                    if let bg = s as? UIImageView, bg.tag == 101 {
                        if select {
                            bg.image = UIImage(named: "select_44")
                        } else {
                            bg.image = UIImage(named: "input_box_44_44")
                        }
                    }
                }
            }
        }
    }
    
    internal func getToolBar(done: UIBarButtonItem, cancel: UIBarButtonItem) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        // toolbar.backgroundColor = .clear
        // toolbar.barStyle = .default
        toolbar.setBackgroundImage(UIImage.init(color: UIColor(named: "Primary") ?? .black), forToolbarPosition: .any, barMetrics: .default)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([cancel, flexibleSpace, done], animated: false)
        
        done.tintColor = .white
        cancel.tintColor = .white
        return toolbar
    }
    
    public func start() {
        isSelect = false
        isShow = true
        print("😲 START")
    }
    
    public func end() {
        isShow = false
        print("🤗 END")
    }
    
    public func select() {
        print("😇 SELECT ITEM : \(rowValue) last row : \(self.lastSelectedRow)")
        isSelect = true
    }
    
    public func cancel() {
        print("😜 CANCEL ITEM : \(rowValue) last row : \(self.lastSelectedRow)")
        isSelect = false
        rowValue = self.lastSelectedRow
    }
}
