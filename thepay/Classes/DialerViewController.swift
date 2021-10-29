//
//  DialerViewController.swift
//  thepay
//
//  Created by xeozin on 2020/08/12.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SafariServices

class DialerViewController: TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var btnKT: TPButton!
    @IBOutlet weak var btnSK: TPButton!
    @IBOutlet weak var btnRecharge: UIButton!
    @IBOutlet weak var lblRecharge: TPLabel!
    @IBOutlet weak var lblErrorRecharge: TPLabel!
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var lblNetError: TPLabel!
    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var viewRecharge: UIView!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var svNetError: UIView!
    @IBOutlet weak var svBalance: UIView!
    // @IBOutlet weak var lblPhone: TPLabel!
    @IBOutlet weak var lblBalanceTitle: TPLabel!
    @IBOutlet weak var lblBalance: TPLabel!
    
    @IBOutlet weak var lblTelecomNumber: TPLabel!   // 080, 00796, 00301
    @IBOutlet weak var lblNumber: TPLabel!          // 입력 전화번호
    
    @IBOutlet weak var ivNation: UIImageView!
    @IBOutlet weak var lblNation: TPLabel!
    @IBOutlet weak var lblPrefix: TPLabel!
    
    @IBOutlet weak var ivRefreshError: UIImageView!
    @IBOutlet weak var ivRefresh: UIImageView!
    @IBOutlet weak var btnChange: TPButton!
    @IBOutlet weak var btnBack: TPButton!
    
    @IBOutlet weak var dialerBackgroundView: UIView!
    
    var vm = DialerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
        
    func localize() {
        self.btnKT.setTitle("KT \(TELECOM.KT_INTERNATIONAL_CODE)", for: .normal)
        self.btnSK.setTitle("SK \(TELECOM.SKT_INTERNATIONAL_CODE_1)", for: .normal)
        self.btnRate.setTitle(Localized.activity_call_rate.txt, for: .normal)
        self.lblRecharge.text = Localized.btn_recharge.txt
        self.lblErrorRecharge.text = Localized.btn_recharge.txt
        self.lblDesc.text = Localized.guide_preview_msg_00796or00301.txt
        self.lblNetError.text = Localized.toast_msg_internet_fail.txt
        // self.lblPhone.text = StringUtils.telFormat(UserDefaultsManager.shared.loadANI() ?? "")
    }
    
    func initialize() {
        /* 인트로에서 들어올때 HIDE */
//        PKHUD.sharedHUD.hide()
        self.hideLoadingWindow()
        
        svNetError.isHidden = true
        
        setupNationItem(cc: vm.savedInternaltionalCallISO2Code())
        addLongPressEvent()
        
        bind()
        bindPublish()
        
        vm.checkNetwork()
    }
}

// MARK: - ReactiveX
extension DialerViewController {
    
    private func bind() {
        vm.balance.subscribe { [weak self] in
            self?.lblBalance.text = $0.element
            self?.hideLoadingWindow()
        }.disposed(by: vm.db)
        
        vm.type.subscribe { [weak self] in
            guard let self = self else { return }
            guard let type = $0.element else { return }
            
            switch type {
            case .kt:
                self.viewRecharge.isHidden = false
                self.updateDisplayKT()
            case .skt:
                if App.shared.lastConnectionError == true {
                    self.viewRecharge.isHidden = true
                }
                
                self.updateDisplaySKT()
            }
            
            self.updateTitle(type)
        }.disposed(by: vm.db)
    
        vm.pressedNumber.subscribe { [weak self] in
            self?.lblNumber.text = $0.element
            self?.dialerBackgroundView.isHidden = $0.element?.count == 0
            self?.changeDierBacgroundView()
        }.disposed(by: vm.db)
    }
    
    private func changeDierBacgroundView() {
        if self.lblPrefix.text?.count ?? 0 > 0 {
            self.dialerBackgroundView.isHidden = false
        }
    }
    
