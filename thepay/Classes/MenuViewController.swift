//
//  MenuViewController.swift
//  SlideMenuTest
//
//  Created by xeozin on 2020/07/04.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: TPLabel!
}

class MenuViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var lblMobile: TPLabel!
    @IBOutlet weak var lblPhoneNumber: TPLabel!
    @IBOutlet weak var lblIdentity: TPLabel!
    @IBOutlet weak var lblUniqueSign: TPLabel!
    @IBOutlet weak var lblAboutUs: TPLabel!
    @IBOutlet weak var btnTerms: TPButton!
    @IBOutlet weak var btnPrivacy: TPButton!
    @IBOutlet weak var topCorner: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ivLoginType: UIImageView!
    
    @IBOutlet weak var shortMenu: DynamicSideMenu!
    
    private var tapOutsideRecognizer: UITapGestureRecognizer!
    var menuData = App.shared.pre?.O_DATA?.toggleMenuList
    var didTapMenu: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(self.tapOutsideRecognizer == nil) {
            self.tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBehind))
            self.tapOutsideRecognizer.numberOfTapsRequired = 1
            self.tapOutsideRecognizer.cancelsTouchesInView = false
            self.tapOutsideRecognizer.delegate = self
            self.view.window?.addGestureRecognizer(self.tapOutsideRecognizer)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if(self.tapOutsideRecognizer != nil) {
            self.view.window?.removeGestureRecognizer(self.tapOutsideRecognizer)
            self.tapOutsideRecognizer = nil
        }
    }
    
    func localize() {
        let number: String = UserDefaultsManager.shared.loadANI() ?? ""
        lblPhoneNumber.text = StringUtils.telFormat(number)
        lblUniqueSign.text = UserDefaultsManager.shared.loadUUID()
        lblMobile.text = Localized.com_my_mobile.txt
        lblIdentity.text = Localized.com_my_id.txt
        lblAboutUs.text = Localized.company_info.txt
        
        btnTerms.setTitle(Localized.title_activity_term_service.txt, for: .normal)
        btnPrivacy.setTitle(Localized.title_activity_privacy_policy.txt, for: .normal)
    }
    
    func initialize() {
        topCorner.roundCorners(.topRight, radius: 8)
        tableView.addTopBounceAreaView(color: .white)
        
        ivLoginType.image = Utils.getLoginTypeImage()
        
        shortMenu.updateDisplay(menuList: menuData)
        
        sliceMenu()
    }
    
    private func sliceMenu() {
        if let cnt = menuData?.count {
            if cnt > 3 {
                let i = menuData?[3..<cnt]
                menuData = Array<PreloadingResponse.toggleMenuList>(i ?? [])
            }
        }
    }
    
    func moveWebView(type: String, url: String, title: String ) {
        guard let encodedString = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        self.didTapMenu?("\(type)?url=\(url)&adverTitle=\(encodedString)")
    }
    
    func close(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func showMyInfo(_ sender: Any) {
        self.didTapMenu?(Link.myinfo.rawValue)
    }
    
    @IBAction func showTerms(_ sender: Any) {
        moveWebView(type: Link.webview.rawValue,
                    url: ServiceURL.real.wv_terms,
                    title: Localized.menu_use.txt)
    }
    
    @IBAction func pressCloseButton(_ sender: Any) {
        self.didTapMenu?("")
    }
    
    @IBAction func showPrivacy(_ sender: Any) {
        moveWebView(type: Link.webview.rawValue,
                    url: ServiceURL.real.wv_privacy,
                    title: Localized.menu_privacy.txt)
    }
    
    @IBAction func moveMenu1(_ sender: Any) {
        if let mLink = shortMenu.menu1?.moveLink {
            self.didTapMenu?(mLink)
        }
    }
    
    @IBAction func moveMenu2(_ sender: Any) {
        if let mLink = shortMenu.menu2?.moveLink {
            self.didTapMenu?(mLink)
        }
    }
    
    @IBAction func moveMenu3(_ sender: Any) {
        if let mLink = shortMenu.menu3?.moveLink {
            self.didTapMenu?(mLink)
        }
    }
}

// MARK: - Gesture methods to dismiss this with tap outside
extension MenuViewController: UIGestureRecognizerDelegate {
    @objc func handleTapBehind(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            let location: CGPoint = sender.location(in: self.view)

            if (!self.view.point(inside: location, with: nil)) {
                self.view.window?.removeGestureRecognizer(sender)
                self.close(sender: sender)
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // .hard, .soft 모드일때 디버그 메뉴 노출
        let add = (App.shared.debug == .none) ? 0 : 1
        return (menuData?.count ?? 0) + add
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        if indexPath.row < menuData?.count ?? 0 {
            cell.lblTitle.text = menuData?[indexPath.row].title
            cell.imgIcon.image = UIImage(named: menuData?[indexPath.row].iconImg ?? "")
//            cell?.detailTextLabel?.text = menuData?[indexPath.row].moveLink
        } else {
            cell.lblTitle.text = "DEV SETTINGS"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == self.menuData?.count ?? 0 {
            self.didTapMenu?("debug")
            return
        }
        
        guard let moveLink = self.menuData?[indexPath.row].moveLink else { return }
        self.didTapMenu?(moveLink)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
