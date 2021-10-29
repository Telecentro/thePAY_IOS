//
//  Segue.swift
//  thepay
//
//  Created by xeozin on 2020/07/02.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import SafariServices

enum WebViewType {
    case html
    case url
    case prod
}

enum SubMoveLink: Int {
    case history = 0
    case kt_rate = 1
    case sk_rate = 2
    case cash_history = 4
}

enum ThePayNotification {
    case RequestRemains
    case Push
    case DeepLink
    case Contact
    case Airplane
    
    var name: Notification.Name {
        switch self {
        case .RequestRemains: return Notification.Name("RequestRemains")
        case .Push: return Notification.Name("kPushRecv")
        case .DeepLink: return Notification.Name("kDeepLinkRecv")
        case .Contact: return Notification.Name("responseContact")
        case .Airplane: return Notification.Name("Airplane")
        }
    }
}

/*
 [ Parse Move ]
 SegueUtils.parseMoveLink(target: self, link: "thepay://page.charge.international_call?product_type=\(self.type.key)")
 
 [ Open Direct Menu ]
 SegueUtils.openMenu(target: self, link: .international_call, params: ["product_type" : self.type.key])
 */
class SegueUtils {
    
    static func hasEvent(target: TPBaseViewController?, link: String) -> Bool {
        let urlArray = link.components(separatedBy: "?")
        guard let type = Link(rawValue: urlArray[0]) else { return false }
        
        
        if type == .event {
            SegueUtils.openMenu(target: target, link: type, params: ["content":urlArray[1]])
            return true
        }
        
        return false
    }
    
    /**
     *  링크 파싱
     */
    static func parseMoveLink(target: TPBaseViewController?, link: String, title: String? = nil, addParams: [String: String]? = nil) {
        
        // 이벤트 일 경우 [ 강제 리턴 ]
        if hasEvent(target: target, link: link) {
           return
        }
        
        // encoding 안된 Link return 됨
        guard let moveLink = URL(string: link) else { return }
        guard let scheme = moveLink.scheme else { return }
        
        if scheme.hasPrefix("http") {
            SegueUtils.openSafariLink(target: target, link: link)
        } else if scheme == "thepay" {
            let urlArray = link.components(separatedBy: "?")
            guard let type = Link(rawValue: urlArray[0]) else {
                print("🌱 [Undefined schema] : \(urlArray[0])")
                return
            }
            
            if var param = moveLink.queryDictionary {
                // 테이블 뷰에서 > 웹 뷰일 경우에 타이틀 설정
                if let t = title, type == .webview {
                    param.updateValue(t, forKey: "adverTitle")
                }
                
                if let p = addParams {
                    for (key, value) in p {
                        param.updateValue(value, forKey: key)
                    }
                }
                
                SegueUtils.openMenu(target: target, link: type, params: param)
            } else {
                if let p = addParams {
                    SegueUtils.openMenu(target: target, link: type, params: p)
                } else {
                    SegueUtils.openMenu(target: target, link: type)
                }
            }
        } else {
            print("🤬 invalid url \(link)")
        }
    }
    
