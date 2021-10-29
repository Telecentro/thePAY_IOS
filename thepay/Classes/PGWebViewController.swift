//
//  PGWebViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/28.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import WebKit

class PGWebViewController: TPBaseViewController, TPLocalizedController {
    let WEBAES256 = "69dxuq22lxkm5abaisfv3e4dag50k56n"
    var webView: WKWebView!
    var titleString: String?
    var urlString: String?
    
    var sendNamesArr:[String] = []
    let btn = UIButton()
    
    var from: ChargeFrom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        addNotifications()
        createWKWebView()
        updateLayout()
        parseData()
        requestPage()
        createFakeButton()
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(callbackPayment), name: NSNotification.Name("callbackPayment"), object: nil)
    }
    
    @objc private func callbackPayment() {
        webView.evaluateJavaScript("callbackPayment()", completionHandler: nil)
    }
        
    
    func localize() {
        self.setupNavigationBar(type: .basic(title: Localized.title_activity_payment_card_pg.txt))
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
        let controller = WKUserContentController()
        
        controller.add(self, name: "callbackHandler")
        config.userContentController = controller
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.view.addSubview(self.webView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        btn.removeFromSuperview()
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
    
    
    private func createBackButton() {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 21))
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
        self.navigationController?.popViewController(animated: true)
    }
    
    func parseData() {
        print(self.params ?? "NODATA")
        
        guard let pgInfo = self.params?["pgInfo"] as? PGInfo else { return }
        
        guard let pgID = pgInfo.pgID else { return }
        guard let amount = pgInfo.amount else { return }
        guard let rechargeAmount = pgInfo.rechargeAmount else { return }
        guard let rcgSeq = pgInfo.rcgSeq else { return }
        guard let opCode = pgInfo.opCode else { return }
        guard let rcgType = pgInfo.rcgType else { return }
        guard let ctn = pgInfo.ctn else { return }
        guard let notiContent = pgInfo.notiContent else { return } // TODO: mNotiContent = mNotiContent.length == 0 ? @"" : mNotiContent ;
        guard let oderNum = pgInfo.oderNum else { return }
        guard let btype = pgInfo.btype else { return }
        
        let req = RequestAPI()
        
        let param = "\(Key.pinNumber)=\(req.pinNumber)&\(Key.CTN)=\(ctn)&\(Key.USER_ID)=\(req.uuid)&\(Key.LANG)=\(req.langCode)&\(Key.SESSION_ID)=\(req.sessionId)&\(Key.ENC_DATE)=\(req.enc_date)&\(Key.OS)=IOS&\(Key.appType)=thePay&\(Key.ANI)=\(req.ani)&\(Key.opCode)=\(opCode)&\(Key.rcgSeq)=\(rcgSeq)&\(Key.rcgType)=\(rcgType)&\(Key.rcgAmt)=\(rechargeAmount)&\(Key.payAmt)=\(amount)&\(Key.CREDIT_BILL_TYPE)=\(btype)&\(Key.ORDERNUM)=\(oderNum)&\(Key.PG_ID)=\(pgID)&\(Key.noticeContents)=\(notiContent)"
        
        let chiperText = AES256.encryptionAES256WithKey(str: param, key: WEBAES256)
        let safeChars = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrtuvwxyz0123456789/=")
        let encodeString = chiperText.addingPercentEncoding(withAllowedCharacters: safeChars)
        
        guard let p = encodeString else { return }
        
        if pgInfo.pgID == "DAOU" {
            urlString = "\(API.shared.serviceURL.payment_daou)?param=\(p)"
        } else {
            urlString = "\(API.shared.serviceURL.payment_inicis)?param=\(p)"
        }
        
    }
    
    func requestPage() {
        guard let urlString = self.urlString else { return }
        if let url = URL(string: urlString) {
            let req = URLRequest(url: url)
            self.webView?.load(req)
        }
    }
}


extension PGWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("🟢 \(message.body), \(message.name)")
        
        if let functionString = message.body as? String {
            var f:String = functionString
            f = f.replacingOccurrences(of: "(", with: ":")
            f = f.replacingOccurrences(of: ")", with: "")
            f = f.replacingOccurrences(of: ",", with: ":")
            
            print("function \(f)")
            
            // weixin://
            let sendArr = f.components(separatedBy: ":")
            
            if sendArr.count == 0 {
                return
            }
            
            sendNamesArr = sendArr
            
            if let function = sendArr[exist: 0] {
                let selector = NSSelectorFromString(function)
                if self.canPerformAction(selector, withSender: nil) {
                    self.performSelector(onMainThread: selector, with: nil, waitUntilDone: true)
                }
            }
        }
    }
    
    @objc private func goToWeChat() {
        if let url = URL(string: "weixin://"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            if let itunesURL = sendNamesArr[exist: 1] {
                SegueUtils.openURL(urlString: "https://\(itunesURL)")
            }
        }
    }
}

/**
 *  WKUIDelegate
 */
extension PGWebViewController : WKUIDelegate {
    
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

extension PGWebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.evaluateJavaScript("document.querySelector('meta[name=viewport]').setAttribute('content', 'width=\(webView.frame.size.width),initial-scale=1.0, maximum-scale=1.0, user-scalable=no;', false); ", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        print("🌐 webView load Url \(urlString)")
        
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            if urlString.contains("itunes.apple.com") {
                SegueUtils.openLink(link: urlString)
                decisionHandler(.allow)
            } else {
                decisionHandler(.allow)
            }
        } else {
            guard let moveLink = URL(string: urlString) else { return }
            guard let scheme = moveLink.scheme else { return }
            
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
    
    // 중국 타이틀 설정 2020.10.20
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? TPBaseViewController {
            vc.title = self.title
        }
    }
}
