//
//  DebugViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/30.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {
    
    var callback: (()->())?
    @IBOutlet weak var debugInfo: UITextView!
    @IBOutlet weak var seg: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch API.shared.serviceURL {
        case .dev2, .dev:
            self.seg.selectedSegmentIndex = 0
        case .real:
            self.seg.selectedSegmentIndex = 1
        }
        
        updateProfile()
    }
    
    private func updateProfile() {
        self.debugInfo.text = """
        App Language : \(App.shared.codeLang)
        App Debug JSON : \(App.shared.debugResponseJSON)
        App hasPushInfo : \(App.shared.hasPushInfo)
        API Service URL : \(API.shared.serviceURL)
        
        ----D-U-O-L-A-B-S----
        
        ANI : \(UserDefaultsManager.shared.loadANI() ?? "NULL")
        UUID : \(UserDefaultsManager.shared.loadUUID() ?? "NULL")
        SESSIONID : \(UserDefaultsManager.shared.loadSessionID() ?? "NULL")
        NOTICE SEQ : \(UserDefaultsManager.shared.loadNoticeSeq() ?? "NULL")
        PINNUMBER : \(UserDefaultsManager.shared.loadMyPinNumber() ?? "NULL")
        APNS TOKEN : \(UserDefaultsManager.shared.loadAPNSToken() ?? "NULL")
        
        ----LANGUAGES----
        
        flagCode : \(App.shared.codeLang.flagCode)
        nationAlphaName : \(App.shared.codeLang.nationAlphaName)
        languageCode : \(App.shared.codeLang.languageCode)
        localeCode : \(App.shared.codeLang.localeCode)
        nationName : \(App.shared.codeLang.nationName)
        nationCode : \(App.shared.codeLang.nationCode)
        """
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProfile()
    }
    
    @IBAction func detail(_ sender: Any) {
        setupServer()
    }
    
    func setupServer() {
        let alert = UIAlertController(title: "서버 설정", message: nil, preferredStyle: .actionSheet)
        
        let dev = UIAlertAction(title: "DEV1 (61.111.2.224:7944)", style: .default) { (action) in
            API.shared.serviceURL = .dev
            App.shared.selectedServer = true
            self.dismiss(animated: true) { [weak self] in
                self?.callback?()
            }
        }
        
        let dev2 = UIAlertAction(title: "DEV2 (61.111.2.158:7944)", style: .default) { (action) in
            API.shared.serviceURL = .dev2
            App.shared.selectedServer = true
            self.dismiss(animated: true) { [weak self] in
                self?.callback?()
            }
        }
        
        let real = UIAlertAction(title: "REAL (thePay)", style: .destructive) { (action) in
            API.shared.serviceURL = .real
            App.shared.selectedServer = true
            self.dismiss(animated: true) { [weak self] in
                self?.callback?()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
//            self.dismiss(animated: true)
        }
        
        alert.addAction(dev)
        alert.addAction(dev2)
        alert.addAction(real)
        alert.addAction(cancel)
        
        self.present(alert, animated: true) {
            
        }
    }
    
    @IBAction func done(_ sender: Any) {
        print(self.seg.selectedSegmentIndex)
        if self.seg.selectedSegmentIndex == 0 {
            API.shared.serviceURL = .dev
        } else if self.seg.selectedSegmentIndex == 1 {
            API.shared.serviceURL = .real
        }
        
        App.shared.selectedServer = true
        self.dismiss(animated: true)
    }
    
}


class DebugOptionViewController: UITableViewController {
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.switch1.isOn = App.shared.debugResponseJSON
        self.switch2.isOn = App.shared.debugLanguageKeys
    }
    
    @IBAction func press1(_ sender: UISwitch) {
        App.shared.debugResponseJSON = sender.isOn
    }
    
    @IBAction func press2(_ sender: UISwitch) {
        App.shared.debugLanguageKeys = sender.isOn
    }
}
