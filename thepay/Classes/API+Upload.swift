//
//  API+Upload.swift
//  thepay
//
//  Created by seojin on 2020/12/29.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import Alamofire


extension API {
    private func isCrypto(key: String) -> Bool {
        return key == Key.AES256 ||
            //            key == Key.cardNum ||
            //            key == Key.CARDNUM ||
            key == Key.cardPsswd ||
            key == Key.userSecureNum ||
            key == Key.cardExpireMM ||
            key == Key.cardExpireYY ||
            key == Key.DEVICE_TOKEN
    }
    
    func upload<T: Codable>(url: String?, param: [String: Any]?, type: UploadType, completionHandler: @escaping (Result<T, TPError>) -> Void) {
        guard let url = url else { return }
        AF.upload(multipartFormData: { [weak self] multiPart in
            guard let self = self else { return }
            self.updateMultiPart(param: param, multiPart: multiPart, type: type)
            }, to: url, method: .post).uploadProgress { progress in
                print("📧📧📧 \(progress.fractionCompleted)")
        }.validate().response { response in
            switch response.result {
            case .success(let value):
                guard let v = value else { return }
                guard let data = value else { return }
                guard let result = String(data: v, encoding: .utf8) else { return }
                print("⚡️⚡️⚡️ \(url) ⚡️⚡️⚡️ \(result) ⚡️⚡️⚡️")
                let decoder = JSONDecoder()
                do {
                    let d = try decoder.decode(T.self, from: data)
                    if let error = self.parseError(d: d) {
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.success(d))  // [ JSON 결과 성공 ]
                    }
                } catch {
                    self.showErrorMsg(error: error)
                    completionHandler(.failure(TPError.error(code: "-4", msg: "JSON Error")))
                }
            case .failure(let error):
                print("🏴‍☠️🏴‍☠️🏴‍☠️ \(url) \(error) 🏴‍☠️🏴‍☠️🏴‍☠️")
                completionHandler(.failure(TPError.error(code: "-9", msg: error.localizedDescription)))
            }
        }
    }
    
    private func updateMultiPart(param: [String: Any]?, multiPart: MultipartFormData, type: UploadType) {
        guard let p = param else { return }
        for item in p {
            if item.key.contains(UploadTag.uploadFile) || EasyPhotoUtils.isEasyPhotoKey(key: item.key) {
                switch type {
                case .file:
                    if let images = item.value as? Array<Data> {
                        for (idx, img) in images.enumerated() {
                            multiPart.append(img, withName: UploadTag.uploadFile, fileName: "\(item.key)\(idx).png", mimeType: UploadTag.png)
                        }
                    }
                case .safe_card:
                    if let d = item.value as? Data {
                        multiPart.append(d, withName: UploadTag.uploadFile, fileName: "\(item.key).png", mimeType: UploadTag.png)
                    }
                case .easy_pay:
                    if let d = item.value as? Data {
                        multiPart.append(d, withName: UploadTag.uploadFile2, fileName: "\(item.key).png", mimeType: UploadTag.png)
                    }
                case .period:
                    if let d = item.value as? Data {
                        multiPart.append(d, withName: item.key, fileName: "\(item.key).png", mimeType: UploadTag.png)
                    }
                }
                
            } else if item.key.contains(UploadTag.MESSAGE_ID) {
                if let id = item.value as? Array<String> {
                    for x in id {
                        if let strData = x.data(using: .utf8) {
                            multiPart.append(strData, withName: item.key)
                        }
                    }
                }
            } else {
                let v = item.value as? String
                
                if self.isCrypto(key: item.key) && type != .easy_pay {
                    let encodedString = v?.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed)
                    if let strData = encodedString?.data(using: .utf8) {
                        multiPart.append(strData, withName: item.key)
                    }
                } else {
                    if let strData = v?.data(using: .utf8) {
                        multiPart.append(strData, withName: item.key)
                    }
                }
            }
        }
    }
    
    enum UploadType {
        case file
        case safe_card
        case period
        case easy_pay
    }
    
    struct UploadTag {
        static let uploadFile = "uploadFile"
        static let uploadFile2 = "uploadFile[]"
        static let MESSAGE_ID = "MESSAGE_ID"
        static let png = "image/png"
    }
    
    
}
