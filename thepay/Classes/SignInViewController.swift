//
//  SignInViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/08.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import AuthenticationServices
import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import SnapKit


class SignInViewController: TPBaseViewController, TPLocalizedController {
    
    enum Button: String {
        case facebook   = "FCB"
        case google     = "GML"
        case thepay     = "UUID"
        case apple      = "APPLE"
        
        var name: String {
            return self.rawValue
        }
    }
    
    @IBOutlet weak var svButtons: UIStackView!
    @IBOutlet weak var btnEasy: TPButton!
    @IBOutlet weak var viewApple: UIView!
    @IBOutlet weak var btnGoogle: TPButton!
    @IBOutlet weak var btnFacebook: TPButton!
    @IBOutlet weak var lblDesc: TPLabel!
    
    var activeButtons: [Button] = [.facebook, .google, .thepay, .apple]
    
    var loginList: [PreCheckResponse.loginList] = []
    
    var isFirst: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirst {
            isFirst = false
            initialize()
        }
    }
    
    func initialize() {
        if #available(iOS 13.0, *) {
            let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
            button.addTarget(self, action: #selector(loginApple), for: .touchUpInside)
            self.viewApple.addSubview(button)
            
            button.snp.makeConstraints { snp in
                snp.edges.equalToSuperview()
            }
        } else {
            self.viewApple.isHidden = true
        }
        
        if loginList.count > 1 {
            for (index, _) in loginList.enumerated() {
                insertLoginButton(index: index)
            }
            
            for i in self.activeButtons {
                getButton(code: i.name)?.removeFromSuperview()
            }
        }
    }
    
    private func insertLoginButton(index: Int) {
        if let v = getButton(index: index) {
            self.svButtons.insertArrangedSubview(v, at: index)
        }
    }
    
    private func getButton(index: Int) -> UIView? {
        if let code = loginList[index].loginCode {
            self.activeButtons = self.activeButtons.filter() { $0.name != code }
        }
        
        return getButton(code:loginList[index].loginCode ?? "")
    }
    
    private func getButton(code: String) -> UIView? {
        switch code {
        case Button.facebook.name:
            return btnFacebook
        case Button.google.name:
            return btnGoogle
        case Button.thepay.name:
            return btnEasy
        case Button.apple.name:
            return viewApple
        default: return nil
        }
    }
    
    func localize() {
        self.setupNavigationBar(type: .logoOnly2)
        self.lblDesc.text = Localized.login_type_select_warning.txt
        self.btnGoogle.setTitle(Localized.google_login_button_text.txt, for: .normal)
        self.btnFacebook.setTitle(Localized.facebook_login_button_text.txt, for: .normal)
        self.btnEasy.setTitle(Localized.easy_login_button_text.txt, for: .normal)
    }
    
    // 애플 로그인
    @objc func loginApple(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    // 이지 로그인
    @IBAction func loginEasy(_ sender: Any) {
        let id = UserDefaultsManager.shared.loadUUID(social: false) ?? ""
        let email = ""
        
        register(id: id, email: email, type: .Easy)
    }
    
    // 구글 로그인
    @IBAction func loginGoogle(_ sender: Any) {
        let config = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let _ = error {
                return
            }
            
            // 구글 로그아웃
            GIDSignIn.sharedInstance.signOut()
            GIDSignIn.sharedInstance.disconnect()
            
            if let userID = user?.userID, let email = user?.profile?.email {
                self.register(id: userID, email: email, type: .Google)
            }
        }
    }
    
    // 페이스북 로그인
    @IBAction func loginFacebook(_ sender: Any) {
        let loginManager = LoginManager.init()
        
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { [weak self] (loginResult) in
            guard let self = self else { return }
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User Cancel")
            case .success(let grantedPermissions, let decliendPermissions, let accessToken):
                print(grantedPermissions, decliendPermissions, accessToken ?? "")
                AccessToken.current = accessToken
                let params = ["fields": "id, email"]
                GraphRequest(graphPath: "me", parameters: params).start { (conn, results, error) in
                    guard let data = results as? [String: String] else { return }
                    if error == nil {
                        
                        // 페이스북 로그아웃
                        loginManager.logOut()
                        
                        let id = data["id"] ?? ""
                        let email = data["email"] ?? ""
                        self.register(id: id, email: email, type: .Facebook)
                    }
                }
            }
        }
    }
    
    // [아이디 / 이메일] 등록 및 화면 이동
    private func register(id: String, email: String, type: LoginType, segue: Bool = true) {
        print("ID : \(id), EMail : \(email), type : \(type.rawValue) Try Register...")
        
        Utils.setSnsInfo(dataDictionary: [
            K.kSnsId:id,
            K.kEmail:email,
            K.kMemberType:type.rawValue
        ])
        
        // 2021.3.17 애플 로그인 이슈
        if segue {
            SegueUtils.openMenu(target: self, link: .register)
        }
    }
}

// 구글 로그인
extension SignInViewController {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            return
        }
        
        // 구글 로그아웃
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.disconnect()
        
        self.register(id: user.userID ?? "", email: user.profile?.email ?? "", type: .Google)
    }
    
    // 연결 끊김 처리 (X)
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) { }
}

// 애플 로그인
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            var savedEmail = ""
            
            if let email = appleIdCredential.email, let _ = appleIdCredential.fullName {    // 최초 로그인
                UserDefaultsManager.shared.saveAppleEmail(value: email)
                savedEmail = email
            } else {    // 재 로그인
                savedEmail = UserDefaultsManager.shared.loadAppleEmail() ?? ""
            }
            
            self.register(id: appleIdCredential.user, email: savedEmail, type: .Apple)
        }
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
