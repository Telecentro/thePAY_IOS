//
//  EasyKeyboardViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class RoundView: UIView {
    @IBOutlet var asterisk: UILabel!
}

class EasyKeyboardViewController: TPBaseViewController {
    
    var delegate: PasscodeDelegate?
    
    @IBOutlet weak var bg1: UIView!
    @IBOutlet weak var bg2: UIView!
    
    @IBOutlet var rounds: [RoundView]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: TPLabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var state: PasscodeState?
    let viewModel = PasscodeViewModel()
    var password:((String)->Void)?
    var useCase: String?
}

extension EasyKeyboardViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        localize()
    }
    
    private func setupParams() {
        if self.useCase == nil {
            self.useCase = self.params?["use_case"] as? String
        }
        
        if let state = PasscodeState(rawValue: self.useCase ?? "") {
            switch state {
            case .case5:
                makePasswordView()
            default:
                break
            }
            viewModel.state.onNext(state)
        }
    }
    
    private func makePasswordView() {
        var x = 0
        for i in rounds.reversed() {
            if x < 2 {
                i.isHidden = true
            }
            if x > 1 && x < 4 {
                i.backgroundColor = .clear
                i.asterisk.isHidden = false
            }
            x = x + 1
            
        }
        
        viewModel.keyLength = 2
    }
    
    private func addButtonTargets() {
        for btn in buttons {
            btn.addTarget(self, action: #selector(pressButton(sender:)), for: .touchUpInside)
        }
    }
    
    private func bind() {
        viewModel.state.subscribe {
            self.titleLabel.text = $0.element?.title
        }.disposed(by: viewModel.db)
        
        viewModel.errorCount.subscribe { [weak self] value in
            guard let count = value.element else { return }
            self?.errorLabel.isHidden = count == "0/0"
            self?.errorLabel.text = count
            self?.viewModel.keyString.onNext("")
        }.disposed(by: viewModel.db)
        
        viewModel.mainColor.subscribe {
            self.bg1.backgroundColor = $0.element
            self.bg2.backgroundColor = $0.element
            self.backButton.tintColor = $0.element
            for btn in self.buttons {
                btn.tintColor = $0.element
            }
        }.disposed(by: viewModel.db)
        
        viewModel.keyString.subscribe {
            let cnt = $0.element?.count ?? 0
            for i in 0..<self.viewModel.keyLength {
                self.rounds[i].asterisk.isHidden = true
            }
            for i in 0..<cnt {
                self.rounds[i].asterisk.isHidden = false
            }
        }.disposed(by: viewModel.db)
    }
    
    @objc func pressButton(sender: UIButton) {
        guard let pressedKey = sender.titleLabel?.text else { return }
        if !viewModel.canEdit { return }
        
        if !viewModel.max() {
            viewModel.appendString(key: pressedKey)
        }
        
        if viewModel.max() {
            viewModel.canEdit = false
            perform(#selector(updateState), with: nil, afterDelay: 0.2)
        }
    }
    
    @objc func updateState() {
        if let v = try? viewModel.state.value() {
            switch v {
            case .case1:
                setPincode()
            case .case2, .case3, .case4:
                correct()
            case .case5:
                setPassword()
            }
        }
    }
    
    /**
     *  핀코드 입력 (서버에 저장)
     */
    private func setPincode() {
        if viewModel.tempString?.count ?? 0 > 0 {
            if let second = try? viewModel.keyString.value(), let first = viewModel.tempString {
                if second == first {
                    password?(first)
                    self.navigationController?.popViewController(animated: false)
                } else {
                    viewModel.clearString()
                    // lblFailGuide.isHidden = false
                    // lblFailGuide.text =
                    
                    print("다시 입력 실패")
                    viewModel.canEdit = true
                }
            }
        } else {
            viewModel.tempString = try? viewModel.keyString.value()
            viewModel.clearString()
            self.titleLabel.text = Localized.text_guide_please_re_enter_pwd_for_payment.txt
            viewModel.canEdit = true
        }
    }
    
    /**
     *  카드 비번 입력 (2자리)
     */
    private func setPassword() {
        if let s = try? viewModel.keyString.value() {
            self.navigationController?.popViewController(animated: false)
            password?(s)
        }
    }
    
    /**
     *  통신 실패 예외처리 (E8905, E8906)
     */
    private func moveToPage() {
        guard let v = try? viewModel.state.value() else { return }
        
        switch v {
        case .case2:
            self.password?("")
            self.navigationController?.popViewController(animated: false)
            break
        case .case3, .case4:
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    /**
     *  AES 256 암호화
     */
    func enc(str: String) -> String {
        guard let d:Data = str.data(using: .utf8) else { return "" }
        return AES256.encryptionAES256NotEncDate(data: d).base64EncodedString()
    }
    
    /**
     *  키 렌더링
     */
    private func redraw() {
        let items = viewModel.keys.shuffled()
        
        for (index, btn) in self.buttons.enumerated() {
            btn.setTitle(items[index].title, for: .normal)
        }
    }
    
}

// MARK: 번역, 초기화
extension EasyKeyboardViewController: TPLocalizedController {
    
    func localize() { }
    
    func initialize() {
        addButtonTargets()
        bind()
        redraw()
        setupParams()
    }
    
}

extension EasyKeyboardViewController {
    /**
     *  키 입력 백스페이스
     */
    @IBAction func pressBackButton(sender: UIButton) {
        viewModel.removeString()
    }
}

// MARK: lock
extension EasyKeyboardViewController {
    
    public func lock() {
        if !viewModel.isEmptyPasscode() {
            viewModel.updateState(state: .case1)
        }
    }
    
    @available(iOS 11.0, *)
    public func authenticationWithBiometrics() {
        if viewModel.authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            DispatchQueue.main.async {
                switch self.viewModel.authContext.biometryType {
                case .faceID, .touchID:
                    self.viewModel.authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "dd") { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.viewModel.keyString.onNext("000000")
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            if let err = error {
                                print(err.localizedDescription)
                            }
                        }
                    }
                    break
                case .none:
                    break
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
}

// MARK: 통신
extension EasyKeyboardViewController {
    private func correct() {
        guard let pin = try? viewModel.keyString.value() else { return }
        self.showLoadingWindow()
        let str = enc(str: pin)
        let params = CheckEasyRequest.Param(easyPayAuthNum: str)
        let req = CheckEasyRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<CheckEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                if data.O_CODE == FLAG.SUCCESS {
                    // "use_case 4"
                    // 두번째 카드등록시 비밀번호 체크 성공 -> 간편결제 카드사진 찍는 Step2 호출
                    switch self.useCase {
                    case "2":
                        // 간편결제로 결제진행하기 클릭 후 비밀번호 체크성공 -> 이전화면으로 돌아가서 결제 API호출
                        self.password?(str)
                        self.navigationController?.popViewController(animated: false)
                        break
                    case "3":
                        // 내정보에서 카드리스트 노출
                        SegueUtils.parseMoveLink(target: self, link: "thepay://page.easypay_list", addParams: Timemachine.pSelf)
                        break
                    case "4":
                        SegueUtils.parseMoveLink(target: self, link: "thepay://page.easypay?tab_type=2")
                    default:
                        break
                    }
                } else if data.O_CODE == FLAG.E0002 {
                    self.viewModel.increaseErrorCount(failCnt: data.O_DATA?.failCnt ?? "")
                } else if data.O_CODE == FLAG.E8906 {
                    self.viewModel.resetErrorCount()
                    
                    self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: data.O_MSG) {
                        self.moveToPage()
                    } cancel: {
                        self.moveToPage()
                    }
                }
                break
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.viewModel.canEdit = true
            self.hideLoadingWindow()
        }
    }
}
