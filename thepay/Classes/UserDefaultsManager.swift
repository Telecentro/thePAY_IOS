//
//  UserDefaultsManager.swift
//  thepay
//
//  Created by xeozin on 2020/07/01.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class AES256 {
    static func encryptionAES256NotEncDate(data: Data) -> Data {
        let d = data as NSData
        return d.aes256Encrypt(withKey: UserDefaultsManager.shared.loadAESDefaultKey())
    }
    
    static func decriptionAES256NotEncDate(data: Data) -> Data {
        let d = data as NSData
        return d.aes256Decrypt(withKey: UserDefaultsManager.shared.loadAESDefaultKey())
    }
    
    static func encryptionAES256Data(data: Data) -> Data {
        let d = data as NSData
        return d.aes256Encrypt(withKey: UserDefaultsManager.shared.loadAES256Key())
    }
    
    static func encryptionAES256WithKey(str: String, key: String) -> String {
        let s = str as NSString
        return s.encrypt(withKey: key)
    }
}

struct UDF {
    static let UDF_UUID                                = "udf_uuid"
    static let UDF_APPLE_EMAIL                         = "udf_apple_email"
    static let UDF_DYNAMIC_LINK                        = "udf_dynamic_link"
    static let USER_DEFAULT_LANGUAGE                   = "ud_language"
    static let USER_DEFAULT_INTERNATIONAL_CALL_NUM     = "ud_internationalcallnumber"
    static let USER_DEFAULT_SELECT_COUNTRY             = "ud_select_country"
    static let USER_DEFAULT_SELECT_INTERCALL_TAB       = "ud_select_intercall_tab"
    static let USER_DEFAULT_SMS_CONFIRM                = "ud_sms_confirm"
    static let USER_DEFAULT_MY_CASH                    = "ud_my_cash"
    static let USER_DEFALUT_MY_POINT                   = "ud_my_point"
    static let USER_DEFAULT_MY_MOBILE_NUM              = "ud_my_mobile_num"
    static let USER_DEFAULT_MY_ACCOUNT_NUM             = "ud_my_account_num"

    static let UDF_MY_CASH                             = "udf_my_cash"
//    static let UDF_LOGINTDATA                          = "udf_logindata"
    static let UDF_PHONE_NUM                           = "udf_phone_num"
    static let UDF_USER_ID                             = "udf_user_id"
    static let UDF_PINNUMBER                           = "udf_pinnumber"
    static let UDF_LANG                                = "udf_lang"
    static let UDF_NOTICE_SEQ                          = "udf_notice_seq"
    static let UDF_SMS_FLAG                            = "udf_sms_flag"
    static let UDF_ANI                                 = "udf_ani"
    static let UDF_IS_JOIN                             = "udf_is_join"
    static let UDF_CHECK_EVENT_LOOK                    = "udf_check_event_again"
    static let UDF_MY_BANK_CODE                        = "udf_my_bank_code"
    static let UDF_MY_POINT                            = "udf_my_point"
    static let UDF_MY_PINNUMBER                        = "udf_my_pinnumber"
    static let UDF_MY_ACCOUNT_NUM                      = "udf_my_account_num"
    static let UDF_AES_256                             = "udf_aes_256"
    static let UDF_MY_BANK_IMAGE_NAME                  = "udf_my_bank_image_name"
    static let UDF_ENC_DATE                            = "udf_enc_date"
    static let UDF_SESSION_ID                          = "udf_session_id"
    static let UDF_CONTACT_PHONE                       = "udf_contact_phone"
    static let UDF_CONTACT_TITLE                       = "udf_contact_title"
    static let UDF_CONTACT_PROILE                      = "udf_contact_profile"
    static let UDF_IS_CONTACT_US                       = "udf_is_contact"
    static let UDF_IS_INTERNATIONAL_TAP                = "udf_is_international"

    static let UDF_MY_BANK_ACCOUNT                     = "udf_my_bank_account"
    static let UDF_CREDIT_BILL_TYPE                    = "udf_credit_bill_type"
    static let UDF_IS_SHOW_CREDIT_MENU                 = "udf_is_show_credit_menu"
    static let UDF_SAVE_RECENT_CARD_NUM                = "udf_save_recent_card_num"

