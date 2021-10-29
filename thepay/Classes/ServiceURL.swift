//
//  ServiceURL.swift
//  thepay
//
//  Created by xeozin on 2020/06/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
//import Toast_Swi

enum ServiceURL {
    case dev
    case dev2
    case real
    
    // API 요청 정보
    var baseURL: String {
        switch self {
        case .dev:
            return "http://61.111.2.224:7944/Pay010MobileApi/mobile_api/"
        case .dev2:
            return "http://61.111.2.158:7944/Pay010MobileApi/mobile_api/"
        case .real:
            return "https://thePAY.010pay.co.kr/Pay010MobileApi/mobile_api/"
        }
    }
    
    var webCacheURL: String {
        switch self {
        case .dev, .dev2:
            return "http://61.111.2.224:7943/cacheLoad.html"
        case .real:
            return "https://thepayw.010pay.co.kr/cacheLoad.html"
        }
    }
    
    var baseURLName: String {
        switch self {
        case .dev:
            return "61.111.2.224:7944"
        case .dev2:
            return "61.111.2.158:7944"
        case .real:
            return "thePAY.010pay.co.kr"
        }
    }
}

/**
 * 초기화 관련
 */
extension ServiceURL {
    
    // 언어선택 --> 권한설정 --> 약관동의 --> 로그인페이지
    // 약관동의 <--> 로그인페이지 사이
    var precheck: String {
        return "\(baseURL)pAppPreCheck.do"
    }
    
    //-프리로딩 변경 1.1.18 부터 //1.4.0 에 신규 추가
    var preloading_v7: String {
        return "\(baseURL)pAppPreloadingIosV7.do"
    }
    
    var preloading_v8: String {
        return "\(baseURL)pAppPreloadingIosV8.do"
    }
    
    var preloading_v9: String {
        return "\(baseURL)pAppPreloadingIosV9.do"
    }
    
    var preloading_v10: String {
        return "\(baseURL)pAppPreloadingIosV10.do"
    }
    
    var preloading_v11: String {
        return "\(baseURL)pAppPreloadingIosV11.do"
    }
    
    var subPreloading: String {
        return "\(baseURL)pAppSubPreloadingIosV2.do"
    }
    
    var pAppWebViewCacheUsable: String {
        return "\(baseURL)pAppWebViewCacheUsable.do"
    }
    
    var pAppPreFindUser: String {
        return "\(baseURL)pAppPreFindUser.do"
    }
}

/**
 *  Eload
 */
extension ServiceURL {
    //Eload View 관련
    var eload_real: String {
        return "\(baseURL)pAppPreloadingEloadV3.do"
    }
    
    //Eload Dynamic View 관련
    var eload_dynamic: String {
        return "\(baseURL)pAppDynamicView.do"
    }
    
    //Eload Sub Preloading
    var eload_sub_preloading: String {
        return "\(baseURL)pAppSubPreloadingIosV2.do"
    }
    
    //ELoad 상품조회
    var eload_remote: String {
        return "\(baseURL)pAppRemoteView.do"
    }
}

/**
 *  인증 / 조회
 */
extension ServiceURL {
    
    // SMS 인증
    var sms_auth: String {
        return "\(baseURL)pAppSmsAuth.do"
    }
    
    // 잔액 조회
    var remains: String {
        return "\(baseURL)pAppRemains.do"
    }
    
    // KTPos 잔액조회
    var ktpos_remains: String {
        return "\(baseURL)pAppKtposRemains.do"
    }
    
    // SKB 잔액조회
    var skb_remains: String {
        return "\(baseURL)pAppSkbRemains.do"
    }
}

/**
 *  충전 / 공통
 */
extension ServiceURL {
    
    // pAppRcg.do (V1)
    // 선불, 국제카드 공통 호출 부분 (V2)
    var recharge_preview: String {
        return "\(baseURL)pAppRcgV4.do"
    }
    
    // 다우
    var payment_daou: String {
        return "\(baseURL)authCardPaymentDaou.do"
    }
    
    // 이니시스
    var payment_inicis: String {
        return "\(baseURL)authCardPaymentInicis.do"
    }
    
    // CASH로 충전
    var recharge_cash: String {
        return "\(baseURL)pAppRcgCASH.do"
    }
    
    // 은행계좌로 충전
    var recharge_account: String {
        return "\(baseURL)pAppRcgVBA.do"
    }
    
//    // 카드로 충전
//    var recharge_credit: String {
//        return "\(baseURL)pAppRcgCCD.do"
//    }
    
    // 카드로 충전 (V2)
    var recharge_credit_v2: String {
        return "\(baseURL)pAppRcgCCD_V2.do"
    }
    
    // 은행계좌변경
    var change_account: String {
        return "\(baseURL)pAppUserVierAccount.do"
    }
    
    // 공지사항
    var notice_list: String {
        return "\(baseURL)pAppNoticeList.do"
    }
    
    // 공지사항
    var push_history_list: String {
        return "\(baseURL)pAppPushHis.do"
    }
    
    
    // 충전내역
    var recharge_history: String {
        return "\(baseURL)pAppRcgHis.do"
    }
    
    // 캐쉬내역
    var cash_history: String {
        return "\(baseURL)pAppCashHis.do"
    }
    
    // 포인트내역
    var point_history: String {
        return "\(baseURL)pAppPointHis.do"
    }
    
    // 가입자 조회
    var auth_ctn: String {
        return "\(baseURL)pAppAuthCtn.do"
    }
    
    // ELOAD 충전 부분
    var recharge_eload: String {
        return "\(baseURL)pAppRcgEloadV4.do"
    }

    // 편의점 충전 안내 팝업
    var cvs_notice: String {
        return "\(baseURL)pAppCVSnotice.do"
    }
    
