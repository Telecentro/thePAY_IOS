//
//  TPError.swift
//  thepay
//
//  Created by xeozin on 2020/07/25.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

/*
 **통신 실패시 따로 처리 된 사항 없음
 **OCMapper 사용 시 기본적으로 property 맵핑이 자동으로 이루어진다
 이때 _가 OCMapper 내부적으로 제거되어 맵핑된다.
 */

// 이외의 에러코드는 전부 else 로 빠져 Error Msg 출력

enum TPError: Error {
    case error(code: String, msg: String)
    case nilError(code: String, msg: String)
    case e9999(code: String, msg: String)
    case e1087(code: String, msg: String)
    case timeout(code: String, msg: String)
    case expired(code: String, msg: String)
    case checkSMS(code: String, msg: String)
    case retry(code: String, msg: String)
}

enum ResultCode: String {
    case success        = "0000"    // 성공 : 성공으로 success completion에 O_DATA 만을 전달
    case code9999       = "9999"    // 가입자 조회 실패 시 9999 : 가입자 조회 시 찾지 못했을 시 내려오는 코드 0000과 동일하게 판단
    case code1087       = "1087"    // SKT 후불 데이터 충전에서 선불폰 유저 충전 불가 선불폰 유저 충전 시도시 팝업 메시지
    case resDataNil     = "60000"   // JSON Error
    case jsonError      = "50000"   // JSON Error
    case timeout        = "40000"   // 타임아웃 : (가입자 조회 : 5초, default : 20초)
    case errorSession   = "8XXX"    // 8xxx 리턴코드 : 세션종료 (8001 :  ipin 으로 고객이 검색이 안될때, 8888 :  오라클 exception)
    case checkSMS       = "6000"    // SMS 인증
    
    // 예외케이스
    case errorPin       = "0002"    // 핀번호 실패
    case errorPin2      = "0001"    // 핀번호 실패 (T 번호 입력시)
    case e8905          = "8905"    // 실패
    case e8906          = "8906"    // 실패
    case retry          = "-9"      // 재시도
}

extension Error {
    func showErrorMsg(target: UIView) {
        target.hideAllToasts()
        target.makeToast(self.localizedDescription, duration: K.toast_duration, position: .center)
    }
}

extension String {
    func showErrorMsg(target: UIView?) {
        if let target = target {
            target.hideAllToasts()
            target.makeToast(self, duration: K.toast_duration, position: .center)
        }
        
    }
}

extension TPError {
    enum ProcessType {
        case basic
        case remain
        case recharge_preview
        case ccd_v2
    }
    
    // 1. 토스트 팝업
    // 2. 인트로 이동
    func netFailRoot(_ target: UIViewController) {
        switch self {
        case .nilError(_, let msg):
            "\(Localized.alert_title_confirm.txt)\nRSP: \(msg)".showErrorMsg(target: target.view)
            target.navigationController?.backToIntro()
        default:
            break
        }
        
    }
    
    // 1. 팝업 노출
    // 2. 확인
    // 3. 인트로 이동
    private func expiredRoot(_ target: UIViewController) {
        switch self {
        case .expired(_, let msg),
             .timeout(_, let msg):
            target.showConfirmAlertSystem(title: Localized.alert_title_confirm.txt, message: msg) {
                target.navigationController?.backToIntro()
            }
        default:
            break
        }
    }
    
    // 1. HTML 노출 (CCD_VD)
    private func failToMain(_ target: UIViewController) {
        switch self {
        case .error(_, let msg):
            target.showConfirmHTMLAlert(title: Localized.alert_title_confirm.txt, htmlString: msg) {
                App.shared.isRemainsInfoChanged = true
                // 메인으로 이동
                // target.navigationController?.popToRootViewController(animated: true)
                
                // 카드 결제 실패시 - 이전 단계로 이동 2021.03.11
                target.navigationController?.popViewController(animated: true)
            }
        default:
            break
        }
    }
    
    // 1. HTML 노출
    private func showHTML(_ target: UIViewController) {
        switch self {
        case .error(_, let msg):
            target.showConfirmHTMLAlert(title: Localized.alert_title_confirm.txt, htmlString: msg)
        default:
            break
        }
    }
    
    // 1. 팝업 노출
    private func showAlert(_ target: UIViewController) {
        switch self {
        case .e1087(_, let msg):
            target.showConfirmAlertSystem(title: Localized.alert_title_confirm.txt, message: msg)
        default:
            break
        }
    }
    
    func processError(target: UIViewController, type: ProcessType = .basic) {
        switch self {
        case .nilError:
            self.netFailRoot(target)
        case .timeout:
            switch type {
            case .basic:
                self.netFailRoot(target)        /* [timeout, basic] */
            default:
                break
            }
        case .e1087:
            switch type {
            case .recharge_preview:
                showAlert(target)           /* [e1087, recharge_preview] */
            default:
                break
            }
        case .expired:
            expiredRoot(target)
        case .error:
            switch type {
            case .ccd_v2:
                failToMain(target)
            default:
                showHTML(target)
            }
            
        case .e9999:
            showErrorMsg(target: target.view)
        case .retry:
            if let topVC = UIApplication.topViewController() as? IntroViewController {
                /* LOAD LOCALIZED LANGUAGE BUNDLE */
                topVC.showCheckHTMLAlert(popupType: .retry, title: nil, htmlString: Localized.warning_network_not_accesse_preloading.txt) {
                    topVC.requestAPI()
                } cancel: {
                    exit(0)
                }

            }
        case .checkSMS:
            if let t = target as? TPBaseViewController {
                SegueUtils.openDirectMenu(target: t, link: .register)
            }
        }
    }
    
    func showErrorMsg(target: UIView) {
        target.hideAllToasts()
        switch self {
        case .error(code: _, let msg),
             .expired(code: _, let msg),
             .nilError(code: _, let msg),
             .e9999(code: _, let msg),
             .e1087(code: _, let msg),
             .timeout(code: _, let msg),
             .checkSMS(code: _, let msg),
             .retry(code: _, let msg):
            target.makeToast(msg, duration: K.toast_duration, position: .center)
        }
    }
}

