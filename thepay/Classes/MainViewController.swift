//
//  MainViewController.swift
//  thepay
//
//  Created by xeozin on 2020/06/26.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class MainViewController: TPBaseViewController, TPLocalizedController {
    
    // Unwind Segue
    @IBAction func unwindMain(_ unwindSegue: UIStoryboardSegue) { }
    // Unwind Segue END
    
    @IBOutlet weak var lblUserId: TPLabel!
    @IBOutlet weak var lblPhoneNumber: TPLabel!
    
    @IBOutlet weak var lblCashTitle: TPLabel!
    @IBOutlet weak var lblPointTitle: TPLabel!
    @IBOutlet weak var lblCash: TPLabel!
    @IBOutlet weak var lblPoint: TPLabel!
    
    @IBOutlet weak var imgRefresh: UIImageView!
    @IBOutlet weak var loBottomAdHeight: NSLayoutConstraint!
    
    // Money Bar Property
    @IBOutlet weak var leftGageBackground: UIView!
    @IBOutlet weak var leftGageTrailing: NSLayoutConstraint!
    @IBOutlet weak var leftGageForeground: UIView!
    
    @IBOutlet weak var rightGageBackground: UIView!
    @IBOutlet weak var rightGageTrailing: NSLayoutConstraint!
    @IBOutlet weak var rightGageForeground: UIView!
    
    @IBOutlet var slideshow: ImageSlideshow!
    @IBOutlet weak var ivLoginType: UIImageView!
    
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var shortMenu: DynamicMainMenu!
    
    
    var vm = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        App.shared.isRemainsInfoChanged = true
        removeIntro()
        addEvents()
        drawBottomAd()
        
        if App.shared.codeLang == .CodeLangMMR || App.shared.codeLang == .CodeLangMMY {
            let r = tableViewHeader.frame
            tableViewHeader.frame = CGRect(x: 0, y: 0, width: r.width, height: r.height + 8 )
        }
        
        shortMenu.updateDisplay(menuList: App.shared.pre?.O_DATA?.hotKeyList)
    }
    
    func localize() {
        setupNavigationBar(type: .main)
        lblCashTitle.text = Localized.com_my_cash.txt
        lblPointTitle.text = "ⓟ \(Localized.com_my_point.txt)"
        lblPhoneNumber.text = vm.ani
        lblUserId.text = vm.email
        ivLoginType.image = vm.getLoginTypeImage()
        self.tableView.addTopBounceAreaView(color: UIColor(named: "Primary") ?? .white)
//        lblCharge.text = Localized.title_hotkey_cash_recharge.txt
//        lblHistory.text = Localized.title_hotkey_recharge_history.txt
//        lblAccount.text = Localized.title_hotkey_my_bank_account.txt
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if App.shared.isRemainsInfoChanged {
            self.requestRemains()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSideMenu()
        checkPush()
    }
    
    private func checkPush() {
        if App.shared.hasPushInfo {
            NotificationCenter.default.post(name: ThePayNotification.Push.name, object: nil)
        } else {
            if let link = App.shared.moveLink {
                if !link.isEmpty {
                    SegueUtils.parseMoveLink(target: self, link: link)
                    App.shared.moveLink = ""
                }
            }
        }
    }
    
    private func removeIntro() {
        self.navigationController?.setViewControllers([self], animated: true)
    }
    
    private func setupSideMenu() {
        if let nav = self.navigationController as? ENSideMenuNavigationController {
            if nav.sideMenu == nil {
                guard let win = UIWindow.key else { return }
                if (NSClassFromString("UIVisualEffectView") != nil) {
                    // Add blur view
                    
                    vm.visualEffectView.frame = win.bounds
                    vm.visualEffectView.backgroundColor = .black
                    vm.visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    vm.visualEffectView.alpha = 0
                    if(vm.tapOutsideRecognizer == nil) {
                        vm.tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBehind))
                        vm.tapOutsideRecognizer.numberOfTapsRequired = 1
                        vm.tapOutsideRecognizer.cancelsTouchesInView = false
                        vm.tapOutsideRecognizer.delegate = self
                        vm.visualEffectView.addGestureRecognizer(vm.tapOutsideRecognizer)
                    }
                    
                    win.addSubview(vm.visualEffectView)
                }
                let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
                guard let menu = menuStoryboard.instantiateViewController(withIdentifier: "Menu") as? MenuViewController else { return }
                nav.sideMenu = ENSideMenu(sourceView: win, menuViewController: menu, menuPosition: .left, blurStyle: .dark)
                nav.sideMenu?.menuWidth = self.view.frame.width - 80
                nav.sideMenu?.bouncingEnabled = false
                nav.sideMenu?.delegate = self
                nav.sideMenu?.updateFrame()
                
                menu.didTapMenu = { [weak self] moveLink in
                    guard let self = self else { return }
                    
                    nav.sideMenu?.toggleMenu()
                    
                    if moveLink == "debug" {
                        self.vm.visualEffectView.alpha = 0.0
                        App.shared.selectedServer = false
                        App.shared.intro = .update
                        self.navigationController?.backToIntro()
                    }
                    
                    SegueUtils.parseMoveLink(target: self, link: moveLink)
                }
            }
        }
    }
    
    // MARK: - Gesture methods to dismiss this with tap outside
    @objc func handleTapBehind(sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            if let nav = self.navigationController as? ENSideMenuNavigationController {
                nav.sideMenu?.toggleMenu()
            }
        }
    }
    
    private func addEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(requestRemains), name: ThePayNotification.RequestRemains.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNotification), name: ThePayNotification.Push.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDeeplinkPage), name: ThePayNotification.DeepLink.name, object: nil)
    }
    
    @objc private func showNotification() {
        App.shared.hasPushInfo = false
        performSegue(withIdentifier: "Push", sender: nil)
    }
    
    @objc private func showDeeplinkPage() {
        if let deep = App.shared.deeplink {
            SegueUtils.parseMoveLink(target: self, link: deep)
        }
    }
    
    // 상태 업데이트
    @objc private func requestRemains() {
        
        UIView.animate(withDuration: 1.5) {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.duration = 1.5
            self.imgRefresh.layer.add(rotateAnimation, forKey: nil)
        }
        
        let req = RemainsRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RemainsResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print(data)
                App.shared.isRemainsInfoChanged = false
                Utils.updateRemains(data: data)
                self.lblCash.text = "\(data.O_DATA?.cash ?? 0)".currency.won
                self.lblPoint.text = "\(data.O_DATA?.point ?? 0)".currency.point
                self.drawGage(data: data.O_DATA)
                // TODO: updateRemainInfo
            case .failure(let error):
                
                // .timeout 에러에 대해서 예외처리 (아무 동작 안함)
                error.processError(target: self, type: .remain)
            }
        }
    }
    
    /**
     *  게이지 처리
     */
    private func drawGage(data: RemainsResponse.O_DATA?) {
        guard let d = data else { return }
        
        ganerateGage(currentMoney: CGFloat(d.cash ?? 0), maxMoney: 50000, constraint: leftGageTrailing, view: leftGageBackground)
        ganerateGage(currentMoney: CGFloat(d.point ?? 0), maxMoney: 20000, constraint: rightGageTrailing, view: rightGageBackground)
    }
    
    private func ganerateGage(currentMoney: CGFloat, maxMoney: CGFloat, constraint: NSLayoutConstraint, view: UIView) {
        let rate: CGFloat = currentMoney / maxMoney
        let width: CGFloat = view.frame.size.width
        var gageSize: CGFloat = width * rate
        
        if gageSize > width {
            gageSize = width
        }
        
        constraint.constant = width
        view.layoutIfNeeded()
        
        // usingSpringWithDamping: 0.5, initialSpringVelocity: 2,
        UIView.animate(withDuration: 1.75, delay: 0, options: .curveEaseInOut, animations: {
            constraint.constant = width - gageSize
            view.layoutIfNeeded()
        }) { _ in
            // complete
        }
    }
    
    /**
     *  하단 광고 처리
     */
    func drawBottomAd() {
        if let ad = App.shared.pre?.O_DATA?.adverTise {
            if ad.count == 0 {
                self.loBottomAdHeight.constant = 0
                return
            }
            
            for imageInfo in ad {
                if let urlString = imageInfo.adverImgUrl, let source = KingfisherSource(urlString: urlString) {
                    vm.kingfisherSource.append(source)
                }
            }
            
            // 배너 속도
            if let bannerInterval = App.shared.pre?.O_DATA?.bannerInterval {
                let intervalString: String = bannerInterval
                let convert: Double = Double(intervalString) ?? 0
                let interval: Double = convert / 1000
                
                slideshow.slideshowInterval = interval
            }
            
            slideshow.contentScaleMode = UIViewContentMode.scaleToFill

            let pageControl = UIPageControl()
            pageControl.currentPageIndicatorTintColor = UIColor(rgb: 0xC9C9C9)
            pageControl.pageIndicatorTintColor = UIColor(rgb: 0xE4E4E4)
            slideshow.pageIndicator = pageControl
            slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
            slideshow.activityIndicator = DefaultActivityIndicator()
            slideshow.setImageInputs(vm.kingfisherSource)

            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
            slideshow.addGestureRecognizer(recognizer)
        } else {
            self.loBottomAdHeight.constant = 0
        }
    }
    
    @objc func didTap() {
        guard let ad = App.shared.pre?.O_DATA?.adverTise else { return }
        guard let link = ad[slideshow.currentPage].adverLinkUrl else { return }
        SegueUtils.parseMoveLink(target: self, link: link, title: ad[slideshow.currentPage].adverTitle)
    }

    override func leftMenu() {
        if let nav = self.navigationController as? ENSideMenuNavigationController {
            nav.sideMenu?.toggleMenu()
        }
    }
    
    override func rightMenu() {
        let menuData = App.shared.pre?.O_DATA?.toggleMenuList
        let contactList = menuData?.filter() { $0.iconImg == "ic_toggle_contactus" }
        if let mLink = contactList?.last?.moveLink {
            SegueUtils.parseMoveLink(target: self, link: mLink)
        } else {
            SegueUtils.openMenu(target: self, link: .contactus)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? MenuViewController {
            vc.didTapMenu = { [weak self] moveLink in
                guard let self = self else { return }
                if moveLink == "debug" {
                    App.shared.selectedServer = false
                    App.shared.intro = .update
                    self.navigationController?.backToIntro()
                }
                SegueUtils.parseMoveLink(target: self, link: moveLink)
            }
            vc.transitioningDelegate = self
        }
        
        if let vc = segue.destination as? PushViewController {
            vc.pushDismiss = { moveLink in
                App.shared.moveLink = moveLink
                if UIApplication.topViewController() != self {
                    self.navigationController?.popToRootViewController(animated: false)
                } else {
                    self.checkPush()
                }
            }
        }
    }
    @IBAction func showProfile(_ sender: Any) {
        SegueUtils.openMenu(target: self, link: .myinfo)
    }
    
    @IBAction func refreshCash(_ sender: Any) {
        vm.timer?.invalidate()
        vm.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] t in
            self?.requestRemains()
        })
    }
    
    // 충전
    @IBAction func moveCharge(_ sender: Any) {
        let key = App.shared.pre?.O_DATA?.hotKeyList?[0]
        if let mLink = key?.moveLink {
            SegueUtils.parseMoveLink(target: self, link: mLink)
        }
    }
    
    @IBAction func moveHistory(_ sender: Any) {
        let key = App.shared.pre?.O_DATA?.hotKeyList?[1]
        if let mLink = key?.moveLink {
            SegueUtils.parseMoveLink(target: self, link: mLink)
        }
    }
    
    @IBAction func moveAccount(_ sender: Any) {
        let key = App.shared.pre?.O_DATA?.hotKeyList?[2]
        if let mLink = key?.moveLink {
            SegueUtils.parseMoveLink(target: self, link: mLink)
        }
    }
    
    @IBAction func moveDialer(_ sender: Any) {
        SegueUtils.openMenu(target: self, link: .dialer)
    }
    
    private func requestRechargePreview() {
        let requestAPI = RequestAPI()
        let param = RechargePreviewRequest.Param(opCode: "CASH",
                                                 rcgType: "",
                                                 ctn: requestAPI.ani,
                                                 mvnoId: "",
                                                 rcgAmt: "",
                                                 userCash: "",
                                                 userPoint: "",
                                                 payAmt: "")
        let req = RechargePreviewRequest(param: param)
        self.showLoadingWindow()
        vm.canOpenSideMenu = false
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RechargePreviewResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                App.shared.easyPayFlag = data.O_DATA?.easyPayFlag == "Y" ? true : false
                
                UserDefaultsManager.shared.saveCreditBillType(value: data.O_DATA?.O_CREDIT_BILL_TYPE)
                
                guard let OCHARGEFLAG = OCHARGEFLAG(rawValue: data.O_DATA?.O_CHARGE_FLAG?.lowercased() ?? "") else { return }
                switch OCHARGEFLAG {
                case .y:
                    guard let OCREDITBILLTYPE = OCREDITBILLTYPE(rawValue: data.O_DATA?.O_CREDIT_BILL_TYPE ?? "") else { return }
                    guard let data = data.O_DATA else { return }
                    switch OCREDITBILLTYPE {
                    case .Bill_11, .Bill_12:
                        let pgInfo = PGInfo(pgID: data.O_PG_ID,
                                            amount: 0,
                                            rechargeAmount: 0,
                                            rcgSeq: data.O_RCG_SEQ,
                                            opCode: data.O_OP_CODE,
                                            rcgType: "",
                                            ctn: requestAPI.ani,
                                            notiContent: data.O_NOTIECE_CONTENT,
                                            oderNum: data.O_ORDERNUM,
                                            btype: data.O_CREDIT_BILL_TYPE)
                        SegueUtils.openMenu(target: self, link: .pgwebview, params: ["pgInfo":pgInfo])
                    case .Bill_13, .Bill_18:
                        SegueUtils.openMenu(target: self, link: .cash)
                    }
                case .n:
                    guard let html = data.O_DATA?.O_NOTIECE_CONTENT else { return }
                    self.showConfirmHTMLAlert(title: nil, htmlString: html)
                }
                self.vm.canOpenSideMenu = true
                self.hideLoadingWindow()
            case .failure(let error):
                self.vm.canOpenSideMenu = true
                self.hideLoadingWindow()
                
                // .e1087 번호 에러에 대해서 예외처리
                error.processError(target: self, type: .recharge_preview)
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.mergedMenuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainMenuCell", for: indexPath) as! MainCell
        cell.callback = {
//            print($0)
            SegueUtils.parseMoveLink(target: self, link: $0.moveLink ?? "", title:  $0.title ?? "")
        }
        cell.data = vm.mergedMenuData[indexPath.row]
        return cell
    }
}


