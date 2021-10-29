//
//  LanguageUtils.swift
//  thepay
//
//  Created by xeozin on 2020/07/16.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum CustomFont: String {
    case MMR = "Zawgyi-One"
    case BGD = "Bangla"
    
    var fontName: String {
        return self.rawValue
    }
    
    var upSize: CGFloat {
        switch self {
        case .BGD:
            return 3
        case .MMR:
            return -2
        }
    }
}

class LanguageUtils: NSObject {
    
    static func saveLanguage(lang: CodeLang) {
        let nationCode = lang.nationCode
        UserDefaultsManager.shared.saveNationCode(value: nationCode)
        App.shared.generateBundle(lang: nationCode)
    }
    
    static func useCustomFont() -> Bool {
        let customFonts = [
            CodeLang.CodeLangMMR,
            CodeLang.CodeLangMMY
//            CodeLang.CodeLangBGD,
        ]
        
        for i in customFonts {
            if App.shared.codeLang == i {
                return true
            }
        }
        
        return false
    }
    
    static func getLocale() -> Locale? {
        var countryCode = App.shared.codeLang.localeCode
        
        // 강제로 영어 로케일 적용
        countryCode = CodeLang.CodeLangUSA.localeCode
        let locale = Locale(identifier: countryCode)
        
        return locale
    }
    
    // 캘린더의 경우 몽골, 미얀마에만 영어 로케일을 적용한다.
    static func getCalendarLocale() -> Locale {
        var countryCode = App.shared.codeLang.localeCode
        
        switch countryCode {
        case CodeLang.CodeLangMNG.localeCode,
             CodeLang.CodeLangMMR.localeCode:
            countryCode = CodeLang.CodeLangUSA.localeCode
        default:
            break
        }
        
        let locale = Locale(identifier: countryCode)
        return locale
    }
    
