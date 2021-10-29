//
//  Utils.swift
//  thepay
//
//  Created by xeozin on 2020/07/11.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import Contacts
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication

enum LoginType: String {
    case Easy = "easy"
    case Facebook = "facebook"
    case Google = "google"
    case Apple = "apple"
}

struct K {
    static var toast_duration = 1.0
    
    static var vNotifyDidFinishLogIn                                       = "NotifyDidFinishLogIn"
    static var vLogInEasy                                                  = "easy"
    static var vLogInFacebook                                              = "facebook"
    static var vLogInGoogle                                                = "google"
    static var vLogInApple                                                 = "apple"
    static var kSnsId                                                      = "id"
    static var kEmail                                                      = "email"
    static var kToken                                                      = "token" // 로그인/회원가입 시 받=  토큰
    static var kIsLogIn                                                    = "isLogIn"
    static var kAccount                                                    = "Account"
    static var kLastLogInType                                              = "lastlogintype"
    static var kSnsInfo                                                    = "snsinfo" // 현재 연동된 sns 정보 저장 =  값
    static var kNickname                                                   = "nickName"
    static var kParent                                                     = "parent"
    static var kResult                                                     = "result" // tru= /false
    static var kMemberType                                                 = "memberType" //easy :기본, faceboo= :페이스북 google:구글
    static var kAccessToken                                                = "AccessToken"
}

//func getSSID() -> String? {
//    guard let interfaces = CNCopySupportedInterfaces() else { return nil }
//    let interfacesArray = interfaces as! [String]
//    if interfacesArray.count <= 0 { return nil }
//    let interfaceName = interfacesArray[0] as String
//    guard let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName as CFString) else { return nil }
//    let interfaceData = unsafeInterfaceData as! Dictionary <String,AnyObject>
//    return interfaceData["SSID"] as? String
//}

class Utils: NSObject {
    
    // 객체 로드
    static func getObjectForKey(key: String) -> [String:Any]? {
        guard let data = UserDefaultsManager.shared.loadObjectUserDefaults(key: key) else { return nil }
        if let objects = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? NSMutableDictionary {
            return objects as? [String : Any]
        } else {
            return nil
        }
    }
    
