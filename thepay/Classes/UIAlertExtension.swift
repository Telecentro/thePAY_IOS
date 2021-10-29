//
//  UIAlertExtension.swift
//  thepay
//
//  Created by xeozin on 2020/07/28.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

//enum PKHUDType {
//    case basic
//    case lang
//}

//extension PKHUD {
//    func showHUD(type: PKHUDType = .basic) {
//        switch type {
//        case .basic:
//            PKHUD.sharedHUD.contentView = PKHUDProgressView()
//        case .lang:
//            PKHUD.sharedHUD.contentView = PKHUDProgressView(title: App.shared.codeLang.nationAlphaName, subtitle: App.shared.codeLang.nationName)
//        }
//
//        PKHUD.sharedHUD.show()
//    }
//}

extension UIViewController {
    
    func showConfirmAlertSystem(title: String?, message: String, confirm: (()->())? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: Localized.btn_confirm.txt, style: .default) { action in
                confirm?()
            }
            
            alert.setValue(Utils.fontUpdate(text: title ?? "", size: 17),
                           forKey: "attributedTitle")
            alert.setValue(Utils.fontUpdate(text: message, size: 14),
                           forKey: "attributedMessage")
            alert.addAction(confirmAction)
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            self.present(alert, animated: true)
        }
    }
    
    func showConfirmAlert(popupType: CustomPopupViewController.PopupType = .classic,
                          title: String?, message: String, confirm: (()->())? = nil) {
        DispatchQueue.main.async {
        
        if popupType == .classic {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "TextPopViewController") as? TextPopViewController else { return }
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = Utils.fontUpdate(text: message , size: 14)
                vc.confirm = confirm
                vc.isSingleConfirm = true
                self.present(vc, animated: true)
            }
        } else {
            let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "CustomPopupViewController") as? CustomPopupViewController else { return }
                vc.type = popupType
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = Utils.fontUpdate(text: message , size: 14)
                vc.confirm = confirm
                vc.isSingleConfirm = true
                self.present(vc, animated: true)
            }
        }
    }
    
    func showConfirmHTMLAlert(popupType: CustomPopupViewController.PopupType = .classic,
                              title: String?, htmlString: String, confirm: (()->())? = nil) {
        if popupType == .classic {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "TextPopViewController") as? TextPopViewController else { return }
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = htmlString.convertHtml(fontSize: 14)
                vc.confirm = confirm
                vc.isSingleConfirm = true
                self.present(vc, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "CustomPopupViewController") as? CustomPopupViewController else { return }
                vc.type = popupType
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = htmlString.convertHtml(fontSize: 14)
                vc.confirm = confirm
                vc.isSingleConfirm = true
                self.present(vc, animated: true)
            }
        }
    }
    
    func showCheckAlert(popupType: CustomPopupViewController.PopupType = .classic,
                        title: String?, message: String, confirm: (()->())?, cancel: (()->())?) {
        if popupType == .classic {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "TextPopViewController") as? TextPopViewController else { return }
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = Utils.fontUpdate(text: message , size: 14)
                vc.confirm = confirm
                vc.cancel = cancel
                self.present(vc, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "CustomPopupViewController") as? CustomPopupViewController else { return }
                vc.type = popupType
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = Utils.fontUpdate(text: message , size: 14)
                vc.confirm = confirm
                vc.cancel = cancel
                self.present(vc, animated: true)
            }
        }
    }
    
    func showCheckHTMLAlert(popupType: CustomPopupViewController.PopupType = .classic,
                            title: String?, htmlString: String, confirm: (()->())?, cancel: (()->())?) {
        if popupType == .classic {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "TextPopViewController") as? TextPopViewController else { return }
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = htmlString.convertHtml(fontSize: 14)
                vc.confirm = confirm
                vc.cancel = cancel
                self.present(vc, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "PopUp", bundle: nil)
                guard let vc = sb.instantiateViewController(withIdentifier: "CustomPopupViewController") as? CustomPopupViewController else { return }
                vc.type = popupType
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.titleText = Utils.fontUpdate(text: title ?? "", size: 17)
                vc.descText = htmlString.convertHtml(fontSize: 14)
                vc.confirm = confirm
                vc.cancel = cancel
                self.present(vc, animated: true)
            }
        }
    }
    
    func showWithdrawalAlert(confirm: ((String)->())?, cancel: (()->())?) {
        DispatchQueue.main.async {
            let sb = UIStoryboard(name: "PopUp", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "WithdrawalPopupViewController") as? WithdrawalPopupViewController else { return }
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            vc.confirm = confirm
            vc.cancel = cancel
            self.present(vc, animated: true)
        }
    }
}


extension NSRange {
  public init(_ x: Range<Int>) {
    self.init()
    location = x.lowerBound
      length = x.count
  }
}

extension String {

    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }

    func ranges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        while let range = range(of: searchString, options: mask, range: (ranges.last?.upperBound ?? startIndex)..<endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }

    func nsRanges(of searchString: String, options mask: NSString.CompareOptions = [], locale: Locale? = nil) -> [NSRange] {
        let ranges = self.ranges(of: searchString, options: mask, locale: locale)
        return ranges.map { nsRange(from: $0) }
    }
}

extension String{
    func convertHtml(fontSize: CGFloat) -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do{
            let attributed = try NSMutableAttributedString(data: data, documentType: .html)
            let font = LanguageUtils.fontWithSize(size: fontSize)
            let attributes = [NSAttributedString.Key.font : font]
            let length = (attributed.string as NSString).length
            attributed.addAttributes(attributes, range: NSRange(location: 0, length: length))
            
            return attributed
        }catch{
            return NSAttributedString()
        }
    }
    
    func convertToAttributedString(fontSize: String = "16") -> NSAttributedString? {
        let modifiedFontString = "<span style=\"font-size: \(fontSize)\">" + self + "</span>"
        return modifiedFontString.convertHtml(fontSize: 18)
    }
}

extension NSMutableAttributedString {
    convenience init(data: Data, documentType: DocumentType, encoding: String.Encoding = .utf8) throws {
        
        try self.init(data: data,
                      options: [.documentType: documentType,
                                .characterEncoding: encoding.rawValue],
                      documentAttributes: nil)
    }
    convenience init(html data: Data) throws {
        try self.init(data: data, documentType: .html)
    }
    convenience init(txt data: Data) throws {
        try self.init(data: data, documentType: .plain)
    }
    convenience init(rtf data: Data) throws {
        try self.init(data: data, documentType: .rtf)
    }
    convenience init(rtfd data: Data) throws {
        try self.init(data: data, documentType: .rtfd)
    }
}
