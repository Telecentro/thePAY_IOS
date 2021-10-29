//
//  PushViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/12.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import WebKit

class PushViewController: TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txView: UITextView!
    @IBOutlet weak var viewContainer: UIView!
    
    var webView: WKWebView!
    var moveLink: String = ""
    
    var pushDismiss: ((String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.request()
    }
    
    func initialize() {
        createWKWebView()
        updateLayout()
    }
    
    
    func createWKWebView() {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        controller.add(self, name: "callbackHandler")
        config.userContentController = controller
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.viewContainer.addSubview(self.webView)
    }
    
    
    private func updateLayout() {
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor).isActive = true
        self.webView.topAnchor.constraint(equalTo: viewContainer.topAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor).isActive = true
    }
    
    func localize() {
        btnConfirm.setTitle(Localized.btn_recharge.txt, for: .normal)
        btnCancel.setTitle(Localized.btn_confirm.txt, for: .normal)
    }
    
    @IBAction func confirm(_ sender: Any) {
        App.shared.moveLink = self.moveLink
        
        self.dismiss(animated: true) { [weak self] in
            self?.pushDismiss?(self?.moveLink ?? "")
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true) { }
    }
    
    private func request() {
        guard let seq = App.shared.userInfo?["push_seq"] as? String else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        self.showLoadingWindow()
        let req = PushReviewRequest(seq: seq)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<PushReviewResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.moveLink = data.O_DATA?.moveLink ?? ""
                self.setDataToView(data: data.O_DATA)
                self.btnConfirm.setTitle(data.O_DATA?.moveBtnTitle, for: .normal)
            case .failure:
                self.dismiss(animated: true)
            }
            
            self.hideLoadingWindow()
        }
        
        /* 초기화 */
        App.shared.userInfo = nil
    }
    
    private func setDataToView(data: PushReviewResponse.O_DATA?) {
        txView.isHidden = true
        viewContainer.isHidden = true
//        guard let token = data?.token else { return }
//        if token != UserDefaultsManager.shared.loadAPNSToken() {
//            request()
//        }
        
        lblTitle.text = data?.title
        
        switch data?.msgType {
        case "txt":
            viewContainer.isHidden = true
            txView.isHidden = false
            txView.text = data?.content
            txView.isUserInteractionEnabled = false
            txView.font = LanguageUtils.fontWithSize(size: 15)
        case "web":
            viewContainer.isHidden = true
            txView.isHidden = false
            txView.attributedText = data?.content?.convertHtml(fontSize: 17)
            txView.font = LanguageUtils.fontWithSize(size: 15)
//            txView.isUserInteractionEnabled = false
        default:
            break
        }
        
        if data?.msgBoxType == "1" {
            btnConfirm.isHidden = false
        } else {
            btnConfirm.isHidden = true
        }
        
        if !btnConfirm.isHidden {
            self.btnCancel.setTitle(Localized.btn_cancel.txt, for: .normal)
        }
    }
}


/**
 *  WKUIDelegate
 */
extension PushViewController : WKUIDelegate {
    
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




extension PushViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        webView.evaluateJavaScript("document.body.style.fontFamily = 'Zawgyi-One'", completionHandler: nil)
        webView.evaluateJavaScript("document.body.style.fontSize = '15'", completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            if urlString.contains("itunes.apple.com") {
                SegueUtils.openURL(urlString: urlString)
                decisionHandler(.cancel)
            } else {
                SegueUtils.openURL(urlString: urlString)
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}


extension PushViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}

// 디버그 용
extension PushViewController {
    private func testHTML() {
        txView.isHidden = true
        viewContainer.isHidden = false
        let viewPort = "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1, user-scalable=0\">"
        let content = "<font color=\"blue\">[Recharge Failed]</font><br/></br>You selected a wrong monthly plan.<br/> </br>Please choose a correct monthly plan and recharge.<br/></br><font color=\"red\"> -> ￦39,600 </font><br/></br>For more information call your operator(Tel: 114).<a href=\"https://www.naver.com\">naver</a>"
        let html = "\(viewPort)\(content)"
        webView.loadHTMLString(html, baseURL: nil)
    }
}
