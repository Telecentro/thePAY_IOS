//
//  PhoneUtils.swift
//  thepay
//
//  Created by seojin on 2020/11/26.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class PhoneUtils: NSObject {
    static func findPrefixNationInfo(src: String, nations: [NationItem]) -> ContactInfo? {
        
        if src.count <= 0 {
            return nil
        }
        
        var item = ContactInfo()
        
        if src.hasPrefix("82")
            || src.hasPrefix("+82")
            || src.hasPrefix("0") {
            item.countryCode = "kr"
            item.countryNumber = "82"
            var callNumber = ""
            if src.hasPrefix("82") {
                callNumber = "0\(src[2...])"
                print("🦴82 \(src) \(callNumber)")
            } else if src.hasPrefix("+82") {
                callNumber = "0\(src[3...])"
                print("🦴82+ \(src) \(callNumber)")
            } else {
                callNumber = src
                print("🦴 \(src)")
            }
            item.callNumber = callNumber
        } else {
            for nation in nations {
                guard var code = nation.countryCode else { return item }
                guard var number = nation.countryNumber else { return item }
                
                if src.hasPrefix(number) {
                    if code == "us" || code == "ca" {
                        code = StringUtils.checkUSAorCanada(src)
                    } else if code == "kz" || code == "ru" {
                        code = StringUtils.checkKzorRusia(src)
                        if code == "kz" {
                            number = "77"
                        } else {
                            number = "7"
                        }
                    }
                    
                    item.countryCode = code
                    item.countryNumber = number
                    let cnt:Int = number.count
                    item.callNumber = "\(src[cnt...])"
                }
            }
        }
        
        return item
    }
    
    
    static func isKTUSIM() -> Bool {
        let telecomName = Utils.getTelecom(isLowercase: true)
        return telecomName.hasPrefix("kt")
            || telecomName.hasPrefix("Kt")
            || telecomName.hasPrefix("KT")
            || (telecomName.range(of: "olleh", options: .caseInsensitive) != nil )
    }
    
    static func isKorean(cc: String, number: String) -> Bool {
        return cc == "kr" && number.hasPrefix("0")
    }
}

