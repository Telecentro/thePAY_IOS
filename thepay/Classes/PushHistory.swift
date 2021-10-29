//
//  PushHistory.swift
//  thepay
//
//  Created by seojin on 2020/12/21.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import Foundation

struct PushHistoryResponse: ResponseAPI {
    struct O_DATA: Codable {
        
        struct pushList: Codable {
            var pushDay: String?
            var pushCtn: String?
            var pushTime: String?
            var pushData: pushData?
        }
        
        struct pushData: Codable {
            var os: String?
            var token: String?
            var push_seq: Int?
            var push_type: String?
            var title: String?
            var version: String?
            var msgType: String?
            var content: String?
            var url: String?
            var image: String?
            var app: String?
        }
        
        var pushList: [pushList]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class PushHistoryRequest: RequestAPI {
    
    struct Param {
        var day: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.push_history_list
    }
    
    override func getParam() -> [String : Any]? {
        let params = [
            Key.pinNumber                   : pinNumber,
            Key.ANI                         : ani,
            Key.USER_ID                     : uuid,
            Key.DAY                         : param.day,
            Key.LANG                        : langCode,
            Key.SESSION_ID                  : sessionId,
            Key.ENC_DATE                    : enc_date,
            Key.AES256                      : aes256Value,
        ]
        return params
    }
}

/*
 
 {
   "pushList": [
     {
       "pushDay": "2015.11.12",
       "pushCtn": "01091842083",
       "pushTime": "20:23",
       "pushData": {
                 "os": "android",
                 "token": "c9iP6-Q-5pw:APA91bEw6Qosyqzs88nJ-YJgZqhsJz8f75qroz_UZGp5exPeL7Yq4_pcKq9KmRRxYTzOhIyWhFgo8Sl834HdExVdw9y6hAYpIH5GzraO1mB-CAOp8sdIzypivrLCgOx1WUh7gVCy0wrs",
                 "push_seq": 313030,
                 "push_type": "",
                 "title": "thePAY",
                 "version": "1.1.2",
                 "msgType": "",
                 "content": "[Оплата на кадафон не успешно] <br/><br/><br/>▷ Возможная причина. Срок визы истек. <br/><br/>▷ Мобильный: 010-4832-4669 <br/><br/>▷ Номер телефона мобильной компании : 114 <br/> <br/><br/>Что делать? <br/> <br/>1) Если истек срок Вашей визы тогда вы можете продлить через имииграционный офис (тел 1345) <br/><br/>2) Если ваша сим карта оформлена на паспорт тогда надо  переоформить ее на айди карту <br/><br/>3) Иногда это случается даже если вы продлили срок вашей визы. Тогда вам надо оповести Ваш оператор связи об этом чтобы они не отключили <br/><br/>4) Если Ваша симкарта от компании Mobing, 7Mobile, Eyes, тогда вы можете обратиться в сервисный центр THEPAY (тел 1666-0146) <br/><br/>5) После решения проблему с визой можете пополнить баланс через CASH баланс",
                 "url": "",
                 "image": "",
                 "app": "thePAY"
               }
     },
     {
       "pushDay": "2015.11.12",
       "pushCtn": "01091842083",
       "pushTime": "20:23",
       "pushData": {
                 "os": "android",
                 "token": "c9iP6-Q-5pw:APA91bEw6Qosyqzs88nJ-YJgZqhsJz8f75qroz_UZGp5exPeL7Yq4_pcKq9KmRRxYTzOhIyWhFgo8Sl834HdExVdw9y6hAYpIH5GzraO1mB-CAOp8sdIzypivrLCgOx1WUh7gVCy0wrs",
                 "push_seq": 313030,
                 "push_type": "",
                 "title": "thePAY",
                 "version": "1.1.2",
                 "msgType": "web",
                 "content": "[Оплата на кадафон не успешно] <br/><br/><br/>▷ Возможная причина. Срок визы истек. <br/><br/>▷ Мобильный: 010-4832-4669 <br/><br/>▷ Номер телефона мобильной компании : 114 <br/> <br/><br/>Что делать? <br/> <br/>1) Если истек срок Вашей визы тогда вы можете продлить через имииграционный офис (тел 1345) <br/><br/>2) Если ваша сим карта оформлена на паспорт тогда надо  переоформить ее на айди карту <br/><br/>3) Иногда это случается даже если вы продлили срок вашей визы. Тогда вам надо оповести Ваш оператор связи об этом чтобы они не отключили <br/><br/>4) Если Ваша симкарта от компании Mobing, 7Mobile, Eyes, тогда вы можете обратиться в сервисный центр THEPAY (тел 1666-0146) <br/><br/>5) После решения проблему с визой можете пополнить баланс через CASH баланс",
                 "url": "",
                 "image": "",
                 "app": "thePAY"
               }
     }
   ]
 }






 */
