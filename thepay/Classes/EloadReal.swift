//
//  EloadReal.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

// 우즈벡 전기 (다이나믹 뷰)
// 네팔 전기 (다이나믹 뷰)
// 네팔 인터넷 (리모트 뷰)

/*
 네팔 테스트 계정 요청
 */

struct EKey {
    static let requestDynamicView = "requestDynamicView"
    
    // function
    static let eloadCalcurate = "eloadCalcurate"
    static let setPrefix = "setPrefix"
    
    // type
    static let show = "show"
    static let hide = "hide"
    
    // viewType
    static let nationSpinner = "nationSpinner"
    static let spinner = "spinner"
    static let text = "text"
    static let image = "image"
    static let category = "category"
    static let boxLabel = "boxLabel"
    
    // inputType
    static let email = "email"
    static let number = "number"
    static let date = "date"
    static let password = "password"
    
    // prefix
    static let separator = ".$"
    static let prefix = "{"
    static let prefixSharp = "{#"
    static let suffix = "}"
    
    // apiValue
    static let inputValue = "{$inputValue}"
    static let getPrefix = "{$getPrefix}"
    static let getCountryCode = "{$getCountryCode}"
    
    // apiKey
    static let CTN = "CTN"
}

struct EloadRealResponse: ResponseAPI {
    
    enum FunctionArgs: Codable {
        case string([String])
        case arg([arg])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([String].self) {
                self = .string(x)
                return
            }
            if let x = try? container.decode([EloadRealResponse.arg].self) {
                self = .arg(x)
                return
            }
            throw DecodingError.typeMismatch(FunctionArgs.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for FunctionArgs"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let x):
                try container.encode(x)
            case .arg(let x):
                try container.encode(x)
            }
        }
    }
    
    enum APIValue: Codable {
        case string(String)
        case double(Double)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            if let x = try? container.decode(Double.self) {
                self = .double(x)
                return
            }
            throw DecodingError.typeMismatch(APIValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for APIValue"))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let x):
                try container.encode(x)
            case .double(let x):
                try container.encode(x)
            }
        }
        
        var raw: String {
            switch self {
            case .string(let str):
                return str
            case .double(let d):
                return String(d)
            }
        }
    }
    
    struct param: Codable {
        var key: String
        var value: String
        
        private enum CodingKeys: String, CodingKey {
            case key, value
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            key = (try? values.decode(String.self, forKey: .key)) ?? ""
            value = (try? values.decode(String.self, forKey: .value)) ?? ""
        }
    }
    
    /* View의 속성정의 객체 */
    struct attr: Codable {
        var margin: margin?             /* View의 margin 값 정의 객체 */
        var countryCode: String?        /* 컨텐츠 앞에 수정 불가능한 국가코드(prefix) 삽입 */
        var inputPrefix: String?        /* 컨텐츠 앞에 수정 불가능한 prefix 삽입 */
        var inputType: String?          /* 키보드 타입을 위한 email, number, password, date 종류 */
        var max_val: String?            /* {$inputValue} 사용 시, 컨텐츠의 최대길이 체크용도*/
        var autoCompleteType: String?   /* 이로드 저장 타입 id, email, num */
        var min_val: String?            /* {$inputValue} 사용 시, 컨텐츠의 최소길이 체크용도*/
        var text: String?               /* 표시될 내용 */
        var hint: String?               /* 표시될 힌트 삽입 */
        var textColor: String?          /* [사용안함] */
        var contentUrl: String?         /* 이미지 Url */
    }
    
    /* View의 margin 값 정의 객체 */
    struct margin: Codable {
        var margin_bottom: Double?      /* margin-top의 인수 (안드로이드:dp) */
        var margin_top: Double?         /* margin-left의 인수 (안드로이드:dp) */
        var margin_right: Double?       /* margin-right의 인수 (안드로이드:dp) */
        var margin_left: Double?        /* margin-bottom의 인수 (안드로이드:dp) */
    }
    
    struct arg: Codable {
        var amount: Double?
        var exRateFlag: String?
        var cost: Double?
        var countryCode: String?
        var rcgType: String?
        var prodId: String?
        var param: [param]?
    }
    
    /* Native 함수호출에 사용 됨 */
    struct function: Codable {
        var arg: FunctionArgs?          /* 함수에 전달할 인수 값 */
        var type: String?               /* 함수 타입 */
    }
    
    /* spinner 아이템 리스트 */
    struct item: Codable {
        var sortNo: Double?
        var apiValue: [APIValue]?       /* View의 변수값 (spinner만) */
        var itemCode: String?           /* 아이템 코드값 */
        var function: [function]?       /* Native 함수호출에 사용 됨 */
        var text: String?               /* 표시될 내용 */
        
        static func ==(left: item, right: item) -> Bool {
            return left.itemCode == right.itemCode && left.text == right.text
        }
    }
    
    // 클래스 타입 (값을 수정할 필요가 있어서 클래스 타입으로 선언)
    class eloadList: Codable {
        var sortNo: Double?             /* 노출 순서 */
        var apiKey: [String]?           /* View의 변수 */
        var apiValue: [APIValue]?       /* View의 변수값 */
        var viewtype: String?           /* View 유형 */
        var id: String?                 /* View의 id. */
        var type: String?               /* show일 때, 활성화. hide일 때, 비활성화(화면에 그리지 않음) */
        var attr: attr?                 /* View의 속성정의 객체 */
        var item: [item]?               /* spinner 아이템 리스트 */
        var contentUrl: String?         /* 이미지 Url */
        
        // 추가 변수
        var selectItemIndex: Int?       /* 선택된 인덱스 */
        
        func getIndex() -> Int {
            if let idx = selectItemIndex {
                return idx
            } else {
                return 0
            }
        }
    }
    
    /* API 호출을 위해 사용 */
    struct interface: Codable {
        var apiKey: [String]?           /* API 요청시 전달할 파라메터 Key */
        var apiValue: [APIValue]?       /* API 요청시 전달할 파라메터 Value */
        var apiId: String?              /* API의 id */
    }
    
    struct O_DATA: Codable {
        var eloadList: [eloadList]?
        var interface: [interface]?
    }
    
    var O_DATA: O_DATA?
    var O_CODE: String
    var O_MSG: String
}

class EloadRealRequest: RequestAPI {
    
    struct Param {
        var mvnoId: String
        var itemId: String
    }
    
    var param: Param
    
    init(param: Param) {
        self.param = param
    }
    
    override func getAPI() -> String? {
        return API.shared.serviceURL.eload_real
    }
    
    override func getParam() -> [String : Any]? {
        
        let params = [
            Key.ANI                 : ani,
            Key.pinNumber           : pinNumber,
            Key.USER_ID             : uuid,
            Key.LANG                : langCode,
            Key.mvnoId              : param.mvnoId,
            Key.EloadReal.prodItem  : param.itemId
        ]
        
        return params
    }
}

/*
 EXCEL LINE 40 ~ 49
 
 ANI                : 단말기 전화번호 없으면 NULL
 pinNumber          : 사용자 고유의 식별용 PIN 번호
 USER_ID            : 안드로이드 : GMAIL   , IOS -UUID
 LANG               : 단말기 언어 없으면 NULL
 mvnoId             : 국가 구분 코드 998 , 977
 EloadReal.prodItem : 현재는 사용안함. 추후 사용할수 있음.
 */
