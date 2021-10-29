//
//  ContactViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/10.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker

class ContactViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextView: TPDelegateTextView!
    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblFake: TPLabel!
    @IBOutlet weak var btnCover: TPButton!
    
    var messageId: Int = 10
    var viewHeight: CGFloat = 31
    var dataValue: ContactHistoryResponse?
    var tapGesture: UITapGestureRecognizer?
    
    var imageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.actionKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func localize() {
        self.inputTextView.attributedText = Utils.fontUpdate(text: inputTextView.text ?? "", size: 14)
    }
    
    func initialize() {
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        self.chatTableView.rowHeight = UITableView.automaticDimension
        self.inputTextView.delegate = self
        self.inputTextView.newDelegate = self
        self.requestHistory()
        
        self.addTapEvent()
    }
    
    @IBAction func showDetailImage(_ sender: UIButton) {
        guard let data = self.dataValue?.O_DATA?.contList else { return }
        if data[sender.tag].contType == "img" {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController else { return }
            vc.imgString = data[sender.tag].contContens ?? ""
            vc.textDate = getDate(row: sender.tag, data: data)
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if data[sender.tag].contType == "txt" {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func showAlbum(_ sender: Any) {
        showCameraRoll()
    }
    
    @IBAction func showCameraAction(_ sender: Any) {
        showCamera()
    }
    
    private func showCamera() {
        let permission = CameraPermission()
        permission.showCamera {
            performSegue(withIdentifier: CameraPermission.cameraSegue, sender: nil)
        } denied: {
            permission.showCameraPermissionAlert(vc: self)
        } notDetermined: {
            self.performSegue(withIdentifier: CameraPermission.cameraSegue, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.topViewController as? CameraViewController {
                vc.setupDelegate(delegate: self, type: .clear)
            }
        }
    }
    
    private func showCameraRoll() {
        let permission = CameraRollPermission()
        permission.showAlbum { [weak self] in
            self?.imagePicker()
        } denied: {
            permission.showAlbumPermissionAlert(vc: self)
        }
    }
    
    // TODO: 통신 분리,ImagePickerController 유틸로 분리 2020.03.14
    private func imagePicker() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.min = 1
        imagePicker.settings.selection.max = 2
        imagePicker.settings.selection.unselectOnReachingMax = true
        presentImagePicker(imagePicker, animated: true, select: nil, deselect: nil, cancel: nil, finish: { [weak self] assets in
            if assets.count > 0 {
                let param = ContactUploadRequest.Param()
                let req = ContactUploadRequest(param: param)
                guard let p = req.getParam() else { return }
                API.shared.upload(url: req.getAPI(), param: self?.addParam(p: p, assets: assets), type: .file) { (response:Swift.Result<ContactUploadResponse, TPError>) -> Void in
                    switch response {
                    case .success(let data):
                        print("ContactUSV3 success: \(data)")
                        self?.requestHistory()
                    case .failure(let error):
                        print("ContactUSV3 failure: \(error)")
                    }
                }
            }
        })
    }
    
    
    private func addParam(p: [String : Any], assets: [PHAsset]) -> [String : Any]? {
        var param = p
        
        var mid:[String] = []
        var images:[Data] = []
        
        for i in 0..<assets.count {
            mid.append(String(messageId))
            images.append(Utils.getImageSize(image: assets[i].getAssetThumbnail()))
            messageId += 1
        }
        
        param.updateValue(mid, forKey: "MESSAGE_ID")
        param.updateValue(images, forKey: "uploadFile")
        return param
    }
    
    @IBAction func showTextView(_ sender: Any) {
        self.inputTextView.becomeFirstResponder()
    }
    
    @IBAction func send(_ sender: Any) {
        if inputTextView.text.isEmpty || inputTextView.text == "" {
            return
        } else {
            requestSend(messageId: String(self.messageId))
        }
    }
}


extension PHAsset {
    func getAssetThumbnail() -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: self,
                             targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight),
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: {(result, info) -> Void in
                                if let img = result {
                                    thumbnail = img
                                }
                                
        })
        return thumbnail
    }
}

