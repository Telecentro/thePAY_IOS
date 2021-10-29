//
//  EasyContainerViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/25.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasyStepViewController: TPBaseViewController {
    var showLoading:(()->Void)?
    var hideLoading:(()->Void)?
    
    var press:(()->Void)?
    
    func pressNext() { }
    
    var emptyString: String {
        return ""
    }
    
    func enc(str: String) -> String {
        guard let d:Data = str.data(using: .utf8) else { return "" }
        return AES256.encryptionAES256NotEncDate(data: d).base64EncodedString()
    }
}