    private func bindPublish() {
        vm.netError.subscribe { [weak self] in
            guard let self = self else { return }
            $0.element?.processError(target: self)
        }.disposed(by: vm.db)
        
        vm.isAirplaneMode.subscribe { [weak self] in
            guard let self = self else { return }
            if $0.element ?? false {
                NotificationCenter.default.addObserver(self, selector: #selector(self.goIntro), name: ThePayNotification.Airplane.name, object: nil)
                self.resetSideMenu()
                self.setupNavigationBar(type: .logoOnly2)
                self.svNetError.isHidden = false
                self.svBalance.isHidden = true
                self.viewRate.isHidden = true
                if self.vm.currentType == .skt {
                    self.viewRecharge.isHidden = true
                }
            } else {
                self.setupNavigationBar(type: .basic(title: Localized.title_activity_call_main.txt))
                self.svNetError.isHidden = true
                self.svBalance.isHidden = false
                self.viewRate.isHidden = false
                self.viewRecharge.isHidden = false
            }
        }.disposed(by: vm.db)
    }
}

// MARK: - Internal
extension DialerViewController {
    
    private func updateDisplayKT() {
        self.btnKT.isSelected = true
        self.btnSK.isSelected = false
        self.lblRecharge.isHidden = false
        self.btnRecharge.isHidden = false
        
        var image: UIImage?
        if self.vm.savedKT == 0 {
            image = UIImage(named: TELECOM.IMAGE_796080)
            self.lblDesc.text = Localized.guide_preview_msg_00796or00301.txt
            self.lblTelecomNumber.text = TELECOM.KT_INTERNATIONAL_CODE
        } else {
            image = UIImage(named: TELECOM.IMAGE_080796)
            self.lblDesc.text = Localized.guide_preview_msg_080.txt
            self.lblTelecomNumber.text = TELECOM.CODE_080
        }
        self.btnChange.setImage(image, for: .normal)
        
        self.lblDesc.sizeToFit()
    }
    
    private func updateDisplaySKT() {
        self.btnKT.isSelected = false
        self.btnSK.isSelected = true
        
        let s = SKT(rawValue: self.vm.savedSKT ?? 0) ?? .N0841102
        let image = UIImage(named: s.imageName)
        self.lblDesc.text = s.guidePreviewMsg
        self.lblTelecomNumber.text = s.telecomNumber
        self.btnChange.setImage(image, for: .normal)
        
        self.lblDesc.sizeToFit()
    }
    
    private func updateTitle(_ type : DialerType) {
        self.lblBalanceTitle.text = "\(type.title) \(Localized.alert_msg_search_remains.txt)"
    }
    
    private func updateDial(new :String) {
        setupNationItem(cc: vm.savedInternaltionalCallISO2Code())
        vm.updateNumber(new: new)
    }
    
    // 초기값 설정
    private func setupNationItem(cc: String? = nil) {
        var countryCode: String = ""
        if let c = cc {
            countryCode = c
        } else {
            vm.updateKR()
            countryCode = vm.selectNation.countryCode
        }
        
        let nations = DBListManager.getNationList() as? [NationItem]
        
        for i in nations ?? [] {
            if countryCode == i.countryCode {
                vm.updateNation(item: i)
            }
        }
        
        updateNation()
    }
    
    private func updateNation() {
        self.lblNation.text = vm.selectNation.nameUs
        self.ivNation.image = UIImage(named: vm.selectNation.getImgNm())
        
        if vm.selectNation.countryCode == "kr" {
            self.lblPrefix.text = ""
        } else {
            self.lblPrefix.text = "+\(vm.selectNation.countryNumber ?? "")"
        }
        
        changeDierBacgroundView()
    }
    
}

// MARK: - Selector
extension DialerViewController {
    
    @objc private func goIntro() {
        self.showCheckAlert(title: "Network Notice", message: Localized.alert_network_accesse_dialer.txt, confirm: {
            NotificationCenter.default.removeObserver(self, name: ThePayNotification.Airplane.name, object: nil)
            self.navigationController?.backToIntro()
        }, cancel: nil)
    }
    
    private func addLongPressEvent() {
        let event: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(deleteLong))
        self.btnBack.addGestureRecognizer(event)
    }
    
    @objc func deleteLong() {
        setupNationItem()
        vm.clear()
    }
    
    func checkNetwork() {
        vm.checkNetwork()
    }
}

