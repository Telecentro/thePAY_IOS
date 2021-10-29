//
//  CountryCallViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/18.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class CountryCallViewController: CallViewController {
    
    var isDirect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isDirect {
            updateDisplay()
            setupNavigationTitle(title: Localized.title_activity_call_contacts.txt)
        }
    }
    
    func updateDisplay() {
        if showList.count == 0 {
            loadContactsListTask()
        }
    }
}
