//
//  UDP.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/24.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

enum UDP {
    case timemachine(value: Timemachine)
    case seq(value:String)
    case url(value:String)
    case adverTitle(value:String)
    
    static let timemachine      = "timemachine"
    static let seq              = "seq"
    static let url              = "url"
    static let step2            = "step2"
    static let step3            = "step3"
    static let adverTitle       = "adverTitle"
    
    static func params(params:[UDP]) -> [String:String] {
        var p:[String: String] = [:]
        for i in params {
            p.updateValue(i.value, forKey: i.key)
        }
        return p
    }
    
    var key: String {
        switch self {
        case .timemachine:
            return UDP.timemachine
        case .seq:
            return UDP.seq
        case .url:
            return UDP.url
        case .adverTitle:
            return UDP.adverTitle
        }
    }
    
    var value: String {
        switch self {
        case .timemachine(let value):
            return value.rawValue
        case .seq(let value):
            return value
        case .url(let value):
            return value
        case .adverTitle(let value):
            return value
        }
    }
}

enum Timemachine : String {
    case main = "main"
    case `self` = "self"
    
    static let pMain = UDP.params(params: [UDP.timemachine(value: .main)])
    static let pSelf = UDP.params(params: [UDP.timemachine(value: .`self`)])
}