    static func parseSchemeWebURL(moveLink: String?) -> String? {
        guard let link = moveLink else { return nil }
        guard let moveLink = URL(string: link) else { return nil }
        guard let scheme = moveLink.scheme else { return nil }

        if scheme == "thepay" {
            let urlArray = link.components(separatedBy: "?")
            guard let type = Link(rawValue: urlArray[0]) else { return nil }

            if type == .webview {
                if let param = moveLink.queryDictionary {
                    return param["url"]
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    /**
     *  Safari Open
     */
    static func openLink(link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    static func openSafariLink(target:TPBaseViewController?, link: String) {
        guard let url = URL(string: link) else { return }
        let safariViewController = SFSafariViewController(url: url)
        target?.present(safariViewController, animated: true, completion: nil)
    }
    
    // URL 오픈 (App Store, Tel)
    static func openURL(urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    /**
     *  세그 이동
     */
    static func openMenu(target:TPBaseViewController?, link: Link, params: [String: Any]? = nil) {
        switch link.action {
        case .segue:
            if let segueString = link.segue {
                if link.hasDirectViewController {
                    if let vc = link.viewController {
                        vc.params = params
                        vc.title = link.title
                        target?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    let info = SegueInfo(title: link.title, params: params)
                    target?.performSegue(withIdentifier: segueString, sender: info)
                }
            }
        case .share:
            target?.shared()
        default:
            print(link.action ?? "")
        }
    }

    static func openHistory(target: TPBaseViewController?, option: SubMoveLink = .history) {
        if let moveLink = App.shared.pre?.O_DATA?.subMoveLinkList?[exist: option.rawValue]?.moveLink {
            if let url = SegueUtils.parseSchemeWebURL(moveLink: moveLink) {
                let title = Link.history.title ?? ""
                SegueUtils.openMenu(target: target, link: .webview, params: ["Timemachine":Timemachine.main, "url":url, "adverTitle":title])
            } else {
                SegueUtils.openMenu(target: target, link: .history, params: ["Timemachine":Timemachine.main])
            }
        }
    }
    
    /**
     *  직접 이동
     */
    static func openDirectMenu(target:TPBaseViewController?, link: Link, params: [String: Any]? = nil) {
        switch link.action {
        case .segue:
            if let vc = link.viewController {
                vc.params = params
                vc.title = link.title
                target?.navigationController?.pushViewController(vc, animated: true)
            }
        case .share:
            target?.shared()
        default:
            print(link.action ?? "")
        }
    }
    
    static func push(target: TPBaseViewController?, link: Link, params: [String: Any]? = nil) {
        if let vc = link.viewController {
            vc.params = params
            vc.title = link.title
            target?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

struct Storyboard {
    static let Main              = "Main"
    static let Menu              = "Menu"
    static let Contact           = "Contact"
    static let Payment           = "Payment"
    static let SafeCard          = "SafeCard"
    static let EasyPay           = "EasyPay"
    static let Sign              = "Sign"
    static let Charge            = "Charge"
}

/**
 *  메인 이동 세그
 */
struct Segue {
    static let Lang              = "Lang"
    static let History           = "History"
    static let PushHistory       = "PushHistory"
    static let MyInfo            = "MyInfo"
    static let Notice            = "Notice"
    static let Integrate         = "Integrate"
    static let InternationalCall = "InternationalCall"
    static let Cash              = "Cash"
    static let FAQ               = "FAQ"
    static let Contactus         = "Contactus"
    static let SafeCard          = "SafeCard"
    static let EasyPayInfo       = "EasyPayInfo"
    static let EasyPay           = "EasyPay"
    static let EasyPwdAuth       = "EasyPwdAuth"
    static let EasyList          = "EasyList"
    static let Extendstay        = "Extendstay"
    static let Dialer            = "Dialer"
    static let ARS               = "ARS"
    static let SKTData           = "SKTData"
    static let Eload             = "Eload"
    static let WebView           = "WebView"
    static let EasyPayTerms      = "EasyTerms"
    static let GiftCash          = "GiftCash"
}

/**
 *  스페셜 세그
 */
extension Segue {
    static let ModifyInfo        = "ModifyInfo"
    static let Main              = "Main"
    static let SignIn            = "SignIn"
    static let Terms             = "Terms"
    static let Register          = "Register"
    static let Menu              = "Menu"
    static let Fake              = "Fake"
    static let Recommend         = "Recommend"
    static let PGWeb             = "PGWeb"
    static let Pay               = "Pay"
    static let Event             = "WebView"
}

struct SegueInfo {
    var title: String?
    var params: [String: Any]?
}

enum ActionType {
    case segue
    case share
}

enum Link: String {
    case history            = "thepay://page.history"
    case pushhistory        = "thepay://page.pushhistory"
    case myinfo             = "thepay://page.myinfo"
    case faq                = "thepay://page.faq"
    case contactus          = "thepay://page.contactus"
    case lang               = "thepay://page.lang"
    case recommend          = "thepay://recommend"
    
    case request_safecard   = "thepay://page.request_safecard"
    case request_easypay    = "thepay://page.request_easypay"
    case request_extendstay = "thepay://page.request_extendstay"
    case notice             = "thepay://page.notice"
    case dialer             = "thepay://page.dialer"
    
    case integrate          = "thepay://page.charge.integrate"
    case montlyplan         = "thepay://page.charge.montlyplan"
    case cash               = "thepay://page.charge.cash"
    case sktdata            = "thepay://page.charge.sktdata"
    case international_call = "thepay://page.charge.international_call"
    case eload              = "thepay://page.charge.eload"
    case ars                = "thepay://page.charge.ars"
    case webview            = "thepay://webview"
    
    case easy_terms         = "thepay://page.easypay_terms_of_use"
    case easy_pay           = "thepay://page.easypay"
    case easy_pwd_auth      = "thepay://page.easypay_pwd_auth"
    case easy_list          = "thepay://page.easypay_list"
    
//-------------- CUSTOM --------------//
    case pgwebview          = "thepay://custom.pgwebview"
    case pay                = "thepay://page.charge.pay"
    case main               = "thepay://custom.main"
    case signin             = "thepay://custom.signin"
    case terms              = "thepay://custom.terms"
    case register           = "thepay://custom.register"
    
    case event              = "thepay://page.event"
    case gift_cash          = "thepay://page.giftcash"
    
    var webViewLink: String {
        switch self {
        case .history:
            return "thepay://webview?url=https://thepayw.010pay.co.kr/rcgHistory.html"
        default:
            return ""
        }
    }
    
    var action: ActionType? {
        switch self {
        case .recommend:
            return .share
        default:
            return .segue
        }
    }
    
    var viewController: TPBaseViewController? {
        guard let sb = self.storyboard else { return nil }
        guard let id = self.segue else { return nil }
        
        return sb.instantiateViewController(withIdentifier: id) as? TPBaseViewController
    }
    
    var storyboard: UIStoryboard? {
        switch self {
        case .cash:
            return UIStoryboard(name: Storyboard.Payment, bundle: nil)
        case .history:
            return UIStoryboard(name: Storyboard.Menu, bundle: nil)
        case .dialer:
            return UIStoryboard(name: Storyboard.Contact, bundle: nil)
        case .request_safecard:
            return UIStoryboard(name: Storyboard.SafeCard, bundle: nil)
        case .request_easypay:
            return UIStoryboard(name: Storyboard.EasyPay, bundle: nil)
        case .contactus:
            return UIStoryboard(name: Storyboard.Menu, bundle: nil)
        case .register:
            return UIStoryboard(name: Storyboard.Main, bundle: nil)
        case .webview:
            return UIStoryboard(name: Storyboard.Main, bundle: nil)
        case .eload, .ars, .international_call, .integrate, .sktdata, .gift_cash:
            return UIStoryboard(name: Storyboard.Charge, bundle: nil)
        case .easy_terms, .easy_pay, .easy_pwd_auth, .easy_list:
            return UIStoryboard(name: Storyboard.EasyPay, bundle: nil)
        default:
            return nil
        }
    }
    
    var hasDirectViewController: Bool {
        switch self {
        case .webview:
            return true
        case .eload, .ars, .international_call, .integrate, .sktdata, .gift_cash:
            return true
        case .easy_terms, .easy_pay, .easy_pwd_auth, .easy_list:
            return true
        case .cash:
            return true
        default:
            return false
        }
    }
    
    var segue: String? {
        switch self {
        case .history:
            return Segue.History
        case .pushhistory:
            return Segue.Notice
        case .myinfo:
            return Segue.MyInfo
        case .faq:
            return Segue.FAQ
        case .contactus:
            return Segue.Contactus
        case .lang:
            return Segue.Lang
        case .recommend:
            return Segue.Recommend
        case .request_safecard:
            return Segue.SafeCard
        case .request_easypay:
            return Segue.EasyPayInfo
        case .request_extendstay:
            return Segue.Extendstay
        case .notice:
            return Segue.Notice
        case .dialer:
            return Segue.Dialer
        case .integrate:
            return Segue.Integrate
        case .montlyplan:
            return nil
        case .cash:
            return Segue.Cash
        case .sktdata:
            return Segue.SKTData
        case .international_call:
            return Segue.InternationalCall
        case .eload:
            return Segue.Eload
        case .ars:
            return Segue.ARS
        case .webview:
            return Segue.WebView
        
        case .easy_terms:
            return Segue.EasyPayTerms
        case .easy_pay:
            return Segue.EasyPay
        case .easy_pwd_auth:
            return Segue.EasyPwdAuth
        case .easy_list:
            return Segue.EasyList
        case .gift_cash:
            return Segue.GiftCash
            
//-------------- CUSTOM --------------//
        case .pgwebview:
            return Segue.PGWeb
        case .pay:
            return Segue.Pay
        case .main:
            return Segue.Main
        case .signin:
            return Segue.SignIn
        case .terms:
            return Segue.Terms
        case .register:
            return Segue.Register
        case .event:
            return Segue.Event
        }
    }
    
    var title: String? {
        switch self {
        case .history:
            return Localized.title_activity_history.txt
        case .pushhistory:
            return Localized.title_activity_notice.txt
        case .myinfo:
            return Localized.title_activity_my_info.txt
        case .faq:
            return Localized.title_activity_faq.txt
        case .contactus:
            return UserDefaultsManager.shared.loadContactTitle()
        case .lang:
            return Localized.menu_language.txt
        case .recommend:
            return nil
        case .request_safecard:
            return Localized.btn_safe_card_registration.txt
        case .request_easypay:
            return "간편결제"
        case .request_extendstay:
            return Localized.request_extend_stay_title.txt
        case .notice:
            return Localized.title_activity_notice.txt
        case .dialer:
            return Localized.title_activity_call_main.txt
        case .integrate:
            return Localized.title_activity_charge_integrate.txt
        case .montlyplan:
            return nil
        case .cash:
            return Localized.title_activity_charge_preview_cash.txt
        case .sktdata:
            return Localized.title_activity_skdata.txt
        case .international_call:
            return Localized.title_activity_call_main.txt
        case .eload:
            return Localized.title_eload.txt
        case .ars:
            return Localized.activity_main_list_ars_charge_title.txt
        case .webview:
            return nil
        
        case .easy_terms:
            return nil
        case .easy_pay:
            return nil
        case .easy_pwd_auth:
            return nil
        case .easy_list:
            return nil
        case .gift_cash:
            return nil
            
//-------------- CUSTOM --------------//
        case .pgwebview:
            return nil
        case .pay:
            return nil
        case .main:
            return nil
        case .signin:
            return nil
        case .terms:
            return nil
        case .register:
            return nil
        case .event:
            return nil
        }
    }
}

enum NavContents {
    case voice
    case data
    case month
    case intercall
    case eload
    case skt_data
    
    var title: String {
        switch self {
        case .voice:
            return Localized.title_activity_charge_integrate.txt
        case .data:
            return Localized.title_page_data_charge.txt
        case .month:
            return Localized.title_activity_charge_integrate.txt
        case .intercall:
            return Localized.title_activity_call_main.txt
        case .eload:
            return Localized.title_eload.txt
        case .skt_data:
            return Localized.title_activity_skdata.txt
        }
    }
    
    var subTitle: String {
        switch self {
        case .voice:
            return Localized.contents_page_charge_normal.txt
        case .data:
            return Localized.contents_page_charge_normal.txt
        case .month:
            return Localized.contents_page_charge_month.txt
        case .intercall:
            return Localized.contents_page_call_charge.txt
        case .eload:
            return Localized.contents_page_eload_charge.txt
        case .skt_data:
            return Localized.contents_page_skt_data_charge.txt
        }
    }
}

//enum IconImage: String {
//    case voice = "ic_main_menu_voice"
//    case data = "ic_main_menu_data"
//    case month = "ic_main_menu_month"
//    case intercall = "ic_main_menu_intercall"
//    case eload = "ic_main_menu_eload"
//    case hanpass = "ic_main_menu_hanpass"
//    case extend = "ic_main_menu_extend"
//    case skt_data = "ic_main_menu_skt_lte_data"
//    case ars = "ic_main_menu_ars"
//    case faq = "ic_main_menu_faq"
//    case safe_card = "ic_main_menu_safe_card"
//
//    struct NavTitle {
//        var title: String
//        var subTitle: String
//    }
//
//    var navInfo: NavTitle? {
//        return getNavTitle(value: self.rawValue)
//    }
//
//    func getNavTitle(value: String) -> NavTitle? {
//        if let item = App.shared.pre?.O_DATA?.mainMenuList?.filter({
//            return $0.iconImg == value
//        }).first, let title = item.title, let sub = item.content {
//            return NavTitle(title: title, subTitle: sub)
//        } else {
//            return nil
//        }
//    }
//}
