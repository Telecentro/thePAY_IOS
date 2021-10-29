//
//  WebViewController+BNB.swift
//  thepay
//
//  Created by seojin on 2021/01/08.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit
import AVFoundation

// 처음 한 번 안눌리는 현상
// TODO: 2021-01-13 18:08:41.105695+0900 thePAY[4240:1254496] [general] Connection to daemon was invalidated

extension WebViewController {
    enum BNB: String {
        case getCommonParams = "getCommonParams"
        case getEncParams = "getEncParams"
        case getCardNum = "getCardNum"
        case setCardNum = "setCardNum"
        case getContactList = "getContactList"
        case getChargeNumberHistory = "getChargeNumberHistory"
        case appRestart = "appRestart"
        case getImage = "getImage"
        case addChargeInfoHistory = "addChargeInfoHistory"
        case getChargeInfoHistory = "getChargeInfoHistory"
        case getSystemCall = "getSystemCall"
        case setWebViewTitle = "setWebViewTitle"
        case goToWebBrowser = "goToWebBrowser"
        case getEncDaouParams = "getEncDaouParams"
        case getBirthDate = "getBirthDate"
        case goToContact = "goToContact"
        
        var getFunction: String {
            return "\(self.rawValue)()"
        }
        
        func getParamString(body: String) -> String {
            let p = body.replacingOccurrences(of: self.rawValue, with: "").dropFirst().dropLast()
        
            return String(p)
        }
        
        var callBack: String? {
            switch self {
            case .getCommonParams:
                return "callbackCommonParams"
            case .getEncParams:
                return "callbackEncParams"
            case .getCardNum:
                return "callbackCardNum"
            case .getChargeNumberHistory:
                return "callbackChargeNumberHistory"
            case .getImage:
                return "callbackImage"
            case .getChargeInfoHistory:
                return "callbackChargeInfoHistory"
            case .getEncDaouParams:
                return "callbackEncDaouParams"
            case .getBirthDate:
                return "callbackBirthDate"
            case .goToContact:
                return "callbackContact"
            default:
                return nil
            }
        }
    }
    
