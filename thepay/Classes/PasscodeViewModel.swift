//
//  File.swift
//  
//
//  Created by 홍서진 on 2021/05/14.
//

import UIKit
import LocalAuthentication
import RxSwift

enum PasscodeState: String {
    case case1 = "1"  // 간편결제 최초 등록시(seq없는경우) PIN 6자리 비번등록
    case case2 = "2"  // 비번체크 - 간편 결제 충전시
    case case3 = "3"  // 비번체크 - 내정보 카드관리 페이지 진입시
    case case4 = "4"  // 비번체크 - 2번째 간편결제 카드 추가시
    case case5 = "5"  // 카유(비생) 카드비번 입력
    
    var title: String {
        switch self {
        case .case1:
            return Localized.text_guide_please_enter_easy_payment_pwd_for_payment.txt
        case .case2:
            return Localized.text_guide_please_enter_easy_payment_pwd.txt
        case .case3:
            return Localized.text_guide_please_enter_easy_payment_pwd_to_view_card_list_info.txt
        case .case4:
            return Localized.text_guide_please_enter_6_digits_easy_payment_pwd.txt
        case .case5:
            return Localized.text_title_first_2_digits_of_pwd.txt
        }
    }
}

struct KeyItem {
    var imageName: String
    var title: String
    var number: Int
}

protocol PasscodeDelegate {
    func incorrect()
    func changedFail()
    func cancel(state: PasscodeState)
}

class PasscodeViewModel {
    let authContext = LAContext()
    
//    var state: PasscodeState = .change
//    var realPass:String? = "776776"
    var maxErrorCount = 5
    var keyLength = 6
    
    var tempString:String?
    
    var state = BehaviorSubject<PasscodeState>(value: .case1)
    var errorCount = BehaviorSubject<String>(value: "0/0")
    let mainColor:BehaviorSubject<UIColor>
    
    var db = DisposeBag()
    
    var keyString = BehaviorSubject<String>(value: "")
    
    var keyFirst: String?
    
    init() {
        mainColor = BehaviorSubject(value: UIColor(named: "e9e9e9") ?? .white)
    }
    
    var canEdit = true
    
    let keys:[KeyItem] = [
        KeyItem(imageName: "image_0", title:"1", number: 0),
        KeyItem(imageName: "image_1", title:"2", number: 1),
        KeyItem(imageName: "image_2", title:"3", number: 2),
        KeyItem(imageName: "image_3", title:"4", number: 3),
        KeyItem(imageName: "image_4", title:"5", number: 4),
        KeyItem(imageName: "image_5", title:"6", number: 5),
        KeyItem(imageName: "image_6", title:"7", number: 6),
        KeyItem(imageName: "image_7", title:"8", number: 7),
        KeyItem(imageName: "image_8", title:"9", number: 8),
        KeyItem(imageName: "image_9", title:"0", number: 9),
    ]
    
    func correctPassword() {
//        updateState(state: .checked)
        resetErrorCount()
    }
    
    func updateState(state: PasscodeState) {
        self.state.onNext(state)
    }
    
    func resetErrorCount() {
        errorCount.onNext("0/0")
    }
    
    func increaseErrorCount(failCnt: String) {
        errorCount.onNext(failCnt)
    }
    
    func isEmptyPasscode() -> Bool {
        guard let key = try? keyString.value() else { return true }
        if key.count < 6 {
            return true
        } else {
            return false
        }
    }
//
//    func isSame() -> Bool {
//        guard let value = try? keyString.value() else { return false }
//        return realPass == value
//    }
    
    func max() -> Bool {
        guard let value = try? keyString.value() else { return false }
        return value.count == keyLength
    }
    
    func needUpdate() -> Bool {
        guard let value = try? keyString.value() else { return false }
        return value.count == keyLength
    }
    
    func appendString(key: String) {
        guard var value = try? keyString.value() else { return }
        value.append(key)
        keyString.onNext(value)
    }
    
    func clearString() {
        keyString.onNext("")
    }
    
    func removeString() {
        guard var value = try? keyString.value() else { return }
        if value.count > 0 {
            value.removeLast()
            keyString.onNext(value)
        }
    }
}
