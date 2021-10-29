//
//  File.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

class EasyPhotoUtils {
    static let list = [
        FILE_NAME.FILE_CREDIT_CARD_FRONT,
        FILE_NAME.FILE_CREDIT_CARD_BACK,
        FILE_NAME.FILE_ALINE_CARD_FRONT,
        FILE_NAME.FILE_ALINE_CARD_BACK,
        FILE_NAME.FILE_PASSPORT,
        FILE_NAME.FILE_SELF_CAMERA,
        FILE_NAME.FILE_SIGNATURE
    ]
    
    static func isEasyPhotoKey(key: String) -> Bool {
        for i in list {
            if i == key {
                return true
            }
        }
        
        return false
    }
}