    static let UDF_IS_NETWROKD_ACCESS                  = "udf_is_network_access"
    static let UDF_IS_NETWROKD_FAIL                    = "udf_is_network_fail"
    static let UDF_IS_PRELOADING_DATA_NULL             = "udf_is_preloading_data_null"

    static let UDF_BARCODE_1                           = "udf_barcode1"     // 삭제 대상
    static let UDF_BARCODE_2                           = "udf_barcode2"     // 삭제 대상
    
    static let UDF_LANG_CODE                           = "udf_lang_code"
    static let UDF_PUSH_SEQ                            = "udf_push_seq"
    static let UDF_RECENT_CARD_TYPE                    = "udf_recent_card_type"

    static let UDF_APNS_TOKEN                          = "udf_apns_token"
    
    static let UDF_KT_DIAL                             = "udf_kt_dial"
    static let UDF_SKT_DIAL                             = "udf_skt_dial"
    
    static let UDF_SAVED_OLDCALL                        = "udf_saved_old_call"
    
    // 2021.1.5 추가
    static let UDF_ANI2                                = "udf_ani2"
    static let UDF_SMS_SESSION_ID                      = "udf_sms_session_id"
    // 2021.1.5 추가
    
    // 2021.1.15 추가
    static let UDF_DATA_VER                            = "udf_data_ver"
    // 2021.1.15 추가
    
    // 2021.4.08 추가
    static let UDF_SHOW_CARD_NO                        = "udf_show_card_no"
    static let UDF_INTER_CALL_ISO2                     = "udf_inter_call_iso2"
    // 2021.4.08 추가
    
    // 2021.8.14 추가
    static let UDF_PERMISION_CONFIRM                   = "udf_permission_confirm"
    // 2021.8.14 추가
    
    // 2021.9.29 추가
    static let UDF_AUTH_BIO                            = "udf_authentication_biometrics"
    static let UDF_CHECK_AUTH_BIO                      = "udf_authentication_biometrics_check"
    // 2021.9.29 추가
}

class UserDefaultsManager: NSObject {
    static let shared = UserDefaultsManager()
    
