//
//  RechargeEload.swift
//  thepay
//
//  Created by xeozin on 2020/07/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

/* RechargePreviewResponse 대치 */
//struct RechargeEloadResponse: ResponseAPI {
//    struct O_DATA: Codable {
//        var O_RCG_SEQ: String?
//        var O_PG_ID: String?
//        var O_OP_CODE: String?
//        var O_CHARGE_FLAG: String?
//        var O_NOTIECE_CONTENT: String?
//        var O_IS_SHOW_CREDIT_MENU: String?
//        var NOTIECE_TITLE: String?
//        var O_PAY_FLAG: String?
//        var O_CREDIT_BILL_TYPE: String?
//        var O_ORDERNUM: String?
//    }
//
//    var O_DATA: O_DATA?
//    var O_CODE: String
//    var O_MSG: String
//}

class RechargeEloadRequest: RequestAPI{
    
    struct Param {
        var opCode: String
        var rcgType: String
        var ctn: String
        var mvnoId: String
        var rcgAmt: String
        var userCash: String
        var userPoint: String
        var payAmt: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.recharge_eload
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.opCode      : param.opCode,
            Key.rcgType     : param.rcgType,
            Key.pinNumber   : pinNumber,
            Key.ANI         : ani,
            Key.rcgAmt      : param.rcgAmt,
            Key.userCash    : param.userCash,
            Key.userPoint   : param.userPoint,
            Key.payAmt      : param.payAmt,
            Key.LANG        : langCode,
            Key.SESSION_ID  : sessionId,
            Key.ENC_DATE    : enc_date,
            Key.AES256      : aes256Value,
            Key.OS_LANG     : os_lang
        ]
        
        return params
    }
}

//PaymentView 클래스에서 사용되는 다른 Elod 통신
//- (void)requestEloadPreview:(NSDictionary *)addParams {
//
//    NSMutableDictionary *params =
//    [[NSMutableDictionary alloc] initWithDictionary:@{TAG_OPCODE : @"NOTICE",
//                                                      TAG_RCGTYPE : self.productDO.rcgType,
//                                                      TAG_PIN_NUMBER : [SharedUserDefault loadMyPinNumber],
//                                                      TAG_MVNO_ID : self.productDO.mvnoId,
//                                                      TAG_RCGAMT :  self.productDO.price,
//                                                      TAG_USERCASH : self.cashUseButton.isSelected ? self.productDO.usedCash : @"0",
//                                                      TAG_USERPOINT : self.pointUseButton.isSelected ? self.productDO.usedPoint : @"0",
//                                                      TAG_PAYAMT : self.productDO.amountToPay,
//                                                      TAG_ANI : [SharedUserDefault loadANI],
//                                                      TAG_LANG : [SharedUserDefault loadLangText],
//                                                      TAG_SESSION_ID : [SharedUserDefault loadSessionID],
//                                                      TAG_ENC_DATE : [SharedUserDefault loadEncDate],
//                                                      TAG_AES256 : [SharedUserDefault loadAES256Value],
//                                                      TAG_OSLANG : [[NSLocale currentLocale] ISO639_2LanguageCode].uppercaseString}];
//
//    [params addEntriesFromDictionary:addParams];
//    [NetworkManager requestPostWithPath:URL_RECHARGE_ELOAD parameters:params baseViweController:self.parentViewController  success:^(id JSON) {
//
//        [self progressPreview:JSON];
//    } failure:^(NSError *error) {
//
//    }];
//}
