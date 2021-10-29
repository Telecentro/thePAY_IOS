//
//  AbstractModel.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

protocol ResponseAPI: Codable {
    var O_CODE: String { get set } 
    var O_MSG: String { get set }
}

extension String {
    func encryptCard() -> String {
        if self == "" {
            return ""
        }
        let stamp = Utils.generateCurrentTimeStamp()
        let str = "\(self)\(stamp)"
        guard let d:Data = str.data(using: .utf8) else { return "" }
        return AES256.encryptionAES256NotEncDate(data: d).base64EncodedString()
    }
    
    func encryptCardNoStamp() -> String {
        guard let d:Data = self.data(using: .utf8) else { return "" }
        return AES256.encryptionAES256NotEncDate(data: d).base64EncodedString()
    }
}

extension RequestAPI {
    func getNewParam(_ addParams: [String:String]) -> [String:String] {
        var newParam:[String: String] = [:]
        if let defaultParam: [String: Any] = self.getParam() {
            for (k, v) in defaultParam {
                newParam.updateValue(v as? String ?? "", forKey: k)
            }
        }
        
        for (k, v) in addParams {
            newParam.updateValue(v, forKey: k)
        }
        
        return newParam
    }
}

class RequestAPI {
    
    func getParam() -> [String: Any]? {
        return nil
    }
    
    func getAPI() -> String? {
        return nil
    }
    
    var pinNumber: String {
        return UserDefaultsManager.shared.loadMyPinNumber() ?? ""
    }
    
    var uuid: String {
        return UserDefaultsManager.shared.loadUUID() ?? ""
    }
    
    var ani: String {
        return UserDefaultsManager.shared.loadANI() ?? ""
    }
    
    // 2020.1.5 추가
    var ani2: String {
        return UserDefaultsManager.shared.loadANI2() ?? ""
    }
    
    // 2020.1.5 추가
    var sms_sessionId: String {
        return UserDefaultsManager.shared.loadSMSSessionID() ?? ""
    }
    
    var dynamicLink: String {
        return UserDefaultsManager.shared.loadDynamicLink()
    }
    
    var localUUID: String {
        return UserDefaultsManager.shared.loadUUID(social: false) ?? ""
    }
    
    var sessionId: String {
        return UserDefaultsManager.shared.loadSessionID() ?? ""
    }
    
    var enc_date: String {
        return UserDefaultsManager.shared.loadEncDate() ?? ""
    }
    
    var aes256Value: String {
        let str = "\(pinNumber)\(enc_date)"
        
        guard let d:Data = str.data(using: .utf8) else { return "" }
        let data = AES256.encryptionAES256Data(data: d)
        
        return data.base64EncodedString()
    }
    
    // 장치 모델명
    var model : String {
        return Utils.getModel()
    }
    
    // 랭귀지 코드 (USA)
    var langCode: String {
        return UserDefaultsManager.shared.loadNationCode()
    }
    
    // 이메일 주소
    var email: String {
        return Utils.getSnsEmail()
    }
    
    // 텔레콤
    var telecom: String {
        return Utils.getTelecom()
    }
    
    // 아이디 타입 (구글, 페이스북, 애플, 이지로그인)
    var userIdType: String {
        return Utils.userIdType()
    }
    
    // 앱 버전
    var appver: String {
        return Utils.ver
    }
    
    var appver_desc: String {
        return "thePAY@\(Utils.ver)"
    }
    
    var noticeSeq: String {
        return UserDefaultsManager.shared.loadNoticeSeq() ?? ""
    }
    
    var smsFlag: String {
        return UserDefaultsManager.shared.loadSMSFlag() ?? "N"
    }
    
    var deviceToken: String {
        guard let d:Data = UserDefaultsManager.shared.loadAPNSToken()?.data(using: .utf8) else { return "" }
        return AES256.encryptionAES256NotEncDate(data: d).base64EncodedString()
    }
    
    var os: String {
        return UIDevice.current.systemVersion
    }
    
    var os_desc: String {
        return "ios@\(UIDevice.current.systemVersion)"
    }
    
    var os_lang: String {
        /* OS LANGUAGE */
        let locale = Locale.current as NSLocale
        return locale.iso639_2LanguageCode()?.uppercased() ?? ""
    }
    
    var dataVer: String {
        return UserDefaultsManager.shared.loadDataVer() ?? "0"
    }
    
    var freeMemory: String {
        return DiskStatus.avialibeMemory
    }
    
    var freeDisk: String {
        return String(DiskStatus().getFreeDiskspace() ?? 0)
    }
    
    var isRooting: String {
        if UIDevice.current.isJailBroken {
            return "true"
        } else {
            return "false"
        }
    }
    
    var ipAddress: String {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "" }
        guard let firstAddr = ifaddr else { return "" }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address ?? ""
    }
}