    func removeKey(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func saveStringUserDefaults(str: String, key: String) {
        UserDefaults.standard.set(str, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func loadStringUserDefaults(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    func saveBoolUserDefaults(boolean: Bool, key: String) {
        UserDefaults.standard.set(boolean, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func loadBoolUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func saveIntegerUserDefaults(intValue: Int, key: String) {
        UserDefaults.standard.set(intValue, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func loadIntegerUserDefaults(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func loadObjectUserDefaults(key: String) -> Any? {
        return UserDefaults.standard.data(forKey: key)
    }
}

// 2021.4.3
extension UserDefaultsManager {
    func clearAll() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        
        UserDefaults.standard.synchronize()
    }
}


extension UserDefaultsManager {
//    -(void)saveIsShowCreditMenu:(NSString *)str{
//        if ([str.lowercaseString isEqualToString:@"y"]) {
//            [self saveBoolUserDefaults:YES key:UDF_IS_SHOW_CREDIT_MENU];
//        }
//        else{
//            [self saveBoolUserDefaults:NO key:UDF_IS_SHOW_CREDIT_MENU];
//        }
//    }
//    -(BOOL)loadIsShowCreditMenu{
//        return [self loadBoolUserDefaults:UDF_IS_SHOW_CREDIT_MENU];
//    }
}


extension UserDefaultsManager {
    func loadUUID(social: Bool = true) -> String? {
        if social && Utils.isSocialLogin() {
            return Utils.getSnSId()
        }
        let keychainWrapper = KeychainItemWrapper(identifier: UDF.UDF_UUID, accessGroup: nil)
        var uuidValue = keychainWrapper?.object(forKey: kSecAttrAccount) as? String
        
        if let uuid = uuidValue, uuid.count > 0 {
            return uuid
        } else {
            let uuidRef = CFUUIDCreate(nil)
            let uuidStringRef = CFUUIDCreateString(nil, uuidRef)
            uuidValue = uuidStringRef as String? ?? ""
            
            keychainWrapper?.setObject(uuidValue, forKey: kSecAttrAccount)
            UserDefaults.standard.set(uuidValue, forKey: UDF.UDF_UUID)
        }
        
        return uuidValue
    }
}

extension UserDefaultsManager {
    func saveAppleEmail(value: String) {
        let keychainWrapper = KeychainItemWrapper(identifier: UDF.UDF_APPLE_EMAIL, accessGroup: nil)
        keychainWrapper?.setObject(value, forKey: kSecValueData)
    }
    
    func loadAppleEmail() -> String? {
        let keychainWrapper = KeychainItemWrapper(identifier: UDF.UDF_APPLE_EMAIL, accessGroup: nil)
        return keychainWrapper?.object(forKey: kSecValueData) as? String
    }
}


extension UserDefaultsManager {
    // KOR, USA
    func saveNationCode(value: String) {
        self.saveStringUserDefaults(str: value, key: UDF.UDF_LANG_CODE)
    }
    
    func loadNationCode() -> String {
        return self.loadStringUserDefaults(key: UDF.UDF_LANG_CODE) ?? "USA"
    }
}

//extension UserDefaultsManager {
//    func saveSelectCountry(str: String?) {
//        guard let country = str else { return }
//        
//        if country.count > 0 {
//            self.saveStringUserDefaults(str: country, key: UDF.USER_DEFAULT_SELECT_COUNTRY)
//        }
//    }
//    
//    func loadSelectCountry() -> String? {
//        guard let country = self.loadStringUserDefaults(key: UDF.USER_DEFAULT_SELECT_COUNTRY) else { return nil }
//        
//        if country.count < 1 {
//            self.saveStringUserDefaults(str: "kr", key: UDF.USER_DEFAULT_SELECT_COUNTRY)
//            return "kr"
//        }
//        
//        return country
//    }
//}

extension UserDefaultsManager {
    func isJoined() -> Bool {
        return self.loadBoolUserDefaults(key: UDF.UDF_IS_JOIN)
    }
    
    func saveJoin(value :Bool) {
        self.saveBoolUserDefaults(boolean: value, key: UDF.UDF_IS_JOIN)
    }
}

extension UserDefaultsManager {
    func saveANI(value: String) {
        self.saveStringUserDefaults(str: value.removeDash(), key: UDF.UDF_ANI)
    }
    
    func loadANI() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_ANI)
    }
    
    // 2021.1.5 추가
    func saveANI2(value: String) {
        self.saveStringUserDefaults(str: value.removeDash(), key: UDF.UDF_ANI2)
    }
    
    // 2021.1.5 추가
    func loadANI2() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_ANI2)
    }
}

extension UserDefaultsManager {
    func saveSMSFlag(value: String) {
        self.saveStringUserDefaults(str: value, key: UDF.UDF_SMS_FLAG)
    }
    
    func loadSMSFlag() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_SMS_FLAG)
    }
}

extension UserDefaultsManager {
    func saveNoticeSeq(value: String) {
        self.saveStringUserDefaults(str: value, key: UDF.UDF_NOTICE_SEQ)
    }
    
    func loadNoticeSeq() -> String? {
        if let value = self.loadStringUserDefaults(key: UDF.UDF_NOTICE_SEQ) {
            return value
        } else {
            saveNoticeSeq(value: "")
            return ""
        }
    }
}


extension UserDefaultsManager {
    func saveSessionID(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_SESSION_ID)
        }
    }
    
    func loadSessionID() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_SESSION_ID)
    }
    
    // 2021.1.5 추가
    func saveSMSSessionID(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_SMS_SESSION_ID)
        }
    }
    
    // 2021.1.5 추가
    func loadSMSSessionID() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_SMS_SESSION_ID)
    }
}

extension UserDefaultsManager {
    func saveAES256Key(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_AES_256)
        }
    }
    
    func loadAES256Key() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_AES_256)
    }
}

