//
//  APIProvider.swift
//  thePAYTests
//
//  Created by seojin on 2021/03/13.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation
@testable import thePAY

class APIProvider {
    func preloading(completionHandler: @escaping (PreloadingResponse?) -> Void) {
        let req = PreloadingRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<PreloadingResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print("🏄🏼‍♂️ \(data)")
                completionHandler(data)
                break
            case .failure(let error):
                print("🏄🏼‍♂️ \(error)")
                completionHandler(nil)
                break
            }
        }
    }
    
    func authCtn(ctn: String, completionHandler: @escaping (AuthCtnResponse?) -> Void) {
        let req = AuthCtnRequest(ctn: ctn)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<AuthCtnResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                print("🏄🏼‍♂️ \(data)")
                completionHandler(data)
            case .failure(let error):
                print("🏄🏼‍♂️ \(error)")
                completionHandler(nil)
            }
        }
    }
    
    func rcgCardLimiteV3(param: RcgCardLimiteV3Request.Param, completionHandler: @escaping (RcgCardLimiteV3Response?) -> Void) {
        let req = RcgCardLimiteV3Request(param: param)
        
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response:Swift.Result<RcgCardLimiteV3Response, TPError>) -> Void in
            switch response {
            case .success(let data):
                print("🏄🏼‍♂️ \(data)")
                completionHandler(data)
            case .failure(let error):
                print("🏄🏼‍♂️ \(error)")
                completionHandler(nil)
            }
        }
    }
}