    // 선불폰 충전 실패
    var rcg_fail_note: String {
        return "\(baseURL)pAppRcgFailNote.do"
    }
    
    // 카드 충전 제한 체크 (V3)
    var rcg_card_limte_v3: String {
        return "\(baseURL)pAppRcgCardLimte_V3.do"
    }

    // 문의하기 (v1)
    var contact_us: String {
        return "\(baseURL)pAppContactWrite.do"
    }
    
    // 문의하기 (v2)
    var contact_us_v2: String {
        return "\(baseURL)pAppContactWrite_V2.do"
    }
    
    // 문의하기 (v3)
    var contact_us_v3: String {
        return "\(baseURL)pAppContactWrite_V3.do"
    }
    
    // 문의하기 내역
    var contact_history: String {
        return "\(baseURL)pAppContactHis.do"
    }
    
    // 문의하기 파일 업로드
    var contact_upload: String {
        return "\(baseURL)pAppContactWriteForm.do"
    }
    
    // 푸시 토큰 갱신
    var push_restore: String {
        return "\(baseURL)pAppPushRestore.do"
    }
    
    // 환율 계산
    var exchange_rate: String {
        return "\(baseURL)pAppExRate.do"
    }            //환율계산
    
    // 푸시 다시 보기
    var push_review: String {
        return "\(baseURL)pAppPushReview.do"
    }

    // 체류기간 폼
    var user_form_pre: String {
        return "\(baseURL)pAppUserFormPre.do"
    }
    
    // 체류기간 업로드 - 기존 것 포함 2개 통신 존재 1개는 쓸모없음 67line
    var user_form_store: String {
        return "\(baseURL)pAppUserFormStore.do"
    }

    // 세이프 카드
    var card_form_store: String {
        return "\(baseURL)pAppUserCardFormStoreV2.do"
    }
}

extension ServiceURL {
    var easy_delete: String {
        return "\(baseURL)pAppEasyPayDel.do"
    }
    
    var easy_list: String {
        return "\(baseURL)pAppEasyPayList.do"
    }
    
    var easy_auth_account: String {
        return "\(baseURL)pAppAuthAccount.do"
    }
    
    var easy_pre: String {
        return "\(baseURL)pAppEasyPayPreValue.do"
    }
    
    var easy_check: String {
        return "\(baseURL)pAppEasyPayCheck.do"
    }
    
    var easy_reg: String {
        return "\(baseURL)pAppEasyPayReg.do"
    }
    
    var easy_pay: String {
        return "\(baseURL)pAppRcgEasyPay.do"
    }
    
    var easy_pay_limte: String {
        return "\(baseURL)pAppRcgEasyPayLimte.do"
    }
}

extension ServiceURL {
    var gift_trans_check: String {
        return "\(baseURL)pAppTransCheck.do"
    }
    var gift_trans: String {
        return "\(baseURL)pAppTrans.do"
    }
}

/**
 *  서비스 URL
 */
extension ServiceURL {
    var facebookLink: String {
        return "https://www.facebook.com/thePAYtelecentro/"
    }
    
    var thePayHomePage: String {
        return "http://www.thePAY010.com"
    }
    
    // 사용방법 앞부분
    var interCallUseRullVer1: String {
        return "http://www.thePAY010.com/contents/manual/sub?lang="
    }
    
    // 사용방법 뒷부분
    var interCallUseRullVer2: String {
        return "&item=intercall&step=1"
    }
    
    // 뒤에 언어코드가 필요
    var manyFAQ: String {
        return "http://www.thePAY010.com/contents/faq?lang="
    }
    
    // 뒤에 언어코드가 필요
    var useRull: String {
        return "https://www.thePAY010.com:7443/contents/manual?lang="
    }
}

/**
 *  웹뷰 URL
 */
extension ServiceURL {
    
    // 이용약관
    var wv_terms: String {
        return "\(baseURL)terms.do"
    }
    
    // 개인정보취급방침
    var wv_privacy: String {
        return "\(baseURL)private.do"
    }
    
    // 개인정보 수집 및 이용 동의
    var wv_collect: String {
        return "\(baseURL)privateUsageAgree.do"
    }
    
    // 간편결제 이용약관
    var wv_easy_terms: String {
        return "\(baseURL)easyPayTerms.do"
    }
    
    // 간편결제 개인정보취급방침
    var wv_easy_privacy: String {
        return "\(baseURL)easyPayPrivate.do"
    }
    
    // 간편결제 기본약관
    var wv_easy_basic: String {
        return "\(baseURL)easyPaySEFTBasicTerm.do"
    }
    
    // 개인정보취급방침 (체류기간연장)
    var wv_privacy_extendstay: String {
        return "\(baseURL)privateAgree.do"
    }
    
    // KT 요율표
    var wv_kt_url_rates: String {
        return "\(baseURL)ktPosRate.do"
    }
    
    // SK 요율표
    var wv_sk_url_rates: String {
        return "\(baseURL)pAppSkRate.do"
    }
    
    // 이용방법
    var wv_howto_thepay: String {
        return "thPayHowto.do"
    }
    
    // 국제전화충전방법
    var wv_howto_recharge_theplus: String {
        return "howtoRechargethePlus.do"
    }
    
    // 편의점바코드충전방법
    var wv_howto_convenience: String {
        return "howtoConvenience.do"
    }
}

/**
 *  새로운 API
 */
extension ServiceURL {
    // 회원 탈퇴
    var withdrawal: String {
        return "\(baseURL)pAppWithdrawal.do"
    }
    
    // 회원 탈퇴
    var withdrawalCheck: String {
        return "\(baseURL)pAppWithdrawalCheck.do"
    }
}