extension UserDefaultsManager {
    func saveMyPinNumber(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_MY_PINNUMBER)
        }
    }
    
    func loadMyPinNumber() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_MY_PINNUMBER)
    }
}

extension UserDefaultsManager {
    func saveEncDate(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_ENC_DATE)
        }
    }
    
    func loadEncDate() -> String? {
        return Utils.generateCurrentTimeStamp()
    }
}

extension UserDefaultsManager {
    func saveContactPhone(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_CONTACT_PHONE)
        }
    }
    
    func loadContactPhone() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_CONTACT_PHONE)
    }
}

extension UserDefaultsManager {
    func saveContactTitle(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_CONTACT_TITLE)
        }
    }
    
    func loadContactTitle() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_CONTACT_TITLE)
    }
}

extension UserDefaultsManager {
    func saveContactProfile(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_CONTACT_PROILE)
        }
    }
    
    func loadContactProfile() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_CONTACT_PROILE)
    }
}

extension UserDefaultsManager {
    func saveloadInternationalTap(value: String?) {
        if let v = value {
            switch v {
            case "all":
                self.saveIntegerUserDefaults(intValue: 0, key: UDF.UDF_IS_INTERNATIONAL_TAP)
            case "kt":
                self.saveIntegerUserDefaults(intValue: 1, key: UDF.UDF_IS_INTERNATIONAL_TAP)
            case "sk":
                self.saveIntegerUserDefaults(intValue: 2, key: UDF.UDF_IS_INTERNATIONAL_TAP)
            default:
                self.saveIntegerUserDefaults(intValue: 0, key: UDF.UDF_IS_INTERNATIONAL_TAP)
            }
        }
    }
    
    func loadInternationalTap() -> Int? {
        return self.loadIntegerUserDefaults(key: UDF.UDF_IS_INTERNATIONAL_TAP)
    }
}


extension UserDefaultsManager {
//    -(void)saveCreditBillType:(NSString *)str{
//
//    //    //긴급패치 한국일 경우 13으로 강제
//    //    NSString *languageOS = [[NSLocale preferredLanguages] objectAtIndex:0];
//    //    NSString *languageCode = [[languageOS componentsSeparatedByString:@"-"] objectAtIndex:0];
//    //
//    //    if([languageCode isEqualToString:@"ko"]){
//    //        str = @"13";
//    //    }
//
//        [self saveStringUserDefaults:str key:UDF_CREDIT_BILL_TYPE];
//    //    [self saveBoolUserDefaults:boolean key:UDF_CREDIT_BILL_TYPE];
//    }
//
//    -(NSString *)loadCreditBillType{
//        return [self loadStringUserDefaults:UDF_CREDIT_BILL_TYPE];
//    }
//    -(BOOL)loadIsCreditBillType{
//        //13 = 다 보여주는 화면
//        //18 = 카드번호, 년도, 월 만 보여줌
//
//    //    //긴급패치 한국일 경우 13으로 강제
//    //    NSString *languageOS = [[NSLocale preferredLanguages] objectAtIndex:0];
//    //    NSString *languageCode = [[languageOS componentsSeparatedByString:@"-"] objectAtIndex:0];
//    //
//    //    if([languageCode isEqualToString:@"ko"]){
//    //        return YES;
//    //    }
//
//        if ([[self loadStringUserDefaults:UDF_CREDIT_BILL_TYPE] isEqualToString:@"13"]) {
//            return YES;
//        }
//        else{
//            return NO;
//        }
//    }

}

extension UserDefaultsManager {
    func saveCreditBillType(value: String?) {
//        let languageOS = Locale.preferredLanguages[0]
//        let languageCode = languageOS.components(separatedBy: "-")[0]
//        if languageCode == "ko" {
//            self.saveStringUserDefaults(str: "13", key: UDF.UDF_CREDIT_BILL_TYPE)
//        } else {
//            if let v = value {
//                self.saveStringUserDefaults(str: v, key: UDF.UDF_CREDIT_BILL_TYPE)
//            }
//        }
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_CREDIT_BILL_TYPE)
        }
    }
    
    func loadCreditBillType() -> String? {
//        let languageOS = Locale.preferredLanguages[0]
//        let languageCode = languageOS.components(separatedBy: "-")[0]
//        if languageCode == "ko" {
//            return "13"
//        } else {
//            return self.loadStringUserDefaults(key: UDF.UDF_CREDIT_BILL_TYPE)
//        }
        return self.loadStringUserDefaults(key: UDF.UDF_CREDIT_BILL_TYPE)
    }
}