// MARK: - NationListDelegate
extension DialerViewController: NationListDelegate {
    func nation(item: NationItem) {
        vm.selectNation = item
        updateNation()
    }
}

// MARK: - PREPARE [ UIStoryboardSegue ]
extension DialerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NationListViewController {
            vc.delegate = self
        }
        
        if let vc = segue.destination as? AddressViewController {
            if vm.selectNation.countryCode == nil {
                return
            }
            vc.selectNationCode = vm.selectNation.countryCode
            
            // 전화 번호 선택
            vc.item = { [weak self] contact in
                guard let self = self else { return }
                if let nation = DBListManager.getNationInfo(contact.countryCode) {
                    self.vm.selectNation = nation
                    self.updateNation()
                    self.vm.updateNumber(new: contact.callNumber ?? "")
                }
            }
        }
        
        if segue.identifier == "Country" {
            if let vc = segue.destination as? AddressViewController {
                vc.currentType = .country
            }
        }
        
        if let vc = segue.destination as? ARSViewController {
            vc.isAirplaneMode = vm.lastAirplaneMode
        }
    }
}

// MARK: - @IBAction
extension DialerViewController {
    
    /**
     *  KT 탭 버튼
     */
    @IBAction func callKT(_ sender: Any) {
        vm.tapKT()
    }
    
    /**
     *  SKT 탭 버튼
     */
    @IBAction func callSK(_ sender: Any) {
        vm.tapSKT()
    }
    
    //    xeozin 2020/09/27 reason: 연락처 권한 버튼 추가
    @IBAction func goRecentContact(_ sender: Any) {
        Utils.getContactPermissions(vc: self, segue: "Recent")
    }
    
    @IBAction func goCountryContact(_ sender: Any) {
        Utils.getContactPermissions(vc: self, segue: "Country")
    }
    
    /**
     *  화면 갱신
     */
    @IBAction func refresh(_ sender: Any) {
        if App.shared.lastConnectionError == false && !svNetError.isHidden {
            self.navigationController?.backToIntro()
            return
        }
        
        self.ivRefresh.transform = CGAffineTransform.identity
        self.ivRefresh.layoutIfNeeded()
        UIView.animate(withDuration: 1.5) {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = 1.5
            self.ivRefresh.layer.add(rotateAnimation, forKey: nil)
        }
        
        showLoadingWindow()
        vm.request()
    }
    
    /**
     *  충전
     */
    @IBAction func charge(_ sender: Any) {
        if vm.lastAirplaneMode {
            self.performSegue(withIdentifier: Segue.ARS, sender: nil)
        } else {
            SegueUtils.push(target: self, link: .international_call, params: ["product_type" : vm.currentType.key])
        }
    }
    