class MainCell: UITableViewCell {
    
    @IBOutlet weak var lblLeftTitle: TPLabel!
    @IBOutlet weak var lblRightTitle: TPLabel!
    @IBOutlet weak var ivLeft: UIImageView!
    @IBOutlet weak var ivRight: UIImageView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    @IBOutlet weak var viewLeft: UIView!
    @IBOutlet weak var viewRight: UIView!
    
    var callback: ((PreloadingResponse.mainMenuList)->())?
    
    var data: MainViewModel.MainMenu? {
        didSet {
            if let ld = data?.left {
                if let iconImg = ld.iconImg {
                    ivLeft.image = UIImage(named: iconImg)
                }
                lblLeftTitle.text = ld.title
            }
            
            if let rd = data?.right {
                if let iconImg = rd.iconImg {
                    ivRight.image = UIImage(named: iconImg)
                }
                lblRightTitle.text = rd.title
                viewRight.backgroundColor = .white
                btnRight.isUserInteractionEnabled = true
            } else {
                ivRight.image = nil
                lblRightTitle.text = ""
                viewRight.backgroundColor = .clear
                btnRight.isUserInteractionEnabled = false
            }
            
            switch App.shared.codeLang {
            case .CodeLangMMR, .CodeLangMMY:
                viewRight.isHidden = true
            default:
                viewRight.isHidden = false
            }
        }
    }
    
    @IBAction func pressLeftButton(_ sender: Any) {
        guard let ld = data?.left else { return }
        guard let _ = ld.moveLink else { return }
        callback?(ld)
    }
    
    @IBAction func pressRightButton(_ sender: Any) {
        guard let rd = data?.right else { return }
        guard let _ = rd.moveLink else { return }
        callback?(rd)
    }
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        vm.transition.isPresenting = true
        return vm.transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        vm.transition.isPresenting = false
        return vm.transition
    }
}

extension MainViewController : ENSideMenuDelegate {
    func sideMenuShouldOpenSideMenu() -> Bool {
        if self.navigationController?.topViewController == self {
            return true && vm.canOpenSideMenu
        } else {
            return false
        }
    }
    
    func sideMenuDidOpen() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.vm.visualEffectView.alpha = 0.6
        }
    }
    
    func sideMenuDidClose() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.vm.visualEffectView.alpha = 0.0
        }
    }
    
    func sideHandle(p: CGFloat) {
        var per = p / self.view.frame.width
        if per < 0 {
            return
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            if per > 0.6 {
                per = 0.6
            }
            self?.vm.visualEffectView.alpha = per
        }
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
