//
//  ContactCallViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/18.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class ContactCallViewController: CallViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateDisplay() {
        if showList.count == 0 {
            loadContactsListTask()
        }
    }
}