    /**
     *  요율 보기
     */
    @IBAction func showRate(_ sender: Any) {
        let moveInfo = vm.getRateMoveInfo()
        if let vc = Link.webview.viewController as? WebViewController {
            vc.needFakeButton = false
            vc.titleString = moveInfo.titleString
            vc.urlString = moveInfo.urlString
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func pressDial(_ sender: UIButton) {
        let v = sender.tag - 100
        vm.updatePressNumber(str: "\(v)")
    }
    
    @IBAction func pressBackspace(_ sender: UIButton) {
        vm.backspace()
    }
    
    /* 080 <-> 00301 */
    @IBAction func change(_ sender: Any? = nil) {
        vm.rotateNumber()
    }
    
    /* 전화걸기 */
    @IBAction func call(_ sender: Any) {
        guard var dialNumber = self.lblNumber.text else { return }
        
        var countryCode = vm.selectNation.countryCode
        let telecomNumber = self.lblTelecomNumber.text
        var countryNumber = self.lblPrefix.text?.replacingOccurrences(of: "+", with: "")
        
        if dialNumber.isEmpty {
            Localized.toast_empty_tel.txt.showErrorMsg(target: self.view)
            return
        }
        
        var isKorean = false
        
        if countryCode == "kr" {
            countryNumber = "82"
            let tempDialNumber = dialNumber
            
            if dialNumber.hasPrefix("00") {
                if dialNumber.hasPrefix("001") ||
                    dialNumber.hasPrefix("002") ||
                    dialNumber.hasPrefix("005") ||
                    dialNumber.hasPrefix("006") ||
                    dialNumber.hasPrefix("008") ||
                    dialNumber.hasPrefix("009") {
                    dialNumber = StringUtils.subString(dialNumber, startIdx: 3, endIdx: dialNumber.count - 3)
                } else {
                    if dialNumber.hasPrefix("003") || dialNumber.hasPrefix("007") {
                        if dialNumber.count >= 5 {
                            dialNumber = StringUtils.subString(dialNumber, startIdx: 5, endIdx: dialNumber.count - 5)
                        }
                    } else {
                        isKorean = true
                    }
                }
            } else {
                if dialNumber.hasPrefix("+") ||
                    dialNumber.hasPrefix("1") ||
                    dialNumber.hasPrefix("2") ||
                    dialNumber.hasPrefix("3") ||
                    dialNumber.hasPrefix("4") ||
                    dialNumber.hasPrefix("5") ||
                    dialNumber.hasPrefix("6") ||
                    dialNumber.hasPrefix("7") ||
                    dialNumber.hasPrefix("8") ||
                    dialNumber.hasPrefix("9") {
                    dialNumber = dialNumber.replacingOccurrences(of: "+", with: "")
                } else {
                    dialNumber = tempDialNumber
                    isKorean = true
                }
            }
            
            if dialNumber.count > 16 || dialNumber.count < 9 {
                dialNumber = tempDialNumber.replacingOccurrences(of: "+", with: "")
                isKorean = true
            }
            
            if !isKorean {
                if !dialNumber.hasPrefix("0") {
                    //해외전화이기 때문에 앞에 국제번호를 찾는다.
                    let tempDialNumber = dialNumber // 임시 번호
                    if dialNumber.count > 3 {
                        for idx in (0...4).reversed() {
                            if DBListManager.getNationCorrect(StringUtils.subString(dialNumber, startIdx: 0, endIdx: idx))
                                && StringUtils.subString(dialNumber, startIdx: idx, endIdx: dialNumber.count - 4).count >= 5
                                && dialNumber.count >= idx {
                                countryNumber = StringUtils.subString(dialNumber, startIdx: 0, endIdx: idx)
                                countryCode = DBListManager.getNationCode(countryNumber)
                                dialNumber = StringUtils.subString(dialNumber, startIdx: idx, endIdx: dialNumber.count - idx)
                                break
                            }
                        }
                        
                        if countryCode == "us" {
                            let cc = StringUtils.checkUSAorCanada(tempDialNumber)
                            if cc == "ca" {
                                countryNumber = StringUtils.getCanadaPrefix(tempDialNumber)
                                countryCode = cc
                                dialNumber = StringUtils.subString(tempDialNumber, startIdx: 4, endIdx: tempDialNumber.count - 4)
                            }
                        }
                    }
                }
            }
        }
        
        // 번호 저장
        if let code = countryCode, var mvno = countryNumber, let inter = telecomNumber  {
            
            var no = dialNumber
            
            if code == "ca" && mvno != "1" {
                mvno.remove(at: mvno.startIndex)
                no = "\(mvno)\(dialNumber)"
                mvno = "1"
            }
            
            UserDefaultsManager.shared.saveInternationalCallISO2(value: code)
            Utils.saveCalledNumber(ctn: no, code: code, mvno: mvno, inter: inter)
            updateDial(new: no)
            
            
            let serviceCode = vm.getServiceCode(cc: code, dial: dialNumber, isKorean: isKorean)
            
            // 전화 걸기
            if serviceCode == TELECOM.CODE_080 {
                var callNumber = ""
                if countryNumber == "82" {
                    callNumber = "\(vm.currentType.number080),\(dialNumber)#"
                } else {
                    callNumber = "\(vm.currentType.number080),\(countryNumber ?? "")\(dialNumber)#"
                }
                Utils.callTel(callNumber)
            } else {
                var callNumber = ""
                if countryNumber == "82" {
                    callNumber = "\(serviceCode)\(dialNumber)"
                } else {
                    callNumber = "\(serviceCode)\(countryNumber ?? "")\(dialNumber)"
                }
                Utils.callTel(callNumber)
            }
        }
    }
}
