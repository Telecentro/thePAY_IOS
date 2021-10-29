//
//  MainViewModel.swift
//  thepay
//
//  Created by 홍서진 on 2021/05/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit
import Kingfisher


extension UITableView {

    func addTopBounceAreaView(color: UIColor = .red) {
        var frame = UIScreen.main.bounds
        frame.origin.y = -frame.size.height

        let view = UIView(frame: frame)
        view.backgroundColor = color

        self.addSubview(view)
    }
}

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

class MainViewModel {
    
    struct MainMenu {
        var left:PreloadingResponse.mainMenuList?
        var right:PreloadingResponse.mainMenuList?
    }
    
    var kingfisherSource:[KingfisherSource] = []
    
    var menuData = App.shared.pre?.O_DATA?.mainMenuList
    var mergedMenuData:[MainMenu?] = []
    var hotKeyData = App.shared.pre?.O_DATA?.hotKeyList
    let transition = SlideInTransition()
    let visualEffectView = UIView()
    var tapOutsideRecognizer: UITapGestureRecognizer!
    var canOpenSideMenu = true
    
    var timer: Timer?
    
    var ani: String
    var email: String
    
    init() {
        ani = StringUtils.telFormat(UserDefaultsManager.shared.loadANI() ?? "")
        let e = Utils.getSnsEmail()
        if e == "" {
            email = UserDefaultsManager.shared.loadUUID() ?? ""
        } else {
            email = e
        }
        
        switch App.shared.codeLang {
        case .CodeLangMMR, .CodeLangMMY:
            mergeOneLineMenu()
        default:
            mergeMenu()
        }
    }
    
    
    func getLoginTypeImage() -> UIImage? {
        let type = Utils.userIdType()
        switch type {
        case "GML":
            return UIImage(named: "ic_login_type_google")
        case "FCB":
            return UIImage(named: "ic_login_type_facebook")
        case "APPLE":
            return UIImage(named: "ic_login_type_apple")
        default:
            return UIImage(named: "ic_login_type_thepay")
        }
    }
    
    private func mergeOneLineMenu() {
        guard let menu = self.menuData else { return }
        
        for i in menu {
            let x:MainMenu = MainMenu(left: i, right: nil)
            mergedMenuData.append(x)
        }
    }
    
    private func mergeMenu() {
        guard let menu = self.menuData else { return }
        var x:MainMenu?
        for i in menu {
            if x == nil {
                x = MainMenu(left: i, right: nil)
            } else {
                x?.right = i
                mergedMenuData.append(x)
                x = nil
            }
        }
        
        if x != nil {
            mergedMenuData.append(x)
            x = nil
        }
    }
}