    func parseBNBFunction(type: BNB?, body: String) {
        var p = ""
        guard let t = type else { return }
        if t.getFunction != body {
            p = type?.getParamString(body: body) ?? ""
        }
        switch t {
        case .getCommonParams:
            getCommonParams()
        case .getEncParams:
            getEncParams(param: p)
        case .appRestart:
            appRestart()
        case .getCardNum:
            getCardNum()
        case .setCardNum:
            setCardNum(param: p)
        case .setWebViewTitle:
            setWebViewTitle(param: p)
        case .getContactList:
            getContactList()
        case .getBirthDate:
            getBirthDate(param: p)
        case .goToContact:
            goToContact(param: p)
        case .addChargeInfoHistory:
            addChargeInfoHistory(param: p)
        case .getImage:
            getImage(param: p)
        case .getChargeNumberHistory:
            getChargeNumberHistory()
        case .getChargeInfoHistory:
            getChargeInfoHistory()
        case .getSystemCall:
            getSystemCall()
        case .goToWebBrowser:
            goToWebBrowser(param: p)
        case .getEncDaouParams:
            getEncDaouParams(param: p)
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func send(function: String, data: [String: Any?]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            if let param = String(bytes: jsonData, encoding: .utf8) {
                let javascript = "\(function)('\(param)')"
                self.webView?.evaluateJavaScript(javascript, completionHandler: nil)
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

extension WebViewController {
    
    /**
     *  연락처 가져오기 (폐기?)
     */
    private func getContactList() {
        // 처리
    }
    
    /**
     *  이전에 충전한 번호 리스트 - callBack
     */
    private func getChargeNumberHistory() {
        let transferData: [String: String] = [:]
        if let f = BNB.getChargeNumberHistory.callBack {
            send(function: f, data: transferData)
        }
    }
    
    /**
     *  카드번호 저장
     */
    private func setCardNum(param: String) {
        let dic = convertToDictionary(text: param)
        if let cardNum = dic?["cardNum"] as? String {
            if !cardNum.isEmpty {
                UserDefaultsManager.shared.saveRecentCardNumber(value: cardNum)
            }
        }
        
    }
    
    enum BNB_CAMERA_TYPE: String {
        case CREDIT_CARD_FRONT = "CREDIT_CARD_FRONT"
        case CREDIT_CARD_BACK = "CREDIT_CARD_BACK"
        case SELF_CAMERA = "SELF_CAMERA"
        
        case ALINE_CARD_FRONT = "ALINE_CARD_FRONT"
        case ALINE_CARD_BACK = "ALINE_CARD_BACK"
        case SIGNATURE = "SIGNATURE"
        case PASSPORT = "PASSPORT"
    }
    
    /**
     *  모듈별 카메라 호출 - callBack
     */
    private func getImage(param: String) {
        let dic = convertToDictionary(text: param)
        if let id = dic?["id"] as? String, let type = BNB_CAMERA_TYPE(rawValue: id) {
            switch type {
            case .CREDIT_CARD_FRONT:
                showCamera(type: .creditCardFront)
            case .CREDIT_CARD_BACK:
                showCamera(type: .creditCardBack)
            case .ALINE_CARD_FRONT:
                showCamera(type: .alienCardFront)
            case .ALINE_CARD_BACK:
                showCamera(type: .alienCardBack)
            case .SELF_CAMERA:
                showCamera(type: .myFace)
            case .PASSPORT:
                showCamera(type: .passport)
            case .SIGNATURE:
                gotoSignature()
            }
        }
        
    }
    
    func getImageCallBack(type: CameraType?, image: UIImage) {
        guard let imgString = image.jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
        if let id = type?.bnbID {
            let transferData: [String: String] = ["id":id, "imageString":imgString]
            if let f = BNB.getImage.callBack {
                send(function: f, data: transferData)
            }
        } else {
            let transferData: [String: String] = ["id":"SIGNATURE", "imageString":imgString]
            if let f = BNB.getImage.callBack {
                send(function: f, data: transferData)
            }
        }
    }
    
    //    xeozin 2020/09/26 reason: 카메라 권한 로직 추가
    func showCamera(type: CameraType) {
        currentCameraType = type
        
        let permission = CameraPermission()
        permission.showCamera {
            performSegue(withIdentifier: CameraPermission.cameraSegue, sender: nil)
        } denied: {
            permission.showCameraPermissionAlert(vc: self)
        } notDetermined: {
            self.performSegue(withIdentifier: CameraPermission.cameraSegue, sender: nil)
        }
    }
    
    // TODO: 클라이언트 확인 필요
    
    /**
     *  생년월일 팝업창 - callBack
     */
    private func getBirthDate(param: String) {
        let dic = convertToDictionary(text: param)
        if let birthDate = dic?["birthDate"] as? String {
            if birthDate == "" {
                print("Empty Field")
            } else {
                print("Previous Select Date : \(birthDate)")
            }
            
            let sb = UIStoryboard(name: "PopUp", bundle: nil)
            guard let vc = sb.instantiateViewController(withIdentifier: "BirthViewController") as? BirthViewController else { return }
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: currentCameraType)
            }
        }
        
        
        if let vc = segue.destination as? AddressViewController {
            if let params = sender as? [String:String], let code = params["countryCode"] {
                if code == "" {
                    vc.currentType = .recent
                    vc.addressBookType = .rechargeHistory
                } else {
                    vc.currentType = .recent
                    vc.addressBookType = .eloadCallHistory
                    vc.selectNationCode = code
                }
            }
            
            vc.item = { [weak self] contact in
                guard let number = contact.callNumber else { return }
                let transferData: [String: String] = ["seletedNumber":number]
                if let f = BNB.goToContact.callBack {
                    self?.send(function: f, data: transferData)
                }
            }
        }
    }
    
    
    /**
     *  앱 내 연락처 화면 사용 - callBack
     */
    private func goToContact(param: String) {
        let dic = convertToDictionary(text: param)
        Utils.getContactPermissions(vc: self, segue: "goContact", sender: dic)
    }
    
    
    /**
     *  앱에 저장된 카드번호 가져오기 - callBack
     */
    private func getCardNum() {
        guard let cardNumber = UserDefaultsManager.shared.loadRecentCardNumber() else { return }
        let transferData: [String: String] = ["cardNum":cardNumber]
        if let f = BNB.getCardNum.callBack {
            send(function: f, data: transferData)
        }
    }
    
    /**
     *  공통 파라미터 전달 - callBack
     */
    private func getCommonParams() {
        //        print("🏄🏼‍♂️ getCommonParams()")
        let req = RequestAPI()
        let transferData: [String: String] = [
            Key.ANI: req.ani,
            Key.USER_ID: req.uuid,
            Key.pinNumber: req.pinNumber,
            Key.LANG: req.langCode,
            Key.TELCOM: req.telecom,
            Key.MODEL: req.model,
            Key.OS: req.os,
            Key.OS_LANG: req.os_lang,
            Key.IMSI: "",
            Key.Preloading.IMEI: req.localUUID,
            Key.APP_VER: req.appver,
            Key.SESSION_ID: req.sessionId
        ]
        
        if let f = BNB.getCommonParams.callBack {
            send(function: f, data: transferData)
        }
    }
    
    /**
     *  각종 암호화 값 암호화 처리 - callBack
     */
    private func getEncParams(param: String) {
        //        guard let dic = convertToDictionary(text: param) else { return }
        //        print("🏄🏼‍♂️ getEncParams() \(param) \(dic)")
        let req = RequestAPI()
        let transferData = [
            Key.AES256: req.aes256Value,
            Key.ENC_DATE: req.enc_date
        ]
        
        if let f = BNB.getEncParams.callBack {
            send(function: f, data: transferData)
        }
    }
    
    /**
     *  상단 타이틀
     */
    private func setWebViewTitle(param: String) {
        if let dic = convertToDictionary(text: param) as? [String:String], let title = dic["title"] {
            if !title.isEmpty {
                self.setupNavigationBar(type: .basic(title: title))
            }
        }
    }
    
    /**
     *  앱 재시작
     */
    private func appRestart() {
        self.navigationController?.backToIntro()
    }
}

extension WebViewController {
    
    /**
     *  충전하는 번호 리스트 추가
     */
    private func addChargeNumberHistory(param: String) {
        print("addChargeNumberHistory \(param)")
    }
    
    // {"ctn":"010-7121-7767","date":"20210120080750"}
    // {"ctn":"9775545","date":"20210120080825"}
    // {"ctn":"xeozin@naver.com","date":"20210120080919"}
    /**
     *  충전 정보 히스토리 추가
     */
    private func addChargeInfoHistory(param: String) {
        print("addChargeInfoHistory \(param)")
    }
    
    
    /**
     *  충전 정보 히스토리 가져오기 - callBack
     */
    private func getChargeInfoHistory() {
        let transferData: [String: String] = [:]
        if let f = BNB.getChargeInfoHistory.callBack {
            send(function: f, data: transferData)
        }
    }
    
    /**
     *  전화하기
     *  FAQ화면에서 전화하기 버튼 클릭시 네이티브 앱 전화기능 호출
     */
    private func getSystemCall() {
        // 처리
    }
    
    /**
     *  외부 브라우저 호출
     *  FAQ화면 SNS 연결 링크
     */
    private func goToWebBrowser(param: String) {
        // 처리
    }
    
    /**
     *  다우 웹 결제화면 파라미터 암호화 - callBack
     */
    private func getEncDaouParams(param: String) {
        let transferData: [String: String] = ["params":""]
        if let f = BNB.getEncDaouParams.callBack {
            send(function: f, data: transferData)
        }
    }
    
}

extension WebViewController: DateDelegate {
    func dateMessage(date: String) {
        let transferData: [String: String] = ["birthDate":date]
        if let f = BNB.getBirthDate.callBack {
            send(function: f, data: transferData)
        }
    }
}