    static func fontWithSize(size: CGFloat, oldFont: UIFont? = nil) -> UIFont {
        let desc = oldFont?.fontDescriptor.object(forKey: .face) as? String ?? "Regular"
        if LanguageUtils.useCustomFont() {
            switch App.shared.codeLang {
            case .CodeLangBGD:
                let newSize = size + CustomFont.BGD.upSize
                let fontDesc = UIFontDescriptor(name: CustomFont.BGD.fontName, size: newSize)
                fontDesc.withFace(desc)
                return UIFont(descriptor: fontDesc, size: newSize)
            case .CodeLangMMR, .CodeLangMMY:
                let newSize = size + CustomFont.MMR.upSize
                let fontDesc = UIFontDescriptor(name: CustomFont.MMR.fontName, size: newSize)
                fontDesc.withFace(desc)
                let f = UIFont(descriptor: fontDesc, size: newSize)
                print("👒 \(f.familyName)")
                // iOS 14.01, iPhone 6 plus (.LastReport)
                // 👒 .LastResort
                if f.familyName != CustomFont.MMR.fontName {
                    return oldFont ?? UIFont.systemFont(ofSize: newSize)
                }
                return f
            default:
                return oldFont ?? UIFont.systemFont(ofSize: size)
            }
        } else {
            return oldFont ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    static func printFont() {
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    static func getArabianSentence(string: String) -> String {
        var newString = ""
        for i in string {
            newString.append(LanguageUtils.getArabianNumber(key: i))
        }
        
        return newString
    }
    
    static func getArabianNumber(key: Character) -> Character {
        switch key {
        case "०", "၀", "០", "0", "۰", "০":
            return "0"
        case "१", "၁", "១", "๑", "۱", "১":
            return "1"
        case "२", "၂", "២", "๒", "۲", "২":
            return "2"
        case "३", "၃", "៣", "๓", "۳", "৩":
            return "3"
        case "४", "၄", "៤", "๔", "۴", "৪":
            return "4"
        case "५", "၅","៥", "๕", "۵", "৫":
            return "5"
        case "६", "၆", "៦", "๖", "۶", "৬":
            return "6"
        case "७", "၇", "៧", "๗", "۷", "৭":
            return "7"
        case "८", "၈", "៨", "๘", "۸", "৮":
            return "8"
        case "९", "၉", "៩", "๙", "۹", "৯":
            return "9"
        default:
            return key
        }
    }
}

enum CodeLang: CaseIterable {
    case CodeLangUSA      // 영어
    case CodeLangCHN      // 중국어
    case CodeLangPHI      // 필리핀
    case CodeLangUZB      // 우즈벡어
    case CodeLangCAM      // 캄보디아어
    case CodeLangMMR      // 미얀마어
    case CodeLangNPL      // 네팔 (추후지원)
    case CodeLangVNM      // 베트남어
    case CodeLangTHA      // 태국어
    case CodeLangIDN      // 인도네시아어
    case CodeLangMNG      // 몽골어
    case CodeLangRUS      // 러시아어
    case CodeLangLKA      // 스리랑카 (추후지원)
    case CodeLangBGD      // 방글라데시
    case CodeLangPAK      // 파키스탄
    case CodeLangLAO      // 라오스
    case CodeLangKOR      // 한국
    case CodeLangMMY      // 미얀마어 (유니코드)
    
    // 국기 이미지 정보
    var flagCode: String {
        switch self {
        case .CodeLangKOR: return "kr"
        case .CodeLangUSA: return "us"
        case .CodeLangCHN: return "cn"
        case .CodeLangVNM: return "vn"
        case .CodeLangTHA: return "th"
        case .CodeLangIDN: return "id"
        case .CodeLangMNG: return "mn"
        case .CodeLangCAM: return "kh"
        case .CodeLangUZB: return "uz"
        case .CodeLangMMR: return "mm"
        case .CodeLangLKA: return "lk"
        case .CodeLangNPL: return "np"
        case .CodeLangRUS: return "ru"
        case .CodeLangPHI: return "ph"
        case .CodeLangBGD: return "bd"
        case .CodeLangLAO: return "la"
        case .CodeLangPAK: return "pk"
        case .CodeLangMMY: return "mm"
        }
    }
    
    var nationAlphaName: String {
        switch self {
        case .CodeLangKOR: return "Korea"
        case .CodeLangUSA: return "USA"
        case .CodeLangCHN: return "China"
        case .CodeLangVNM: return "Vietnam"
        case .CodeLangTHA: return "Thailand"
        case .CodeLangIDN: return "Indonesia"
        case .CodeLangMNG: return "Mongolia"
        case .CodeLangCAM: return "Cambodia"
        case .CodeLangUZB: return "Uzbekistan"
        case .CodeLangMMR: return "Myanmar"
        case .CodeLangLKA: return "Sri Lanka"
        case .CodeLangNPL: return "Nepal"
        case .CodeLangRUS: return "Rusia"
        case .CodeLangPHI: return "Pilipinas"
        case .CodeLangBGD: return "Bangladesh"
        case .CodeLangLAO: return "Laos"
        case .CodeLangPAK: return "Pakistan"
        case .CodeLangMMY: return "Myanmar"
        }
    }
    
    // 언어 코드
    var languageCode: String {
        switch self {
        case .CodeLangKOR: return "ko"
        case .CodeLangUSA: return "en"
        case .CodeLangCHN: return "zh"
        case .CodeLangVNM: return "vi"
        case .CodeLangTHA: return "th"
        case .CodeLangIDN: return "id"
        case .CodeLangMNG: return "mn"
        case .CodeLangCAM: return "km"
        case .CodeLangUZB: return "uz"
        case .CodeLangMMR: return "my"
        case .CodeLangLKA: return "si"
        case .CodeLangNPL: return "ne"
        case .CodeLangRUS: return "ru"
        case .CodeLangPHI: return "fil"
        case .CodeLangBGD: return "bn-BD"
        case .CodeLangLAO: return "lo"
        case .CodeLangPAK: return "ur"
        case .CodeLangMMY: return "de"
        }
    }
    
    // 지역 코드
    var localeCode: String {
        switch self {
        case .CodeLangKOR: return "ko"
        case .CodeLangUSA: return "en"
        case .CodeLangCHN: return "zh"
        case .CodeLangVNM: return "vi"
        case .CodeLangTHA: return "th"
        case .CodeLangIDN: return "in"
        case .CodeLangMNG: return "mn"
        case .CodeLangCAM: return "km"
        case .CodeLangUZB: return "uz"
        case .CodeLangMMR: return "my"
        case .CodeLangLKA: return "si"
        case .CodeLangNPL: return "ne"
        case .CodeLangRUS: return "ru"
        case .CodeLangPHI: return "tl"
        case .CodeLangBGD: return "bn"
        case .CodeLangPAK: return "ur"
        case .CodeLangLAO: return "lo"
        case .CodeLangMMY: return "my"
        }
    }
    
    // 서버값 체크 (2020.11.20) MVNO_ID
    var countryCode: String {
        switch self {
        case .CodeLangKOR: return "kr"  // 한국 - 820
        case .CodeLangUSA: return "us"  // 미국 - 없음
        case .CodeLangCHN: return "cn"  // 중국 - 8786
        case .CodeLangVNM: return "vn"  // 베트남 - 84
        case .CodeLangTHA: return "th"  // 태국 - 660
        case .CodeLangIDN: return "id"  // 인도 - 910
        case .CodeLangMNG: return "mn"  // 몽골 - 976
        case .CodeLangCAM: return "kh"  // 캄보디아 - 855
        case .CodeLangUZB: return "uz"  // 우즈베키스탄 - 9981
        case .CodeLangMMR: return "mm"  // 미얀마 - 95
        case .CodeLangLKA: return "lk"  // 스리랑카 - 94
        case .CodeLangNPL: return "np"  // 네팔 - 977
        case .CodeLangRUS: return "ru"  // 러시아 - 70
        case .CodeLangPHI: return "ph"  // 필리핀 - 63
        case .CodeLangBGD: return "bd"  // 방글라데시 - 880
        case .CodeLangPAK: return "pk"  // 파키스탄 - 92
        case .CodeLangLAO: return "la"  // 라오스 - 없음
            // 카자흐스탄 : kz 8700
            // 키르기스스탄 : kg 8705
            // 타지키스탄 : tj 8710
            // 우크라이나 : ua 8715
            // 터키 : tr 8720
            // 아랍에미리트 : ae 8725
            // 나이지리아 : ng 8730
            // 가나 : gh 8740
            // 알제리 : dz 8745
            // 인도네시아 : id 62
            // 말레이시아 : my 8760
        case .CodeLangMMY: return "mm" // 미얀마 - 95
        }
    }
    
    var nationName: String {
        switch self {
        case .CodeLangKOR: return "한국어"
        case .CodeLangUSA: return "English"
        case .CodeLangCHN: return "中國語"
        case .CodeLangVNM: return "Tiếng Việt"
        case .CodeLangTHA: return "ภาษาไทย"
        case .CodeLangIDN: return "Indonesia"
        case .CodeLangMNG: return "Монгол хэл"
        case .CodeLangCAM: return "ភាសាខ្មែរ"
        case .CodeLangUZB: return "O'zbekiston"
        case .CodeLangMMR: return "Myanmar"
        case .CodeLangLKA: return "සිංහල"
        case .CodeLangNPL: return "नेपाली भाषा"
        case .CodeLangRUS: return "Pусский"
        case .CodeLangPHI: return "Filipino/Tagalog"
        case .CodeLangBGD: return "Bangladesh/Bengali"
        case .CodeLangLAO: return "Laos"
        case .CodeLangPAK: return "Pakistan"
        case .CodeLangMMY: return "Myanmar (Unicode)"
        }
    }
    
    var nationCode: String {
        switch self {
        case .CodeLangKOR: return "KOR"
        case .CodeLangUSA: return "USA"
        case .CodeLangCHN: return "CHN"
        case .CodeLangVNM: return "VNM"
        case .CodeLangTHA: return "THA"
        case .CodeLangIDN: return "IDN"
        case .CodeLangMNG: return "MNG"
        case .CodeLangCAM: return "KHM"
        case .CodeLangUZB: return "UZB"
        case .CodeLangMMR: return "MMR"
        case .CodeLangLKA: return "LKA"
        case .CodeLangNPL: return "NPL"
        case .CodeLangRUS: return "RUS"
        case .CodeLangPHI: return "PHL"
        case .CodeLangBGD: return "BGD"
        case .CodeLangLAO: return "LAO"
        case .CodeLangPAK: return "PAK"
        case .CodeLangMMY: return "MMY"
        }
    }
}
