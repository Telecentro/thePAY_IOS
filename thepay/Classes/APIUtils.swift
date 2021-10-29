//
//  APIUtils.swift
//  thepay
//
//  Created by seojin on 2020/11/26.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class APIUtils: NSObject {
    
    static func balanceCheck(target: TPBaseViewController, handler: @escaping ()->()) {
        let req = RemainsRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak target] (response:Swift.Result<RemainsResponse, TPError>) -> Void in
            guard let target = target else { return }
            switch response {
            case .success(let data):
                Utils.updateRemains(data: data)
            case .failure(let error):
                error.processError(target: target, type: .remain)
            }
            
            handler()
        }
    }
    
}
