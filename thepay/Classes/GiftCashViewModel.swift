//
//  GiftCashViewModel.swift
//  thepay
//
//  Created by 홍서진 on 2021/08/25.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit


struct GiftCash {
    public let min = 1000;
    public let max = 50000;
    public var myCash = 0;
    public let seconds = 1800
    
    public enum OperationCode: String {
        case req = "req"
        case res = "res"
        case trans = "trans"
        case cancel = "cancel"
        
        var code: String {
            switch self {
            case .cancel:
                return "cancel"
            case .trans:
                return "trans"
            case .res:
                return "res"
            case .req:
                return "req"
            }
        }
    }
}

public enum errorCode: String{
    case e5001 = "5001" // 본인에게 전송 금지
    case e5002 = "5002" // 하루 전송 횟수 제한  5회
    case e5003 = "5003" // 전송금액 체크 PRECASH 보다큰지 , 50000 원 넘는 금액인지
    case e5004 = "5004" // 전송 대상자 찾을수 없을때
    case e5005 = "5005" // 송금자 차단 고객인경우
    case e5006 = "5006" // 인증번호 틀린경우
    case e5007 = "5007" // 하루 최대 전송 금액 제한 일단 30만원 - TODO - 내부논의 필요
    
    var errorAction: errorActions {
        switch self {
        case .e5001, .e5002, .e5005, .e5007:
            return .showMessage
        case .e5003:
            return .clearCash
        case .e5004:
            return .clearCash
        case .e5006:
            return .clearCash
        }
    }
}

public enum errorActions {
    case showMessage
    case clearCash
    case clearReceiver
    case clearAuth
}

enum GiftCashStatus {
    case start
    case issue(info: GiftInfo?)
    case confirmed(info: GiftInfo?)
}

struct GiftInfo {
    var sender: String?
    var amount: String?
    var receiver: String?
    var authCode: String?
    var authTime: String?
    var transSeq: String?
    
    var amountInt: Int {
        return Int(amount ?? "0") ?? 0
    }
    
    func builder(authCode: String?) -> GiftInfo {
        return GiftInfo(sender: self.sender,
                        amount: self.amount,
                        receiver: self.receiver,
                        authCode: authCode,
                        transSeq: self.transSeq)
    }
    
    func builder(transSeq: String?) -> GiftInfo {
        return GiftInfo(sender: self.sender,
                        amount: self.amount,
                        receiver: self.receiver,
                        authCode: self.authCode,
                        transSeq: transSeq)
    }
    
    static func create(by: GiftTransCheckResponse.O_DATA?) -> GiftInfo? {
        guard let by = by else { return nil }
        return GiftInfo(
            sender: by.transNm,
            amount: by.transAmt,
            receiver: by.transTo,
            transSeq: by.transSeq
        )
    }
}

class GiftCashViewModel {
    var transSeq = "" {
        didSet {
            print("CHANGED SEQ 🎃 \(transSeq)")
        }
    }
    var authCode = ""
    let max = 50000
    var seconds = 0
    var myCash: Int = 0
    var noCash:Bool {
        return myCash < gc.min
    }
    
    var timer: Timer?
    var gc = GiftCash()
    var checkResponseData: GiftTransCheckResponse.O_DATA?

    var resetAmountText:(()->())?
    var resetSenderText:(()->())?
    var resetReceiverText:(()->())?
}

extension GiftCashViewModel {
    
    func isOver() -> Bool {
        if seconds <= 0 {
            timer?.invalidate()
            return true
        } else {
            return false
        }
    }
    
    func decreaseTimer(isFirst: Bool) -> String? {
        if !isFirst {
            seconds = seconds - 1
        }
        
        return getTimerString()
    }
    
    func getTimerString() -> String? {
        let hour    = seconds / 3600
        let min     = (seconds % 3600) / 60
        let sec     = (seconds % 3600) % 60
        
        let h = singleToDouble(target: hour)
        let m = singleToDouble(target: min)
        let s = singleToDouble(target: sec)
        if hour == 0 && min == 0 {
            return "\(sec)"
        } else if hour == 0 {
            return "\(m):\(s)"
        } else if hour > 0 {
            return "\(h):\(m):\(s)"
        } else {
            return nil
        }
    }
    
    func createTimer(timer: Timer) {
        self.timer?.invalidate()
        self.timer = timer
    }
    
    func resetTimer() {
        seconds = gc.seconds
    }
    
    func changeTimer(authTime: String?) {
        let authTime = Int(authTime ?? "18000") ?? 18000
        seconds =  authTime / 1000
    }
    
    private func singleToDouble(target: Int) -> String {
        return (String(target).count == 1) ? "0\(target)" : String(target)
    }
    
    func getValidAmount(text: String?) -> String? {
        if let amountString = text?.replacingOccurrences(of: ",", with: "") {
            
            let max = Int(max)
            if Int(amountString) ?? 0 > max {
                return max.currency
                // 금액 0원은 입력 제한
            } else if Int(amountString) ?? 0 == 0{
                return ""
            } else {
                return amountString.currency
            }
        } else {
            return nil
        }
    }
    
    /**
     *
     */
    func getCurrentStatus(data: GiftTransCheckResponse.O_DATA?) -> GiftCashStatus {
        guard let data = data else { return .start }
        if data.transStatus == "0" {
            return .start
        }
        
        switch data.transStatus {
        case "0":
            return .start
        case "1":
            if data.authStatus == "1" {
                return .confirmed(info: nil)
            } else {
                return .issue(info: nil)
            }
        default:
            break
        }
        
        return .start
    }
    
    /**
     *
     */
    func checkData(data: GiftInfo, view: UIView) -> Bool {
        // sender name
        // ERROR! Check your input values
        if data.sender.isNilOrEmpty {
            resetSenderText?()
            Localized.waring_gift_cash_input_sender.txt.showErrorMsg(target: view)
            return false
        }
        
        if data.amountInt < gc.min {
            resetAmountText?()
            Localized.text_gift_cash_min_check.txt.showErrorMsg(target: view)
            return false
        }
        
        if data.amountInt > gc.max {
            resetAmountText?()
            Localized.text_gift_cash_max_check.txt.showErrorMsg(target: view)
            return false
        }
        
        if data.amountInt > myCash {
            resetAmountText?()
            Localized.waring_gift_cash_input_cash.txt.showErrorMsg(target: view)
            return false
        }
        
        if data.receiver.isNilOrEmpty {
            resetReceiverText?()
            Localized.waring_gift_cash_input_receiver.txt.showErrorMsg(target: view)
            return false
        }
        
        return true
    }
    
    /**
     *
     */
    func createOperationData(data: GiftInfo, opcode: GiftCash.OperationCode) -> GiftTransRequest.Param? {
        guard let nm    = data.sender else { return nil }
        guard let amt   = data.amount else { return nil }
        guard let to    = data.receiver else { return nil }
        var code = authCode
        switch opcode {
        case .trans, .res:
            guard let c = data.authCode else { return nil }
            code = c
        default:
            break
        }
        
        let param = GiftTransRequest.Param(
            opCode      : opcode,
            transSeq    : transSeq,
            transNm     : nm,
            transTo     : to,
            transAmt    : amt,
            authCode    : code
        )
        
        return param
    }
}
