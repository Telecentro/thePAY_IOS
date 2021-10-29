//
//  Extensions.swift
//  thepay
//
//  Created by xeozin on 2020/07/01.
//  Copyright © 2020 DuoLabs. All rights reserved.
//
import UIKit

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start..<end]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex...end]
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex..<end]
    }
}

extension String  {
    var isNumber: Bool {
        if self == "" {
            return true
        }
        
        let new = self.phoneNumber
        
        return !new.isEmpty && new.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    var phoneNumber: String {
        let new = self.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: "").removeDash().trim()
        return new
    }
}

extension Int {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = App.shared.locale
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self))?.currency ?? "0"
    }
}


extension String {
    //Converts String to Int
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }

    //Converts String to Double
    public func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }

    /// EZSE: Converts String to Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }

    //Converts String to Bool
    public func toBool() -> Bool? {
        return (self as NSString).boolValue
    }
}

extension String {
    /**
     *  언어 변환
     */
    func localized(tableName: String = "Localizable") -> String {
        // 번역키 반환
        if App.shared.debugLanguageKeys {
            return self
        }
        guard let bundle = App.shared.bundle else { return "" }
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "**\(self)**", comment: "")
    }
    
    /**
     *  문자열 트림
     */
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeDash() -> String {
        return self.replacingOccurrences(of: "-", with: "")
    }
    
    
    
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = App.shared.locale
        formatter.maximumFractionDigits = 0
        
        let currencyString = formatter.string(from: formatter.number(from: self) ?? 0) ?? "0"
        //        currencyString = currencyString + "원"
        
        return currencyString
    }
    
    var won: String {
        return "￦ \(self)"
    }
    
    var point: String {
        return "P \(self)"
    }
    
    var pureIntString: String {
        return replacingOccurrences(of: "￦", with: "").replacingOccurrences(of: ",", with: "").trim()
    }
    
    var removeCurrency: String {
        return self.replacingOccurrences(of: ",", with: "")
    }
    
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }

        if !UIApplication.shared.canOpenURL(url) { return false }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    // 이메일 유효성 체크
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    var isArabianNumber: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[0-9]", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    var extractNumberString: String {
        if !self.isEmpty {
            let removeCharSet = NSCharacterSet.decimalDigits
            let set = removeCharSet.inverted
            return self.components(separatedBy: set).joined(separator: "")
        }
        return ""
    }
}

//extension Optional {
//    func isNilOrEmpty -> Bool {
//        if let s = self {
//            if let t = s as? String {
//                let isEmpty = t.isEmpty
//                return isEmpty
//            } else {
//                return true
//            }
//        } else {
//            return true
//        }
//    }
//}

extension Optional where Wrapped == String {

    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
    
    var bin: String {
        guard let s = self else { return "" }
        return s
    }

}

extension URL {

  init?(withCheck string: String?) {
    let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
    guard
        let urlString = string,
        let url = URL(string: urlString),
        NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx]).evaluate(with: urlString),
        UIApplication.shared.canOpenURL(url)
        else {
            return nil
    }

    self = url
  }
}

/**
 *  모달 구분
 */
extension UIViewController {
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

//class Utils {
//    // iOS 13. Key 윈도우 가져오기
//    class func getKeyWindow() -> UIViewController? {
//        let keyWindow = UIApplication.shared.connectedScenes
//        .filter({$0.activationState == .foregroundActive})
//        .map({$0 as? UIWindowScene})
//        .compactMap({$0})
//        .first?.windows
//        .filter({$0.isKeyWindow}).first
//
//        return keyWindow?.rootViewController ?? nil
//    }
//}
//
//extension UIApplication {
//// iOS 13 이전
////    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//    class func topViewController(base: UIViewController? = Utils.getKeyWindow()) -> UIViewController? {
//        if let nav = base as? UINavigationController {
//            return topViewController(base: nav.visibleViewController)
//        }
//        if let tab = base as? UITabBarController {
//            if let selected = tab.selectedViewController {
//                return topViewController(base: selected)
//            }
//        }
//        if let presented = base?.presentedViewController {
//            return topViewController(base: presented)
//        }
//        return base
//    }
//}


extension UITextField {
    /**
     *  문자열 초과 계산
     */
    func isOverLength(count: Int, range: NSRange, string: String) -> Bool {
        guard let text = self.text as NSString? else { return false }
        let newString = text.replacingCharacters(in: range, with: string)
        
        if newString.count > count {
            return false
        } else {
            return true
        }
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

extension UIView {
    /**
     *  뷰의 위치
     */
    func getPointFromView(target: UIView) -> CGRect {
        return self.convert(target.frame, from: target)
    }
    
    /**
     *  뷰의 라운드 부분별로
     */
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = self.query else { return nil}

        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {

            let key = pair.components(separatedBy: "=")[0]

            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""

            queryStrings[key] = value
        }
        return queryStrings
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIWindow.key?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}


extension UINavigationController{
    public func removeSubrangeMain(){
        let totalViewControllers = self.viewControllers.count
        let start = 1
        let end = totalViewControllers - 1
        let range = start..<end
        self.viewControllers.removeSubrange(range)
    }
    
    public func removeSubrangeSelf() {
        let totalViewControllers = self.viewControllers.count
        let start = totalViewControllers - 2
        let end = totalViewControllers - 1
        let range = start..<end
        self.viewControllers.removeSubrange(range)
    }
    
    public func backToIntro() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let intro = sb.instantiateViewController(withIdentifier: "Intro")
        self.setViewControllers([intro], animated: false)
    }
    
    public func goToAirplane() {
        if let vc = Link.dialer.viewController {
            self.setViewControllers([vc], animated: true)
        }
    }
    
    public func removePreviousController(total: Int){
        let totalViewControllers = self.viewControllers.count
        self.viewControllers.removeSubrange(totalViewControllers-total..<totalViewControllers - 1)
    }
}

/**
 *  내역 세그먼트 미얀마 문자 issue로 변환
 */
extension UISegmentedControl {
    func setFontSize(fontSize: CGFloat) {
        let font = LanguageUtils.fontWithSize(size: fontSize)
        self.setTitleTextAttributes([NSAttributedString.Key.font: font],
                                                    for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.font: font],
                                                    for: .highlighted)
        self.setTitleTextAttributes([NSAttributedString.Key.font: font],
                                                    for: .selected)
    }
}