    // 객체 저장
    static func setObjectWithKey(value: Any, key: String) {
        let archiveData: NSData = NSKeyedArchiver.archivedData(withRootObject: value) as NSData
        UserDefaults.standard.set(archiveData, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // 객체 삭제
    static func removeObjectForKey(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func getAccessToken() -> Any? {
        guard let snsDictionary = getSnsInfo() else { return nil }
        return snsDictionary[K.kAccessToken]
    }
    
    static func setSnsInfo(dataDictionary: NSMutableDictionary?) {
        guard let data = dataDictionary else { return }
        setObjectWithKey(value: data, key: K.kSnsInfo)
    }
    
    static func getSnsInfo() -> [String:Any]? {
        return getObjectForKey(key: K.kSnsInfo)
    }
    
    static func isSocialLogin() -> Bool {
        guard let _ = getSnsInfo() else { return false }
        return true
    }
    
    static func getSnSId() -> String? {
        guard let snsDictionary = getSnsInfo() else { return nil }
        return snsDictionary[K.kSnsId] as? String
    }
    
    static func getSnsEmail() -> String {
        guard let snsDictionary = getSnsInfo() else { return "" }
        return snsDictionary[K.kEmail] as? String ?? ""
    }
    
    static func userIdType() -> String {
        if let snsDictionary = getSnsInfo() {
            guard let memberType = snsDictionary[K.kMemberType] as? String else { return "UUID" }
            if memberType == K.vLogInFacebook {
                return "FCB"
            } else if memberType == K.vLogInGoogle {
                return "GML"
            } else if memberType == K.vLogInApple {
                return "APPLE"
            } else {
                return "UUID"
            }
        } else {
            return "UUID"
        }
    }
    
    static func getLoginTypeImage() -> UIImage? {
        let type = Utils.userIdType()
        switch type {
        case "GML":
            return UIImage(named: "ic_login_type_google_border")
        case "FCB":
            return UIImage(named: "ic_login_type_facebook_border")
        case "APPLE":
            return UIImage(named: "ic_login_type_apple_border")
        default:
            return UIImage(named: "ic_login_type_thepay_border")
        }
    }
    
    static func generateCurrentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = App.shared.locale
        formatter.dateFormat = "yyyyMMddHHmmss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    static var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String else {return nil}
        
        let versionAndBuild: String = "ver: \(version), build: \(build)"
        return versionAndBuild
    }
    
    static var ver: String {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
        
        return version
    }
    
    // Unwind Segue를 먼저 선언 해야한다.
    static func goMain(target: UIViewController) {
        target.performSegue(withIdentifier: "unwindMain", sender: nil)
    }
    
    /**
     *  핸드폰 번호 하이픈
     */
    static func format(phone: String, mask: String = "XXX-XXXX-XXXX") -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    static func updatePhoneNumber() -> String {
        let ctn = Utils.format(phone: UserDefaultsManager.shared.loadANI() ?? "0")
        if ctn == "0" {
            return ""
        } else {
            return ctn
        }
    }
    
    static func formatPosition(textField: UITextField, range: NSRange,  phone: String, mask: String = "XXX-XXXX-XXXX") {
        
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex

        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {

                result.append(ch)
            }
        }
        
        var cursorPosition = 0
        var add = 0

        if let selectedRange = textField.selectedTextRange {
            cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            let cur = result.index(result.startIndex, offsetBy: cursorPosition)
            print("🀄️ \(cursorPosition) \(result.count)")
            if cursorPosition < result.count {
                if result[exist: cur] == "-" {
                    add = add + 1
                }
            }
        }
        
        textField.text = result
        
        let pos = cursorPosition + 1 + add
        setTextFieldPosition(textField: textField, position: pos)
    }
    
    static func setTextFieldPosition(textField: UITextField, position: Int) {
        let arbitraryValue: Int = position
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: arbitraryValue) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    static func getTelecom(isLowercase:Bool = false) -> String {
        var resultString:String?
        
        let netinfo = CTTelephonyNetworkInfo()
        if let carrier = netinfo.subscriberCellularProvider {
            if isLowercase {
                resultString = carrier.carrierName?.lowercased()
            } else {
                resultString = carrier.carrierName
            }
        }
        return resultString ?? ""
    }
    
    static func updateScroll(scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let bounds = scrollView.bounds.size.height
        let bottom = scrollView.contentInset.bottom
        let bottomOffset = CGPoint(x: 0, y: height - (bounds + bottom))
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    static func getModel() -> String {
        switch Device.version() {
        
        case .iPhone2G:
            return "Phone 2G"
        case .iPhone3G:
            return "Phone 3G"
        case .iPhone3GS:
            return "Phone 3GS"
        case .iPhone4:
            return "Phone 4"
        case .iPhone4S:
            return "iPhone 4s"
        case .iPhone5:
            return "iPhone 5"
        case .iPhone5C:
            return "iPhone 5c"
        case .iPhone5S:
            return "iPhone 5s"
        case .iPhone6:
            return "iPhone 6"
        case .iPhone6Plus:
            return "iPhone 6 Plus"
        case .iPhone6S:
            return "iPhone 6s"
        case .iPhone6SPlus:
            return "iPhone 6s Plus"
        case .iPhoneSE:
            return "iPhone SE"
        case .iPhone7:
            return "iPhone 7"
        case .iPhone7Plus:
            return "iPhone 7 Plus"
        case .iPhone8:
            return "iPhone 8"
        case .iPhone8Plus:
            return "iPhone 8 Plus"
        case .iPhoneX:
            return "iPhone X"
        case .iPhoneXS:
            return "iPhone XS"
        case .iPhoneXS_Max:
            return "iPhone XS Max"
        case .iPhoneXR:
            return "iPhone XR"
        case .iPhone11:
            return "iPhone 11"
        case .iPhone11Pro:
            return "iPhone 11 Pro"
        case .iPhone11Pro_Max:
            return "iPhone 11 Pro Max"
        case .iPhoneSE2:
            return "iPhone SE 2"
        case .iPhone12:
            return "iPhone 12"
        case .iPhone12Pro:
            return "iPhone 12 Pro"
        case .iPhone12Pro_Max:
            return "iPhone 12 Pro Max"
        case .iPhone12Mini:
            return "iPhone 12 Mini"
        case .iPhone13Mini:
            return "iPhone 13 Mini"
        case .iPhone13:
            return "iPhone 13"
        case .iPhone13Pro:
            return "iPhone 13 Pro"
        case .iPhone13Pro_Max:
            return "iPhone 13 Pro Max"
        case .iPad1:
            return "iPad"
        case .iPad2:
            return "iPad 2"
        case .iPad3:
            return "iPad 3"
        case .iPad4:
            return "iPad 4"
        case .iPad5:
            return "iPad 5"
        case .iPad6:
            return "iPad 6"
        case .iPad7:
            return "iPad 7"
        case .iPad8:
            return "iPad 8"
        case .iPadAir:
            return "iPad Air"
        case .iPadAir2:
            return "iPad Air 2"
        case .iPadAir3:
            return "iPad Air 3"
        case .iPadAir4:
            return "iPad Air 4"
        case .iPadMini:
            return "iPad Mini"
        case .iPadMini2:
            return "iPad Mini 2"
        case .iPadMini3:
            return "iPad Mini 3"
        case .iPadMini4:
            return "iPad Mini 4"
        case .iPadMini5:
            return "iPad Mini 5"
        case .iPadPro9_7Inch:
            return "iPad Pro 9_7Inch"
        case .iPadPro10_5Inch:
            return "iPad Pro 10_5Inch"
        case .iPadPro11_0Inch:
            return "iPad Pro 11_0Inch"
        case .iPadPro11_0Inch2:
            return "iPad Pro 11_0Inch 2"
        case .iPadPro12_9Inch:
            return "iPad Pro 12_9Inch"
        case .iPadPro12_9Inch2:
            return "iPad Pro 12_9Inch 2"
        case .iPadPro12_9Inch3:
            return "iPad Pro 12_9Inch 3"
        case .iPadPro12_9Inch4:
            return "iPad Pro 12_9Inch 4"
        case .iPodTouch1Gen:
            return "iPod Touch 1G"
        case .iPodTouch2Gen:
            return "iPod Touch 2G"
        case .iPodTouch3Gen:
            return "iPod Touch 3G"
        case .iPodTouch4Gen:
            return "iPod Touch 4G"
        case .iPodTouch5Gen:
            return "iPod Touch 5G"
        case .iPodTouch6Gen:
            return "iPod Touch 6G"
        case .iPodTouch7Gen:
            return "iPod Touch 7G"
        case .simulator:
            return "iPhone Simulator"
        case .unknown:
            return "iPhone_\(Device.getVersionCode())"
        }
    }
    
    
    // 이미지 사이즈 조정
    static func getImageSize(image: UIImage) -> Data {
        var imageData: Data = Data()
        var newSize = CGSize(width: 0, height: 0)
        let maxSize: CGFloat = 2048
        var scale: CGFloat = 1
        if image.size.width > maxSize || image.size.height > maxSize {
            if image.size.width > image.size.height {
                scale = image.size.width / maxSize
            } else {
                scale = image.size.height / maxSize
            }
            
            newSize.width = image.size.width / scale
            newSize.height = image.size.height / scale
            UIGraphicsBeginImageContext(newSize)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let cpImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
            
            imageData = cpImage.jpegData(compressionQuality: 0.5) ?? imageData
            
        } else {
            imageData = image.jpegData(compressionQuality: 0.5) ?? imageData
        }
        return imageData
    }
    
    // 미얀마 font issue
    static func fontUpdate(text: String, size: CGFloat) -> NSAttributedString {
        let attrString = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font : LanguageUtils.fontWithSize(size: size)
        ])
        
        return attrString
    }
    