extension UserDefaultsManager {
    func saveSelectInterCallTab(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.USER_DEFAULT_SELECT_INTERCALL_TAB)
        } else {
            self.saveStringUserDefaults(str: "192", key: UDF.USER_DEFAULT_SELECT_INTERCALL_TAB)
        }
    }
    
    func loadSelectInterCallTab() -> String? {
        return self.loadStringUserDefaults(key: UDF.USER_DEFAULT_SELECT_INTERCALL_TAB)
    }
}

extension UserDefaultsManager {
    func saveDynamicLink(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_DYNAMIC_LINK)
        }
    }
    
    func loadDynamicLink() -> String {
        let retStr = self.loadStringUserDefaults(key: UDF.UDF_APNS_TOKEN)
        UserDefaultsManager.shared.saveDynamicLink(value: "")
        if let v = retStr {
            return v
        } else {
            return ""
        }
    }
}

extension UserDefaultsManager {
    func saveAPNSToken(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_APNS_TOKEN)
        }
    }
    
    func loadAPNSToken() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_APNS_TOKEN)
    }
}

extension UserDefaultsManager {
    func loadAESDefaultKey() -> String {
        return "8bau9hqvi52cs4xqnnf8np64uhjwao3y"
    }
}


extension UserDefaultsManager {
    func saveMyCash(value: String) {
        self.saveStringUserDefaults(str: value, key: UDF.UDF_MY_CASH)
    }
    
    func loadMyCash() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_MY_CASH)
    }
    
    func saveMyPoint(value: String) {
        self.saveStringUserDefaults(str: value, key: UDF.UDF_MY_POINT)
    }
    
    func loadMyPoint() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_MY_POINT)
    }
}

extension UserDefaultsManager {
    func saveBankCode(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_MY_BANK_CODE)
        }
    }
    
    func loadBankCode() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_MY_BANK_CODE)
    }
}

extension UserDefaultsManager {
    func saveBankImgName(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_MY_BANK_IMAGE_NAME)
        }
    }
    
    func loadBankImgName() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_MY_BANK_IMAGE_NAME)
    }
}

extension UserDefaultsManager {
    func saveMyBankAccount(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_MY_BANK_ACCOUNT)
        }
    }
    
    func loadMyBankAccount() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_MY_BANK_ACCOUNT)
    }
}

extension UserDefaultsManager {
    func saveRecentCardType(value: Int?) {
        if let v = value {
            saveIntegerUserDefaults(intValue: v, key: UDF.UDF_RECENT_CARD_TYPE)
        }
    }
    
    func loadRecentCardType() -> CardType {
        return CardType(rawValue: loadIntegerUserDefaults(key: UDF.UDF_RECENT_CARD_TYPE)) ?? CardType.CARD_TYPE_NULL
    }
    
    func saveRecentCardNumber(value: String?) {
        if let v = value {
            if v.count == 0 {
                removeKey(key: UDF.UDF_SAVE_RECENT_CARD_NUM)
            } else {
                saveStringUserDefaults(str: v, key: UDF.UDF_SAVE_RECENT_CARD_NUM)
            }
        }
    }
    
    func loadRecentCardNumber() -> String? {
        let cardNumbers = self.loadStringUserDefaults(key: UDF.UDF_SAVE_RECENT_CARD_NUM)
        guard let count = cardNumbers?.count else { return "" }
        if count > 16 || count < 12 {
            return ""
        } else {
            return cardNumbers
        }
    }
}


