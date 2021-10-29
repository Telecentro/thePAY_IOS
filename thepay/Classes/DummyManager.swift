//
//  DummyManager.swift
//  thepay
//
//  Created by seojin on 2020/11/27.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class DummyManager: NSObject {
    struct Dummy {
        var callNumber: String
        var date: String
    }
    
    static let shared = DummyManager()
    
    func createDummyData() {
        let nullItem = [
            Dummy(callNumber: "01039999922", date: "20201017141745"),
            Dummy(callNumber: "01031111122", date: "20201107141745")
        ]
        
        let items = [
            Dummy(callNumber: "821006532352", date: "20200728134840"),
            Dummy(callNumber: "820554040404", date: "20200728134909"),
            Dummy(callNumber: "8606532352", date: "20200928134840"),
            Dummy(callNumber: "860554040404", date: "20200928134909"),
            Dummy(callNumber: "380815458454", date: "20200928135000"),
            Dummy(callNumber: "38084544", date: "20200928140008"),
            Dummy(callNumber: "3800524552", date: "20200928140232"),
            Dummy(callNumber: "86010235545", date: "20200928140256"),
            Dummy(callNumber: "01071217767", date: "20200928140744"),
            Dummy(callNumber: "01071217767", date: "20200928140744"),
            Dummy(callNumber: "8653555525", date: "20200929131720"),
            Dummy(callNumber: "86855", date: "20200929155046"),
            Dummy(callNumber: "86866", date: "20200929155335"),
            Dummy(callNumber: "01071211620", date: "20200929201527"),
            Dummy(callNumber: "trst@gmaile.coma", date: "20201007151220"),
            Dummy(callNumber: "trst@gmgmaileaile.coma", date: "20201007151301"),
            Dummy(callNumber: "htghh@hghuy.com", date: "20201007151531"),
            Dummy(callNumber: "htghh@hghuyhtg.com", date: "20201007151600"),
            Dummy(callNumber: "01094946773", date: "20201008141850"),
            Dummy(callNumber: "awkejhflkawjhef", date: "20201108141850"),
            Dummy(callNumber: "ㅁㅈ디라ㅓ미자덜", date: "20200808141850"),
            Dummy(callNumber: "ididididididi", date: "20200708141850"),
            Dummy(callNumber: "01011111111", date: "20200927141745"),
            Dummy(callNumber: "01022222222", date: "20201027141745"),
            Dummy(callNumber: "01033333333", date: "20201127141745")
        ]
        
        for i in nullItem {
            let new = CallHistoryItem()
            new.callNumber = i.callNumber
            new.date = i.date
            DBListManager.addRechargeHistory(new)
        }
        
        for i in items {
            let new = CallHistoryItem()
            new.callNumber = i.callNumber
            new.countryCode = "kr"
            new.countryNumber = ""
            new.date = i.date
            DBListManager.addRechargeHistory(new)
        }
        
        print("🥕 ADD DB DUMMY DATA")
    }
    
    func createCallDummyData() {
        let nullItem = [
            Dummy(callNumber: "01039999922", date: "20201017141745"),
            Dummy(callNumber: "01031111122", date: "20201107141745")
        ]
        
        let items = [
            Dummy(callNumber: "821006532352", date: "20200728134840"),
            Dummy(callNumber: "820554040404", date: "20200728134909"),
            Dummy(callNumber: "8606532352", date: "20200928134840"),
            Dummy(callNumber: "860554040404", date: "20200928134909"),
            Dummy(callNumber: "380815458454", date: "20200928135000"),
            Dummy(callNumber: "38084544", date: "20200928140008"),
            Dummy(callNumber: "3800524552", date: "20200928140232"),
            Dummy(callNumber: "86010235545", date: "20200928140256"),
            Dummy(callNumber: "01071217767", date: "20200928140744"),
            Dummy(callNumber: "01071217767", date: "20200928140744"),
            Dummy(callNumber: "8653555525", date: "20200929131720"),
            Dummy(callNumber: "86855", date: "20200929155046"),
            Dummy(callNumber: "86866", date: "20200929155335"),
            Dummy(callNumber: "01071211620", date: "20200929201527"),
            Dummy(callNumber: "trst@gmaile.coma", date: "20201007151220"),
            Dummy(callNumber: "trst@gmgmaileaile.coma", date: "20201007151301"),
            Dummy(callNumber: "htghh@hghuy.com", date: "20201007151531"),
            Dummy(callNumber: "htghh@hghuyhtg.com", date: "20201007151600"),
            Dummy(callNumber: "01094946773", date: "20201008141850"),
            Dummy(callNumber: "awkejhflkawjhef", date: "20201108141850"),
            Dummy(callNumber: "ㅁㅈ디라ㅓ미자덜", date: "20200808141850"),
            Dummy(callNumber: "ididididididi", date: "20200708141850"),
            Dummy(callNumber: "01011111111", date: "20200927141745"),
            Dummy(callNumber: "01022222222", date: "20201027141745"),
            Dummy(callNumber: "89999999999", date: "20201127141748"),
            Dummy(callNumber: "89999999999", date: "20201127141748"),
            Dummy(callNumber: "89999999999", date: "20201127141748")
        ]
        
        for i in nullItem {
            let new = CallHistoryItem()
            new.callNumber = i.callNumber
            new.date = i.date
            DBListManager.addRechargeHistory(new)
        }
        
        for i in items {
            let new = CallHistoryItem()
            new.callNumber = i.callNumber
            new.countryCode = "kr"
            new.countryNumber = ""
            new.interNumber = "080"
            new.date = i.date
            DBListManager.addCallHistory(new)
        }
        
        print("🥕 ADD DB DUMMY DATA")
    }
}
