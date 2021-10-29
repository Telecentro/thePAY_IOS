//
//  File.swift
//  thepay
//
//  Created by 홍서진 on 2021/04/09.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

class CompletionHandlerWrapper<T> {
    private var completionHandler: ((T) -> Void)?
    private let defaultValue: T
    
    init(completionHandler: @escaping ((T) -> Void), defaultValue: T) {
        self.completionHandler = completionHandler
        self.defaultValue = defaultValue
    }
    
    func respondHandler(_ value: T) {
        completionHandler?(value)
        completionHandler = nil
    }
    
    deinit {
        respondHandler(defaultValue)
    }
}
