//
//  API.swift
//  thepay
//
//  Created by xeozin on 2020/06/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import Alamofire

// O_DATA   : 성공 시 실질적인 ResponseData
// O_CODE   : Result Code
// O_MSG    : 실패 시 메시지

class API {
    
    static let shared: API = API()
    
    var serviceURL: ServiceURL = .real
    
    private var reachability: NetworkReachabilityManager?
    
    private init() {
        monitorReachability()
    }
    
    internal func parseError<T: Codable>(d:T) -> TPError? {
        if let t = d as? ResponseAPI {
            var codeString = t.O_CODE
            if t.O_CODE.hasPrefix("8") {
                switch t.O_CODE {
                case FLAG.E8905:
                    break
                case FLAG.E8906:
                    break
                default:
                    codeString = "8XXX"
                }
            }
            if let code:ResultCode = ResultCode(rawValue: codeString) {
                switch code {
                case .success:
                    return nil
                case .errorPin, .errorPin2, .e8905, .e8906:
                    return nil
                case .code9999:
                    return TPError.e9999(code: t.O_CODE, msg: t.O_MSG)
                case .code1087:
                    return TPError.e1087(code: t.O_CODE, msg: t.O_MSG)
                case .resDataNil, .jsonError:
                    return TPError.nilError(code: t.O_CODE, msg: t.O_MSG)
                case .timeout:
                    return TPError.timeout(code: t.O_CODE, msg: t.O_MSG)
                case .errorSession:
                    return TPError.expired(code: t.O_CODE, msg: t.O_MSG)
                case .checkSMS:
                    return TPError.checkSMS(code: t.O_CODE, msg: t.O_MSG)
                case .retry:
                    return TPError.retry(code: t.O_CODE, msg: t.O_MSG)
                }
            } else {
                return TPError.error(code: t.O_CODE, msg: t.O_MSG)
            }
        } else {
            return TPError.error(code: "-1", msg: "IS NOT Response Protocol")
        }
    }
    
    func request<T: Codable>(url: String?, param: [String: Any]?, showDebug: Bool = true, completionHandler: @escaping (Result<T, TPError>) -> Void) {
        guard let url = url else { return }
        print("🌱 URL : \(url)")
        if showDebug {
            if let p = param {
                print("💌💌💌 \(p) 💌💌💌")
            }
        }
        
        AF.request(url, method: .post, parameters: param) { req in
            req.timeoutInterval = url == API.shared.serviceURL.auth_ctn ? 5 : 20
        }.validate().response { [weak self] response in
            switch response.result {
            case .success(let value):
                guard let v = value else { return }
                guard let data = value else { return }
                guard let result = String(data: v, encoding: .utf8) else { return }
                if showDebug { print("⚡️⚡️⚡️ \(url) ⚡️⚡️⚡️ \(result) ⚡️⚡️⚡️") }
                let decoder = JSONDecoder()
                do {
                    let d = try decoder.decode(T.self, from: data)
                    if let error = self?.parseError(d: d) {
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.success(d))  // [ JSON 결과 성공 ]
                    }
                } catch {
                    self?.showErrorMsg(error: error)
                    completionHandler(.failure(TPError.error(code: "-4", msg: "JSON Error")))
                }
            case .failure(let error):
                print("🏴‍☠️🏴‍☠️🏴‍☠️ \(url) \(error) 🏴‍☠️🏴‍☠️🏴‍☠️")
                self?.hideLoadingWindow()
                
                if url == PreloadingRequest().getAPI() {
                    completionHandler(.failure(TPError.retry(code: "-9", msg: error.localizedDescription)))
                }
            }
        }
    }
    
    internal func showErrorMsg(error: Error) {
        let topController : UIViewController? = UIWindow.key?.rootViewController
        topController?.showConfirmAlertSystem(title: "\(error.localizedDescription)", message: "🈚️ \(error)", confirm: {
            exit(-1)
        })
    }
    
    private func hideLoadingWindow() {
        let view = UIApplication.topViewController()
        if let vc = view as? TPBaseViewController {
            vc.hideLoadingWindow()
        }
    }
}



extension API {
    
    private func showNetError() {
        print("🏝🏝🏝 네트워크 연결 필요")
        var warningMsg = Localized.warning_network_not_accesse_dialer_2.txt
        if warningMsg == "" {
            warningMsg = "Please check network connection"
        }
        
        if !App.shared.lastConnectionError {
            App.shared.lastConnectionError = true
            hideLoadingWindow()
            if let topVC = UIApplication.topViewController() as? TPBaseViewController {
                if let vc = topVC as? DialerViewController {
                    vc.checkNetwork()
                } else {
                    self.hideLoadingWindow()
                    /* LOAD LOCALIZED LANGUAGE BUNDLE */
                    if App.shared.bundle == nil {
                        App.shared.generateBundle(lang: UserDefaultsManager.shared.loadNationCode())
                    }
                    topVC.showConfirmHTMLAlert(title: nil, htmlString: Localized.warning_network_not_accesse.txt) {
                        if !App.shared.isReachable {
                            topVC.navigationController?.goToAirplane()
                        }
                    }
                }
            } else {
                warningMsg.showErrorMsg(target: UIApplication.topViewController()?.view)
            }
        }
    }
    
    private func conn() {
        if App.shared.lastConnectionError {
            App.shared.lastConnectionError = false
            print("⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️⚡️")
            if let topVC = UIApplication.topViewController() {
                if topVC is IntroViewController {
                    let o = topVC as? IntroViewController
                    o?.considerToNext()
                } else {
                    NotificationCenter.default.post(name: ThePayNotification.Airplane.name, object: nil)
                }
            }
        }
    }
    
    private func monitorReachability() {
        
        if reachability == nil {
            reachability = NetworkReachabilityManager(host: "www.apple.com")
        }
        reachability?.startListening { status in
            switch status {
            case .notReachable:
                App.shared.isReachable = false
                self.showNetError()
            case .reachable(let type):
                switch type {
                case .cellular:
                    print("🏖🏖🏖 셀룰러 접근")
                case .ethernetOrWiFi:
                    print("🚦🚦🚦 와이파이 접근")
                }
                App.shared.isReachable = true
                self.conn()
            default:
                print("연결")
            }
        }
    }
}

extension API {
    
    func hasSavedData(opCode: SubPreloadingRequest.OP_CODE) -> Bool {
        switch opCode {
        case .bankList:
            if let count = App.shared.bankList?.count {
                if count > 0 { return true }
            }
        case .cashList:
            if let count = App.shared.cashList?.count {
                if count > 0 { return true }
            }
        case .coupon:
            if let count = App.shared.coupon?.count {
                if count > 0 { return true }
            }
        case .eload:
            if let count = App.shared.eLoad?.count {
                if count > 0 { return true }
            }
        case .intl:
            if let count = App.shared.intl?.count {
                if count > 0 { return true }
            }
        case .ppsAll:
            if let count = App.shared.pps?.count, let count2 = App.shared.mthRate?.count {
                if count > 0 && count2 > 0 { return true }
            }
        case .snsList:
            if let count = App.shared.snsList?.count {
                if count > 0 { return true }
            }
        }
        
        return false
    }
    
}