    // 카메라 권한 커스텀
    static func showCameraPermissionAlrat(vc: UIViewController) {
        let title: String = Localized.alert_title_confirm.txt
        let message: String = Localized.pre_refuse_camera_storage_permission.txt
        vc.showCheckAlert(title: title, message: message, confirm: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }, cancel: nil)
    }
    
    // 연락처 권한 커스텀
    static func showContactPermissionAlrat(vc: UIViewController) {
        let title: String = Localized.alert_title_confirm.txt
        let message: String = Localized.pre_refuse_contacts_permission.txt
        vc.showCheckAlert(title: title, message: message, confirm: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }, cancel: nil)
    }
    
    //    xeozin 2020/09/26 reason: 연락처 권한 로직 추가
    static func getContactPermissions(vc: UIViewController, segue: String, sender: Any? = nil) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            vc.performSegue(withIdentifier: segue, sender: sender)
        case .denied:
            Utils.showContactPermissionAlrat(vc: vc)
        case .restricted:
            print("권한 제한")
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        vc.performSegue(withIdentifier: segue, sender: sender)
                    }
                } else {
                    return
                }
            }
        default: break
        }
    }
    
    static func updateRemains(data:RemainsResponse) {
        UserDefaultsManager.shared.saveMyPinNumber(value: data.O_DATA?.pinNumber)
        UserDefaultsManager.shared.saveMyCash(value: String(data.O_DATA?.cash ?? 0))
        UserDefaultsManager.shared.saveMyPoint(value: String(data.O_DATA?.point ?? 0))
        UserDefaultsManager.shared.saveBankCode(value: data.O_DATA?.bankCode)
        UserDefaultsManager.shared.saveBankImgName(value: data.O_DATA?.imgNm)
        UserDefaultsManager.shared.saveMyBankAccount(value: data.O_DATA?.virAccountId)
    }
    
    
    static func callTel(_ number: String) {
        let urlString = "telprompt://\(number)"
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func nullToNil(value : Any?) -> Any? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    static func isValidRechargeItem(item: CallHistoryItem, krPhoneNumber: String) -> Bool {
        // NSNull 이 포함되어 있다면 false 반환
        if item.isNotValidNumber() {
            return false
        }
        
        // 옵셔널 값이 비어 있으면 false 반환
        if let callNumber = nullToNil(value: item.callNumber) as? String {
            if callNumber.contains(krPhoneNumber) && item.countryCode == "kr" {
                // 조건에 부합한 경우 (2020.11.04)
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    static func isValidAutoCompleteItem(item: AutoCompleteItem, text: String, type: String?, code: String) -> Bool {
        guard let t = type else { return false }
        // NSNull 이 포함되어 있다면 false 반환
        if item.isNotValidTextItem() {
            return false
        }
        
        // 옵셔널 값이 비어 있으면 false 반환
        if item.text.contains(text) && item.code == code && item.type == t {
            return true
        } else {
            return false
        }
    }
    
    static func saveCallNumber(dialNumber: String, countryCode: String?, countryNumber: String?, telecomNumber: String?) {
        let item = CallHistoryItem()
        
        item.name = dialNumber
        item.countryCode = countryCode
        item.countryNumber = countryNumber
        item.interNumber = telecomNumber
        item.callNumber = dialNumber
        item.date = Utils.generateCurrentTimeStamp()
        DBListManager.addCallHistory(item)
    }
    
    @available(iOS 11.0, *)
    static func authenticationWithBiometrics(confirm: (()->())?, errorHandler: ((Error?)->())?) {
        if UserDefaultsManager.shared.loadAuthBio() == false {
            confirm?()
            return
        }
        
        let authContext = LAContext()
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            DispatchQueue.main.async {
                switch authContext.biometryType {
                case .faceID, .touchID:
                    authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "결제를 위해서 지문인증을 합니다.") { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                confirm?()
                            }
                        } else {
                            if let err = error {
                                errorHandler?(err)
                            }
                        }
                    }
                    break
                case .none:
                    errorHandler?(nil)
                @unknown default:
                    fatalError()
                }
            }
        }
    }
}