extension UserDefaultsManager {
    func saveInternationalCallNumber(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.USER_DEFAULT_INTERNATIONAL_CALL_NUM)
        }
    }
    
    func loadInternationalCallNumber() -> String {
        if let str = self.loadStringUserDefaults(key: UDF.USER_DEFAULT_INTERNATIONAL_CALL_NUM) {
            return str
        } else {
            self.saveInternationalCallNumber(value: "00796")
            return "00796"
        }
    }
}

extension UserDefaultsManager {
    func saveKTDial(value: Int) {
        self.saveIntegerUserDefaults(intValue: value, key: UDF.UDF_KT_DIAL)
    }
    
    func loadKTDial() -> Int? {
        return self.loadIntegerUserDefaults(key: UDF.UDF_KT_DIAL)
    }
    
    func saveSKTDial(value: Int) {
        self.saveIntegerUserDefaults(intValue: value, key: UDF.UDF_SKT_DIAL)
//        switch value {
//        case TELECOM.SKT_INTERNATIONAL_CODE_1:
//            self.saveIntegerUserDefaults(intValue: 0, key: UDF.UDF_SKT_DIAL)
//        case TELECOM.CODE_080:
//            self.saveIntegerUserDefaults(intValue: 2, key: UDF.UDF_SKT_DIAL)
//        case TELECOM.SKT_INTERNATIONAL_CODE_2:
//            self.saveIntegerUserDefaults(intValue: 1, key: UDF.UDF_SKT_DIAL)
//        default:
//            break
//        }
    }
    
    func loadSKTDial() -> Int? {
        return self.loadIntegerUserDefaults(key: UDF.UDF_SKT_DIAL)
    }
    
    func saveSavedOldCall(value: Int) {
        self.saveIntegerUserDefaults(intValue: value, key: UDF.UDF_SAVED_OLDCALL)
    }
    
    func loadSavedOldCall() -> Int? {
        return self.loadIntegerUserDefaults(key: UDF.UDF_SAVED_OLDCALL)
    }
}

extension UserDefaultsManager {
    func saveDataVer(value: String?) {
        if let v = value {
            self.saveStringUserDefaults(str: v, key: UDF.UDF_DATA_VER)
        }
    }
    
    func loadDataVer() -> String? {
        return self.loadStringUserDefaults(key: UDF.UDF_DATA_VER)
    }
}

// 2021.04.08
extension UserDefaultsManager {
    func loadShowCardNumber() -> Bool {
        return self.loadBoolUserDefaults(key: UDF.UDF_SHOW_CARD_NO)
    }
    
    func saveShowCardNumber(value :Bool) {
        self.saveBoolUserDefaults(boolean: value, key: UDF.UDF_SHOW_CARD_NO)
    }
}

// 2021.04.08
extension UserDefaultsManager {
    func loadInternationalCallISO2() -> String? {
        let cc = self.loadStringUserDefaults(key: UDF.UDF_INTER_CALL_ISO2)
        return cc
    }
    
    func saveInternationalCallISO2(value :String) {
        let v = value
        self.saveStringUserDefaults(str: v, key: UDF.UDF_INTER_CALL_ISO2)
    }
}


// 2021.08.14
extension UserDefaultsManager {
    func loadPermisionConfirm() -> Bool {
        return self.loadBoolUserDefaults(key: UDF.UDF_PERMISION_CONFIRM)
    }
    
    func savePermisionConfirm(value :Bool) {
        self.saveBoolUserDefaults(boolean: value, key: UDF.UDF_PERMISION_CONFIRM)
    }
}

extension UserDefaultsManager {
    func loadCheckAuthBio() -> Bool {
        return self.loadBoolUserDefaults(key: UDF.UDF_CHECK_AUTH_BIO)
    }
    
    func saveCheckAuthBio(value :Bool) {
        self.saveBoolUserDefaults(boolean: value, key: UDF.UDF_CHECK_AUTH_BIO)
    }
    
    func loadAuthBio() -> Bool {
        return self.loadBoolUserDefaults(key: UDF.UDF_AUTH_BIO)
    }
    
    func saveAuthBio(value :Bool) {
        self.saveBoolUserDefaults(boolean: value, key: UDF.UDF_AUTH_BIO)
    }
}