// MARK: - 통신
extension ContactViewController {
    // 데이터 보내기
    func requestSend(messageId: String) {
        let content = inputTextView.text ?? ""
        let param = ContactUSV3Request.Param(MESSAGE_ID: messageId, CONTENTS: content)
        let req = ContactUSV3Request(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<ContactUSV3Response, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print("ContactUSV3 success: \(data)")
                self.inputTextViewHeight.constant = 31
                self.inputTextView.text = ""
                self.lblFake.text = ""
                self.messageId = self.messageId + 1
                
                let date = Int(Date().timeIntervalSince1970)
                let new = ContactHistoryResponse.O_DATA.contList(contGubun: "CUSTOMER",
                                                                 contProfile: "",
                                                                 contType: "txt",
                                                                 jortNo: 0,
                                                                 contDay: date,
                                                                 contTitle: "",
                                                                 contContens: content,
                                                                 imageData: "")
                
                self.dataValue?.O_DATA?.contList?.append(new)
                if let count = self.dataValue?.O_DATA?.contList?.count {
                    let indexPath = IndexPath(row: count - 1, section: 0)
                    self.chatTableView.insertRows(at: [indexPath], with: .fade)
                    self.moveToPositionBottom(position: self.dataValue?.O_DATA?.contList?.count ?? 0)
                }
                
            case .failure(let error):
                print("ContactUSV3 failure: \(error)")
            }
        }
    }
        
    // 데이터 불러오기
    func requestHistory(_ loading: Bool = true) {
        if loading {
            self.showLoadingWindow()
        }
        
        let req = ContactHistoryRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<ContactHistoryResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print("ContactHistory success: \(data)")
                self.dataValue = data
                self.chatTableView.reloadData()
                
                if self.inputTextView.hasText {
                    self.moveToPositionBottom(position: data.O_DATA?.contList?.count ?? 0)
                    self.textViewDidChange(self.inputTextView)
                    
                } else {
                    self.moveToPositionBottom(position: data.O_DATA?.contList?.count ?? 0)
                }
                
            case .failure(let error):
                error.processError(target: self)
            }
            
            if loading {
                self.hideLoadingWindow()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cnt = self.dataValue?.O_DATA?.contList?.count else { return 0 }
        return cnt
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = self.dataValue?.O_DATA?.contList {
            let item = data[indexPath.row]
            switch item.contGubun {
            case "MANAGER":
                if item.contType == "txt" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CounselorBalloonCell", for: indexPath) as! CounselorBalloonCell
                    cell.selectionStyle = .none
                    cell.lblTitle.text = item.contTitle
                    cell.lblCounselorDate.text = String(getDate(row: indexPath.row, data: data).last ?? "")
                    let replacedText = self.replaceString(str: item.contContens)
                    cell.lblCounselorText.text = replacedText
                    
                    return cell
                    
                } else if item.contType == "web" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CounselorBalloonCell", for: indexPath) as! CounselorBalloonCell
                    cell.selectionStyle = .none
                    cell.lblTitle.text = item.contTitle
                    cell.lblCounselorDate.text = String(getDate(row: indexPath.row, data: data).last ?? "")
                    let replacedText = self.replaceString(str: item.contContens)
                    cell.lblCounselorText.attributedText = replacedText.convertHtml(fontSize: 14)
                    
                    return cell
                    
                } else if item.contType == "img" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CounselorImageCell", for: indexPath) as! ChatImageCell
                    if let imageURL = item.contContens {
                        cell.btn.tag = indexPath.row
                        cell.time.text = String(getDate(row: indexPath.row, data: data).last ?? "")
                        cell.img.setImage(with: imageURL)
                    }
                    
                    return cell
                }
                
            case "CUSTOMER":
                if item.contType == "txt" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "myBalloonCell", for: indexPath) as! MyBalloonCell
                    cell.selectionStyle = .none
                    cell.lblMyDate.text = String(getDate(row: indexPath.row, data: data).last ?? "")
                    let replacedText = self.replaceString(str: item.contContens)
                    cell.lblMyText.text = replacedText
                    
                    return cell
                    
                } else if item.contType == "img" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MyImageCell", for: indexPath) as! ChatImageCell
                    if let imageURL = item.contContens {
                        cell.btn.tag = indexPath.row
                        cell.img.setImage(with: imageURL)
                        cell.time.text = String(getDate(row: indexPath.row, data: data).last ?? "")
                    } else {
                        if let imgData = Data(base64Encoded: item.imageData ?? "") {
                            cell.img.image = UIImage(data: imgData)
                            cell.time.text = String(getDate(row: indexPath.row, data: data).last ?? "")
                        }
                    }
                    
                    return cell
                }
                
            default: break
            }
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITextViewDelegate
extension ContactViewController: UITextViewDelegate, TPTextViewDelegate {
    //  xeozin 2020/09/26 reason: 텍스트가 남아 있어서 초기화
    func backspace(textView: TPDelegateTextView) {
        if textView.text.count == 0 {
            lblFake.text = ""
            inputTextView.resignFirstResponder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let height = textView.contentSize.height
        if height <= 84 { // int값은 텍스트 크기에 따라서 변한다
            self.viewHeight = height
            self.inputTextViewHeight.constant = height // textView 높이 동적
            textView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        self.view.layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            return true
        }
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        self.lblFake.text = updatedText
        
        return true
    }
}

// MARK: - extension
extension ContactViewController {
    // bottom position
    private func moveToPositionBottom(position: Int) {
        let lastIndex = NSIndexPath(row: position - 1, section: 0) as IndexPath
        if lastIndex.row <= 0 { return }
        self.view.layoutIfNeeded()
        self.chatTableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
    }
    
