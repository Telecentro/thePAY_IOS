//
//  TPBaseNavigationExtension.swift
//  thepay
//
//  Created by xeozin on 2020/07/02.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum NavigationType {
    case basic(title: String?)
    case languageFirst
    case languageNormal
    case main
    case logo
    case logoOnly
    case logoOnly2
    case fullScreen
    case camera(title: String?)
}

// iOS 13.5 무시됨
//extension UIViewController {
//    open override func awakeFromNib() {
//        super.awakeFromNib()
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//    }
//}

extension TPBaseViewController {
    func setupNavigationBar(type: NavigationType) {
        switch type {
        case .basic(let title):
            self.title = title
//            setupNavigationTitle(title: self.title)
            setupTitleLogo2()
            self.navigationController?.isNavigationBarHidden = false
        case .languageFirst:
            setupTitleLogo2()
            self.navigationItem.hidesBackButton = true
            self.navigationController?.isNavigationBarHidden = false
        case .languageNormal:
            setupTitleLogo2()
            self.navigationItem.hidesBackButton = false
            self.navigationController?.isNavigationBarHidden = false
        case .main:
            setupTitleLogo()
            setupMenuButton()
            setupRightButton()
            self.navigationItem.hidesBackButton = true
            self.navigationController?.isNavigationBarHidden = false
        case .logo:
            setupTitleLogo()
            self.navigationController?.isNavigationBarHidden = false
        case .logoOnly:
            setupTitleLogo()
            self.navigationItem.hidesBackButton = true
            self.navigationController?.isNavigationBarHidden = false
        case .logoOnly2:
            setupTitleLogo2()
            self.navigationItem.hidesBackButton = true
            self.navigationController?.isNavigationBarHidden = false
        case .fullScreen:
            self.navigationController?.isNavigationBarHidden = true
        case .camera(let title):
            self.title = title
            setupCloseButton()
            setupNavigationTitle(title: self.title)
        }
    }
    
    private func setupTitleLogo() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_main"))
    }
    
    
    private func setupTitleLogo2() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "icoLogoSub"))
    }
    
    
    private func setupCloseButton() {
        let imgView: UIImageView = UIImageView()
        imgView.image = UIImage(named: "btn_menu_closed")
        imgView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        let containerView: UIView = UIView()
        containerView.frame = CGRect(x: -20, y: 0, width: 60, height: 40)

        let coverButton: UIButton = UIButton(type: .custom)
        coverButton.addTarget(self, action: #selector(leftMenu), for: .touchUpInside)

        containerView.addSubview(imgView)
        containerView.addSubview(coverButton)
        imgView.center = containerView.center
        coverButton.center = containerView.center
        coverButton.frame = containerView.frame
        let barButton = UIBarButtonItem(customView: containerView)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    private func setupMenuButton() {
        let btn = UIBarButtonItem(
            image: UIImage(named: "icoMenu"),
            style: .plain,
            target: self,
            action: #selector(leftMenu)
        )
        
        btn.tintColor = .white
        navigationItem.leftBarButtonItem = btn
    }
    
    private func setupLangButton() {
        let button: UIButton = UIButton(type: .custom)
        print("flagCode: \(App.shared.codeLang.flagCode)")
        button.setBackgroundImage(UIImage(named: "flags_\(App.shared.codeLang.flagCode)"), for: .normal)
        button.addTarget(self, action: #selector(rightMenu), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 32)

        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupRightButton() {
        let button: UIButton = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "icon_contact"), for: .normal)
        
        button.addTarget(self, action: #selector(rightMenu), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func leftMenu() { }
    @objc func rightMenu() { }
    
    func setupNavigationTitle(title: String?) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.font = LanguageUtils.fontWithSize(size: 18, oldFont: titleLabel.font)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.numberOfLines = 2
        titleLabel.minimumScaleFactor = 0.5
        navigationItem.titleView = titleLabel
    }
    
    func updateTitle(title: String) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = title
        }
    }
}
