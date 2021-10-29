//
//  Easy.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import Foundation

class EasyRegInfo {
    static let shared = EasyRegInfo()
    
    var step2: PreEasyResponse.step2?
    var step3: PreEasyResponse.step3?
    var cardNum: String?    // STEP4 완료시 카드번호만 받는 경우
    var seq: String?
    
    public func clean() {
        self.step2 = nil
        self.step3 = nil
        self.cardNum = nil
        self.seq = nil
    }
    
    public func isNew() -> Bool {
        return self.step2 == nil
            && self.step3 == nil
            && self.cardNum == nil
            && self.seq == nil
    }
}