    // 1.날짜 2.시간 얻기
    private func getDate(row: Int, data: [ContactHistoryResponse.O_DATA.contList]) -> [String] {
        let dateValue = Date(timeIntervalSince1970: TimeInterval(data[row].contDay ?? 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = App.shared.locale
        let dateString: String = dateFormatter.string(from: dateValue)
        let dateTime: [String] = dateString.components(separatedBy: " ")
        
        return dateTime
    }
    
    // html 오류 문자 치환
    private func replaceString(str: String?) -> String {
        guard let s = str else { return "" }
        var change: String = s.replacingOccurrences(of: "\\r\\n", with: "\n")
        change = change.replacingOccurrences(of: "\\n", with: "\n")
        return change.replacingOccurrences(of: "\"", with: "").trim()
    }
    
    // 제스쳐
    internal func addTapEvent() {
        if self.tapGesture == nil {
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        }
        
        if let tap = self.tapGesture {
            view.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapHandler() {
        self.view.endEditing(true)
    }
}

// MARK: - 키보드 컨트롤
extension ContactViewController {
    private func actionKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(noti:)),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(noti:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(noti: NSNotification) {
        self.btnCover.isHidden = true
        self.lblFake.isHidden = true
        self.inputTextView.isHidden = false
        let notiInfo = noti.userInfo! as NSDictionary   // 키보드의 높이 가져오기
        let keyboardFrame = notiInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardheight = keyboardFrame.size.height
        let hasNotch = UIWindow.key?.safeAreaInsets.bottom ?? 0
        if hasNotch <= 0 {
            self.inputViewBottom.constant = keyboardheight
        } else {
            self.inputViewBottom.constant = keyboardheight - 34
        }
        
        if self.inputTextView.text.isEmpty {
            self.inputTextViewHeight.constant = 31
        } else {
            self.inputTextViewHeight.constant = self.viewHeight
        }
        
        self.durationKeyboard(info: notiInfo)
        moveToPositionBottom(position: self.dataValue?.O_DATA?.contList?.count ?? 0)
    }
    
    @objc private func keyboardWillHide(noti: NSNotification) {
        self.btnCover.isHidden = false
        self.lblFake.isHidden = false
        self.inputTextView.isHidden = true
        self.inputViewBottom.constant = 0
        self.inputTextViewHeight.constant = 31
        let notiInfo = noti.userInfo! as NSDictionary
        self.durationKeyboard(info: notiInfo)
    }
    
    private func durationKeyboard(info: NSDictionary) {
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration) {    // 키보드의 움직이는 시간 가져오기
            self.view.layoutIfNeeded()
        }
    }
}

extension ContactViewController: CaptureDelegate {
    func sendImage(image: UIImage, type: CameraType?) {
        switch type {
        case .clear:
            let param = ContactUploadRequest.Param()
            let req = ContactUploadRequest(param: param)
            guard let p = req.getParam() else { return }
            API.shared.upload(url: req.getAPI(), param: self.addSingleCameraImageParam(p: p, image: image), type: .file) { [weak self] (response:Swift.Result<ContactUploadResponse, TPError>) -> Void in
                switch response {
                case .success(let data):
                    print("ContactUSV3 success: \(data)")
                    self?.requestHistory()
                case .failure(let error):
                    print("ContactUSV3 failure: \(error)")
                }
            }
        default:
            break
        }
    }
    
    private func addSingleCameraImageParam(p: [String : Any], image: UIImage) -> [String : Any]? {
        var param = p
        
        var mid:[String] = []
        var images:[Data] = []
        
        mid.append(String(messageId))
        images.append(Utils.getImageSize(image: image))
        messageId += 1
        
        param.updateValue(mid, forKey: "MESSAGE_ID")
        param.updateValue(images, forKey: "uploadFile")
        return param
    }
    
    private func sendSingleImage() {
        let param = ContactUploadRequest.Param()
        let req = ContactUploadRequest(param: param)
        guard let p = req.getParam() else { return }
        // 파라미터에 이미지 정보 추가해야 함
        API.shared.upload(url: req.getAPI(), param: p, type: .file) { (response:Swift.Result<ContactUploadResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print("ContactUSV3 success: \(data)")
                self.requestHistory()
            case .failure(let error):
                print("ContactUSV3 failure: \(error)")
            }
        }
    }
}
