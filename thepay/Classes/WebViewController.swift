//
//  WebViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/22.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class WebViewController: TPBaseViewController, UIGestureRecognizerDelegate {
    enum WebLoad {
        case first
        case loaded
    }
    
    var webView: WKWebView!
    
    var titleString: String?
    var urlString: String?
    var contents: String?
    
    var sendNamesArr:[String] = []
    let btn = UIButton()
    
    var needFakeButton = true
    
    var currentCameraType:CameraType = .alienCardFront
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func requestCache() {
        self.urlString = API.shared.serviceURL.webCacheURL
        requestPage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        btn.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let params = self.params {
            self.titleString = params["adverTitle"] as? String
            self.urlString = params["url"] as? String
            self.contents = params["content"] as? String
        }
        
        if let t = titleString {
            self.setupNavigationBar(type: .basic(title: t))
        } else {
            self.setupNavigationBar(type: .basic(title: nil))
        }
        
        addNotifications()
        createWKWebView()
        updateLayout()
        requestPage()
        drawContents()
        if needFakeButton {
            createFakeButton()
        }
    }
    
    // 베트남 공지사항 드로잉
    private func drawContents() {
        if let content = self.contents {
            let items = content.components(separatedBy: "&")
            if items.count > 1 {
                var html = String(items[1][8...])
                html = html.replacingOccurrences(of: "\n", with: "")
                html = html.replacingOccurrences(of: "\"", with: "'")
                let width = UIScreen.main.bounds.size.width
                html = html.replacingOccurrences(of: "340px", with: "\(width)px")
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    private func createFakeButton() {
        guard let win = UIWindow.key else { return }
        let top = win.safeAreaInsets.top
        btn.frame = CGRect(x: 0, y: top, width: 50, height: 44)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        btn.backgroundColor = .clear
        win.addSubview(btn)
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUserCardInfo), name: NSNotification.Name("receiveUserCardInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUserCardInfo), name: NSNotification.Name("callbackPayment"), object: nil)
    }
    
    @objc func receiveUserCardInfo() {
        
    }
    
    @objc func callbackPayment() {
        
    }
    
    private func updateLayout() {
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let safeArea = self.view.safeAreaLayoutGuide
            self.webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            self.webView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
            self.webView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            self.webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        } else {
            let margins = self.view.layoutMarginsGuide
            self.webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
            self.webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
            self.webView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
            self.webView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        }
    }
    
    func createWKWebView() {
        let config = WKWebViewConfiguration()
//        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
//        config.websiteDataStore.httpCookieStore.setCookie(<#T##cookie: HTTPCookie##HTTPCookie#>, completionHandler: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        let controller = WKUserContentController()
        
        controller.add(self, name: "callbackHandler")
        config.userContentController = controller
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.view.addSubview(self.webView)
    }
    
    private func createBackButton() {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        btn.setImage(UIImage(named: "btn_top_arrow.png"), for: .normal)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let backBtn = UIBarButtonItem(customView: btn)
        backBtn.title = ""
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc private func goBack() {
        webView.evaluateJavaScript("goBack('IOS')") { [weak self] result, error in
            guard let self = self else { return }
            if error != nil {
                if self.webView.canGoBack {
                    self.webView.goBack()
                } else {
                    self.finish()
                }
            }
        }
    }
    
    @objc private func finish() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func requestPage() {
        guard let urlString = self.urlString else { return }
        if let url = URL(string: urlString) {
            let req = URLRequest(url: url)
            self.webView?.load(req)
        }
    }
    
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("🟢 \(message.body), \(message.name)")
        
        if let functionString = message.body as? String {
            var f:String = functionString
            f = f.replacingOccurrences(of: "(", with: ":")
            f = f.replacingOccurrences(of: ")", with: "")
            f = f.replacingOccurrences(of: ",", with: ":")
            
//            print("function \(f)")
            
            let sendArr = f.components(separatedBy: ":")
            
            if sendArr.count == 0 {
                return
            }
            
            // BNB, 일반 웹뷰 구분
            if let bnb = BNB(rawValue: sendArr[0]) {
                self.parseBNBFunction(type: bnb, body: message.body as? String ?? "")
            } else {
                sendNamesArr = sendArr
                let selector = NSSelectorFromString(sendArr[0])
                if self.canPerformAction(selector, withSender: nil) {
                    self.performSelector(onMainThread: selector, with: nil, waitUntilDone: true)
                }
            }
        }
    }
    
    func checkCameraPermission() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == AVAuthorizationStatus.denied {
            let alert = UIAlertController(title: Localized.title_activity_notice.txt, message: "Check Your Camera", preferredStyle: .alert)
            let action = UIAlertAction(title: Localized.btn_confirm.txt, style: .default) { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        return status != AVAuthorizationStatus.denied
    }
    
    @objc private func CheckPermission() {
        if checkCameraPermission() {
            self.webView.evaluateJavaScript("javascript:callbackIdentification(\"Y\")", completionHandler: nil)
        }
    }
    
    // 이미지 스캔
    @objc private func gotoImageScanner() {
        if !checkCameraPermission() { return }
        let sb = UIStoryboard(name: "Camera", bundle: nil)
        if let nc = sb.instantiateViewController(withIdentifier: "CameraRoot") as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: .imageScan)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // 셀카
    @objc private func gotoSelfCamera() {
        if !checkCameraPermission() { return }
        let sb = UIStoryboard(name: "Camera", bundle: nil)
        if let nc = sb.instantiateViewController(withIdentifier: "CameraRoot") as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: .webFace)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // 카드 스캐너
    @objc private func gotoCardScanner() {
        if !checkCameraPermission() { return }
        let sb = UIStoryboard(name: "Camera", bundle: nil)
        if let nc = sb.instantiateViewController(withIdentifier: "CameraRoot") as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: .cardScan)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // 사인
    @objc func gotoSignature() {
        let sb = UIStoryboard(name: "Sign", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "SignView") as? SignViewController {
            vc.signType = .open
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // 결제
    @objc private func gotoPay() {
        var billType = UserDefaultsManager.shared.loadCreditBillType()
        if billType == "11" || billType == "12" {
            billType = "13"
        }
        
        let pgInfo = PayInfo(payType: .opening,
                             amount: Int(sendNamesArr[1]) ?? 0,
                             rechargeAmount: Int(sendNamesArr[2]) ?? 0,
                             rcgSeq: sendNamesArr[3],
                             opCode: sendNamesArr[4],
                             rcgType: sendNamesArr[5],
                             ctn: sendNamesArr[6],
                             notiContent: sendNamesArr[7],
                             btype: billType)
        
        SegueUtils.openMenu(target: self, link: .pay, params: ["payInfo":pgInfo])
    }
}

extension WebViewController : CaptureDelegate, SignDelegate {
    func signImage(image: UIImage) {
        sendImageCaller(image, type: nil, cardInfo: nil)
    }
    
    func sendImage(image: UIImage, type: CameraType?) {
        sendImageCaller(image, type: type, cardInfo: nil)
    }
    
    func sendImage(image: UIImage, type: CameraType?, cardInfo: SafeCardBeforeData.SafeCardInfo) {
        sendImageCaller(image, type: type, cardInfo: cardInfo)
    }
    
    private func sendImageCaller(_ image: UIImage, type: CameraType?, cardInfo: SafeCardBeforeData.SafeCardInfo?) {
        print(sendNamesArr)
        if hasID() {
            if let data = imageToData(image) {
                let funcCall = sendNamesArr[0].replacingOccurrences(of: "goto", with: "callback")
                let id = sendNamesArr[1]
                sendImageToJS(call: funcCall, id: id, pngData: data)
            }
        } else { // BNB : sendNamesArr [] 배열이 비어 있으면 BNB 호출로 판단
            getImageCallBack(type: type, image: image)
        }
    }
    
    private func hasID() -> Bool {
        return sendNamesArr.count > 1
    }
    
    private func sendImageToJS(call: String, id: String, pngData: Data) {
        
        /* 펑션 초기화 */
        sendNamesArr = []
        
        let fileStrings = pngData.base64EncodedString()
        let resultString = "data:image/png;base64,\(fileStrings)"
        let jsFunction = "\(call)(\"\(id)\",\"\(resultString)\");"
        
        webView.evaluateJavaScript(jsFunction)
    }
    
    private func imageToData(_ image: UIImage) -> Data? {
        let newSize = getImageSize(image: image)
        if isOverMaxSize(image: image) {
            UIGraphicsBeginImageContext(newSize)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let cpImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return cpImage?.pngData()
        } else {
            return image.pngData()
        }
    }
    
    private func isOverMaxSize(image: UIImage) -> Bool {
        let maxSize:CGFloat = 512
        if image.size.width > maxSize || image.size.height > maxSize {
            return true
        } else {
            return false
        }
    }
    
    
    private func getImageSize(image: UIImage) -> CGSize {
        let maxSize:CGFloat = 512
        var scale:CGFloat = 1
        
        if image.size.width > maxSize || image.size.height > maxSize {
            scale = image.size.width / maxSize
        } else {
            scale = image.size.height / maxSize
        }
        
        let w = image.size.width / scale
        let h = image.size.height / scale
        
        return CGSize(width: w, height: h)
    }
}

/**
 *  WKUIDelegate
 */
extension WebViewController : WKUIDelegate {
    
    // [ 확인 ]
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let completionHandlerWrapper = CompletionHandlerWrapper(completionHandler: completionHandler, defaultValue: ())
        
        let htmlMessage = message.convertHtml(fontSize: 17)
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(htmlMessage, forKey: "attributedTitle")
        let okAction = UIAlertAction(title: Localized.btn_confirm.txt, style: .default) { action in
            completionHandlerWrapper.respondHandler(())
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    // [ 확인 ] / [ 취소 ]
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let completionHandlerWrapper = CompletionHandlerWrapper(completionHandler: completionHandler, defaultValue: false)
        
        let htmlMessage = message.convertHtml(fontSize: 17)
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(htmlMessage, forKey: "attributedTitle")
        let okAction = UIAlertAction(title: Localized.btn_confirm.txt, style: .default) { action in
            completionHandlerWrapper.respondHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: Localized.btn_cancel.txt, style: .cancel) { action in
            completionHandlerWrapper.respondHandler(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    // [ 확인 ] / [ 취소 ] : 프롬프트
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let completionHandlerWrapper = CompletionHandlerWrapper(completionHandler: completionHandler, defaultValue: "")
        
        let htmlMessage = prompt.convertHtml(fontSize: 17)
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(htmlMessage, forKey: "attributedTitle")
        let okAction = UIAlertAction(title: Localized.btn_confirm.txt, style: .default) { action in
            let input = alert.textFields?.first?.text
            completionHandlerWrapper.respondHandler(input)
        }
        
        let cancelAction = UIAlertAction(title: Localized.btn_cancel.txt, style: .cancel) { action in
            completionHandlerWrapper.respondHandler(nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.showClearLoadingWindow()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hideLoadingWindow()
        self.webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoadingWindow()
        print("\(error)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
            // Redirected to browser. No need to open it locally
            print("🤩 webView load Url : \(urlString)")
//            SegueUtils.openURL(urlString: urlString)
            self.urlString = urlString
            requestPage()
            decisionHandler(.cancel)
            return
        } else {
            // Open it Locally
            print("🤓 webView load Url : \(urlString) \(navigationAction.navigationType.rawValue)")
        }
        
        print("🌐 webView load Url : \(urlString)")
        
        if App.shared.webCache == .cached {
            // 캐쉬 로드 화면이면 제거
            if urlString == API.shared.serviceURL.webCacheURL {
                self.view.removeFromSuperview()
                self.view.alpha = 1
            }
        }
        
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            if urlString.contains("itunes.apple.com") {
                SegueUtils.openURL(urlString: urlString)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else if navigationAction.request.url?.scheme == "tel" {
            SegueUtils.openURL(urlString: urlString)
            decisionHandler(.cancel)
        } else if urlString.hasPrefix("about:blank") {
            decisionHandler(.allow)
        } else {
            
            guard let moveLink = URL(string: urlString) else {
                decisionHandler(.allow)
                return
            }
            guard let scheme = moveLink.scheme else {
                decisionHandler(.allow)
                return
            }
            
            if urlString.hasPrefix("hanpassapp://") || urlString.hasPrefix("fb://") {
                guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                    self.timerBack()
                    decisionHandler(.cancel)
                    return
                }
                
                // 한패스 스키마 확인
                self.prev()
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            if scheme == "thepay" {
                let host = moveLink.host
                
                if host == "page.charge.pay" {
                    self.goToPayFromMoveLink(moveLink: moveLink)
                } else {
                    SegueUtils.parseMoveLink(target: self, link: urlString)
                }
            } else {
                SegueUtils.parseMoveLink(target: self, link: urlString)
            }
            
            decisionHandler(.cancel)
        }
    }
    
    // decidePolicyFor 에서 들어온 요청에 의한 결제 페이지 이동
    private func goToPayFromMoveLink(moveLink: URL) {
        if let params = moveLink.queryDictionary {
            let info = PayInfo(payType: .opening,
                               amount: Int(params["amount"] ?? "0"),
                               rechargeAmount: Int(params["recharge_amount"] ?? "0"),
                               rcgSeq: params["rcg_seq"],
                               opCode: params["op_code"],
                               rcgType: params["rcg_type"],
                               ctn: params["ctn"],
                               notiContent: params["noti_content"],
                               btype: params["bill_type"],
                               tabType: params["tab_type"] ?? "")
            SegueUtils.openMenu(target: self, link: .pay, params: ["payInfo":info])
        }
    }
    
    // 딜레이 Back
    private func timerBack() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.prev()
        }
    }
    
    // Back
    private func prev() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    
}
