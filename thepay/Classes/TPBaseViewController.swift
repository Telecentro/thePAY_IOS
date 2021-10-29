//
//  BaseViewController.swift
//  thepay
//
//  Created by xeozin on 2020/06/26.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import SnapKit

protocol TPLocalizedController {
    func localize()
    func initialize()
}

class TPBaseViewController: UIViewController {
    var params: [String: Any]?
    var loadingContainer:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let win = UIWindow.key else { return }
        loadingContainer = UIView(frame: win.frame)
        loadingContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // 백버튼 텍스트 제거
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.setupNavigationBar(type: .basic(title: self.title))
        
        if let p = params {
            print("has param : \(p)")
        }
        
        // TODO: 폐기 대상
        if let timeMachine = self.params?["Timemachine"] as? Timemachine {
            switch timeMachine {
            case .main:
                self.navigationController?.removeSubrangeMain()
            default:
                break
            }
        }
        
        if let timemahine = self.params?[UDP.timemachine] as? String {
            switch timemahine {
            case Timemachine.main.rawValue:
                self.navigationController?.removeSubrangeMain()
            case Timemachine.`self`.rawValue:
                self.navigationController?.removeSubrangeSelf()
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = self as? MainViewController {
            if let v = self.navigationController as? TPNavigationViewController {
                v.ok()
            }
        } else {
            if let v = self.navigationController as? TPNavigationViewController {
                v.ok2()
            }
        }
        
        
    }
    
    // 공유하기
    func shared() {
        let thePaytext = [Localized.sns_friends.txt]
        let activityVC = UIActivityViewController(activityItems: thePaytext, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TPBaseViewController {
            if let info = sender as? SegueInfo {
                vc.title = info.title
                vc.params = info.params
            }
        }
    }
    
    func resetSideMenu() {
        if let nav = self.navigationController as? ENSideMenuNavigationController {
            nav.sideMenu = nil
        }
    }
}

extension TPBaseViewController {
    func showLoadingWindow() {
        guard let win = UIWindow.key else { return }
        
        if let con = loadingContainer {
            let v = SpinnerView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            v.center = con.center
            con.addSubview(v)
            win.addSubview(con)
            
            con.snp.makeConstraints{ m in
                m.edges.equalToSuperview()
            }
        }
    }
    
    // 웹뷰 전용
    func showClearLoadingWindow() {
        if let con = loadingContainer {
            con.backgroundColor = .clear
        }
        
        showLoadingWindow()
    }
    
    func hideLoadingWindow() {
        if let con = loadingContainer {
            for v in con.subviews {
                v.removeFromSuperview()
            }
            con.removeFromSuperview()
        }
    }
    
    func requestSubPreloading<T>(opCode: SubPreloadingRequest.OP_CODE, completionHandler: @escaping (T?) -> Void) {
        if API.shared.hasSavedData(opCode: opCode) {
            completionHandler(nil)
        } else {
            self.showLoadingWindow()
            let req = SubPreloadingRequest(opCode: opCode)
            API.shared.request(url: req.getAPI(), param: req.getParam(), showDebug: false) { [weak self] (response:Swift.Result<SubPreloadingResponse, TPError>) -> Void in
                guard let self = self else { return }
                switch response {
                case .success(let data):
                    self.hideLoadingWindow()
                    App.shared.appendMvnoList(data: data, opCode: opCode)
                    completionHandler(nil)
                case .failure(let error):
                    self.hideLoadingWindow()
                    error.processError(target: self)
                }
            }
        }
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            let win = UIApplication.shared.windows.first { $0.isKeyWindow }
            if win == nil {
                return UIApplication.shared.windows.first
            } else {
                return win
            }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
