//
//  RegularViewController.swift
//  thepay
//
//  Created by xeozin on 2020/08/10.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

class RegularViewController: TPAutoCompleteViewController, TPLocalizedController {
    
    enum ButtonType: Int {
        case left = 0
        case center = 1
        case right = 2
    }
    
    @IBOutlet weak var lblPhoneTitle: UILabel!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblChargeAmountTitle: UILabel!
    
    @IBOutlet weak var tfProdDesc: TPTextField!
    @IBOutlet weak var lblAddInfo: TPLabel!
    @IBOutlet weak var tfAmount: TPTextField!
    
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnCenter: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    @IBOutlet weak var btnRegular: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    
    @IBOutlet weak var lblNavTitle: TPLabel!
    @IBOutlet weak var lblNavSubTitle: TPLabel!
    
    var paymentViewController: PaymentViewController?
    var type:IntegrateType?
    
    var ppsList:[SubPreloadingResponse.pps]? = nil
    var selectProds:[SPMenuData<SubPreloadingResponse.pps.rcgList>]?
    var prodType: ProdType = .normal
    var selectedButton: ButtonType?
    var prodCode: ProdCode?
    
    var changeView:((_ type:IntegrateType)->Void)?
    
    var menuManager:MenuManager<SubPreloadingResponse.pps.rcgList> = MenuManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func localize() {
        lblPhoneTitle.text = Localized.recharge_number.txt
        lblProductTitle.text = Localized.recharge_goods.txt
        lblChargeAmountTitle.text = Localized.recharge_amount.txt
        
        self.btnRegular.setTitle(Localized.tab_title_charge_normal.txt, for: .normal)
        self.btnMonthly.setTitle(Localized.tab_title_charge_monthly.txt, for: .normal)
    }
    
    func initialize() {
        menuManager.menu?.selectItem = { [weak self] in
            if let data = $0 {
                self?.tfAmount.text = data.mvnoName
                self?.updatePaymentView(data: data)
            }
        }
        
        
        
        tfPhone.delegate = self
    }
    
    func updateRegularData(data: [SubPreloadingResponse.pps]?) {
        ppsList = data
        setProductType()
        getChargeGoodsList()
        updatePhoneNumber()
    }
    
    func updateButtonState(type: IntegrateType, menu: NavContents) {
        switch type {
        case .regular:
            btnRegular.isSelected = true
            btnMonthly.isSelected = false
        case .monthly:
            btnRegular.isSelected = false
            btnMonthly.isSelected = true
        }
        
        self.lblNavTitle.text = menu.title
        self.lblNavSubTitle.text = menu.subTitle
    }
    
    private func hasCtn() -> Bool {
        if let cnt = self.params?.count {
            return cnt > 2
        } else {
            return false
        }
    }
    
    private func setProductType() {
        // 일반 / 데이터
        if let prodType = ProdType(rawValue: self.params?["product_type"] as? String ?? "") {
            self.prodType = prodType
        }
        
        switch self.prodType {
        case .data:
            prodCode = .D
        case .normal:
            prodCode = .V
        case .special:
            prodCode = .L
        }
    }
    
    private func updatePhoneNumber() {
        // 전화번호 정보가 파라미터에 있다고 판단 (authCtn 통신 안함)
        if hasCtn() {
            if let ctn = self.params?["ctn"] as? String {
                self.tfPhone.text = Utils.format(phone: ctn)
            } else {
                self.tfPhone.text = Utils.updatePhoneNumber()
            }
            guard let index = ProdType(rawValue: self.params?["product_type"] as? String ?? "")?.index else { return }
            let rcgAmt = self.params?["rcg_amt"] as? String
            self.selectRecharegProducts(index: index, amount: rcgAmt ?? "")
        } else {
            self.tfPhone.text = Utils.updatePhoneNumber()
        }
    }
    
    private func selectRecharegProducts(index: Int, amount: String = "") {
        guard let ppsListCnt = self.ppsList?.count else { return }
        // xeozin_2020/09/19 modify: index out of range
        switch ppsListCnt {
        case ButtonType.center.rawValue: // 예외 경우 count: 1라서 중간, 마지막 버튼
            self.btnCenter.setBackgroundImage(nil, for: .normal)
            self.btnCenter.isUserInteractionEnabled = false
        case ButtonType.right.rawValue: // 국가 한국인 경우 count: 2라서 마지막 버튼
            self.btnRight.setBackgroundImage(nil, for: .normal)
            self.btnRight.isUserInteractionEnabled = false
        default: break
        }
        
        if index >= ppsListCnt {    // 눌림방지
            return
        }
        
        if let buttonType = selectedButton {
            if buttonType.rawValue == index {
                return
            }
        }
        
        switch index {
        case ButtonType.left.rawValue:
            self.btnLeft.isSelected = true
            self.btnCenter.isSelected = false
            self.btnRight.isSelected = false
            self.selectedButton = .left
        case ButtonType.center.rawValue:
            self.btnLeft.isSelected = false
            self.btnCenter.isSelected = true
            self.btnRight.isSelected = false
            self.selectedButton = .center
        case ButtonType.right.rawValue:
            self.btnLeft.isSelected = false
            self.btnCenter.isSelected = false
            self.btnRight.isSelected = true
            self.selectedButton = .right
        default:
            print("NONE")
        }
        
        self.selectProds = MenuDataConverter.regularAmount(value: self.ppsList?[index].rcgList)
        menuManager.updateData(data: self.selectProds ?? [])
        
        tfProdDesc.text = self.ppsList?[index].ppsName
        
        // xeozin_2021/06/07 네비게이션 기능 추가
        updateNavTitle(index: index)
        
        
    }
    
    private func updateNavTitle(index: Int) {
        if let p = self.parent as? IntegrateViewController {
            switch index {
            case ButtonType.left.rawValue:
                p.updateNavTitle(prodType: .normal)
            case ButtonType.center.rawValue:
                p.updateNavTitle(prodType: .special)
            case ButtonType.right.rawValue:
                p.updateNavTitle(prodType: .data)
            default:
                print("NONE")
            }
        }
    }
    
    override func updatePhoneNumber(ctn: String) {
        requestAuthCtn(ctn: ctn)
    }
    
    private func requestAuthCtn(ctn: String) {
        if let p = self.parent as? IntegrateViewController {
            p.authCtnData = nil
            p.ctn = ctn
            p.requestAuthCtn()
            
            self.autoComplete?.autoTableView(hidden: true)
            self.tfPhone.text = Utils.format(phone: ctn)
        }
    }
    
    func invalidateAutoComplete() {
        self.autoComplete?.timer?.invalidate()
    }
}

extension RegularViewController {
    // 버튼을 드로잉한다.
    // ProductCode 와 같은 데이터일 경우 인덱스를 선택한다.
    private func getChargeGoodsList() {
        
        // 값이 없으면 메인으로 이동
        guard let list = self.ppsList else {
            Localized.toast_msg_connect_fail.txt.showErrorMsg(target: self.view)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        // 값이 0개면 메인으로 이동
        if list.count < 1 {
            Localized.toast_msg_connect_fail.txt.showErrorMsg(target: self.view)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        // 데이터 조회후 화면 렌더링
        let index = searchData(list: list)
        self.selectRecharegProducts(index: index)
    }
    
    private func searchData(list: [SubPreloadingResponse.pps]) -> Int {
        var buttonIndex = 0
        
        for (idx, pps) in list.enumerated() {
            if pps.rcgList?.first?.rcgType == self.prodCode?.rawValue {
                self.selectProds = MenuDataConverter.regularAmount(value: pps.rcgList)
                menuManager.updateData(data: self.selectProds ?? [])
                buttonIndex = idx
            }
            
            drawButton(idx: idx, pps: pps)
        }
        
        return buttonIndex
    }
    
    private func drawButton(idx: Int, pps: SubPreloadingResponse.pps) {
        if let buttonType: ButtonType = ButtonType(rawValue: idx) {
            var btn: UIButton?
            
            switch buttonType {
            case .left:
                btn = self.btnLeft
            case .center:
                btn = self.btnCenter
            case .right:
                btn = self.btnRight
            }
            
            if let b = btn {
                guard let imageDefaultUrl = URL(string: pps.imageDefaultUrl ?? "") else { return }
                guard let imageSelectUrl = URL(string: pps.imageSelectUrl ?? "") else { return }
                // b.setTitle(pps.title, for: .normal)
                b.sd_setBackgroundImage(with: imageDefaultUrl, for: .normal)
                b.sd_setBackgroundImage(with: imageSelectUrl, for: .selected)
                b.imageView?.contentMode = .scaleAspectFit
                b.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
                b.titleLabel?.numberOfLines = 2
                b.isHidden = false
            }
        }
    }
}

extension RegularViewController {
    
    // IntegrateViewController authCtn 통신후 요청되는 작업
    func updateCtn(data: AuthCtnResponse?, changeProd: Bool = true) {
        guard let d = data?.O_DATA else { return }
        if let ctn = d.ctn {
            self.tfPhone.text = Utils.format(phone: ctn)
        }
        
        // 직접 선택한 경우 전화번호만 변경하고 리턴한다.
        if !changeProd {
            return
        }
        
        drawAddtionInfo(data: d)
        
        // 스페셜이면 상품을 가운데로 고정한다. (아니라면 레귤러로 이동한다.)
        if isSpecial(data: d) {
            self.selectRecharegProducts(index: ButtonType.center.rawValue)
        } else {
            self.selectRecharegProducts(index: ButtonType.left.rawValue)
        }
    }
    
    // Addtion 정보 추가
    private func drawAddtionInfo(data: AuthCtnResponse.O_DATA) {
        var addInfoString = ""
        if let addInfo = data.addInfo?.balance {
            addInfoString = addInfo
        }
        
        if let expiredt = data.addInfo?.expiredt {
            addInfoString = "\(addInfoString)\n\(expiredt)"
        }
        
        self.lblAddInfo.text = addInfoString
        self.lblAddInfo.isHidden = addInfoString.count > 0
    }
    
    // 음성 스페셜 확인
    private func isSpecial(data: AuthCtnResponse.O_DATA) -> Bool {
        guard let ppsListCnt = self.ppsList?.count else { return false }
        guard let type = ProdCode(rawValue: data.rcgtype ?? "") else { return false }
        guard let plan = data.plan else { return false }
        
        return ppsListCnt == 3 && type == .L && plan == "special"
    }
}

extension RegularViewController {
    
    // 충전
    func charge() {
        if let ctn = self.tfPhone.text?.removeDash() {
            self.paymentViewController?.charge(ctn: ctn)
        }
    }
    
    // 상품 금액 선택
    @IBAction func showAmount(_ sender: UIButton) {
        menuManager.show(sender: sender)
        // 자동완성 끄기
        self.autoComplete?.autoTableView(hidden: true)
    }
    
    private func updatePaymentView(data: SubPreloadingResponse.pps.rcgList) {
//        self.selectProd = data
        if let mvnoId = data.mvnoId?.rawInt {
            let data = ProductData(mvnoId: mvnoId,
                                   rcgType: data.rcgType ?? "",
                                   price: Int(data.amounts ?? "0") ?? 0)
            
            self.paymentViewController?.updateProductData(data: data)
        }
    }
    
    // 음성 일반
    @IBAction func onClickLeft(_ sender: TPButton) {
        sender.debounce(delay: 0.1) { [weak self] in
            guard let self = self else { return }
            self.selectRecharegProducts(index: ButtonType.left.rawValue)
        }
    }
    
    // 음성 스페셜
    @IBAction func onClickCenter(_ sender: TPButton) {
        sender.debounce(delay: 0.1) { [weak self] in
            guard let self = self else { return }
            self.selectRecharegProducts(index: ButtonType.center.rawValue)
        }
    }
    
    // 데이터 일반
    @IBAction func onClickRight(_ sender: TPButton) {
        sender.debounce(delay: 0.1) { [weak self] in
            guard let self = self else { return }
            self.selectRecharegProducts(index: ButtonType.right.rawValue)
        }
    }
    
    //    xeozin 2020/09/27 reason: 연락처 권한 버튼 추가
    @IBAction func showContact(_ sender: Any) {
        Utils.getContactPermissions(vc: self, segue: "goContact", sender: sender)
    }
    
    @IBAction func chargeRegular(_ sender: Any) {
        changeView?(.regular)
    }
    
    @IBAction func chargeMontly(_ sender: Any) {
        changeView?(.monthly)
    }
}

extension RegularViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? PaymentViewController {
            self.paymentViewController = vc
            self.updatePaymentFirst()
            vc.paymentTitle = self.title
            vc.view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let vc = segue.destination as? AddressViewController {
            self.autoComplete?.autoTableView(hidden: true)
            switch sender {
            case is HistoryButton:
                vc.currentType = .recent
            case is ContactButton:
                vc.currentType = .country
            default:
                break
            }
            vc.addressBookType = .rechargeHistory
            vc.item = { contact in
                guard let number = contact.callNumber else { return }
                self.requestAuthCtn(ctn: number)
            }
            self.view.endEditing(true)
        }
    }
    
    private func updatePaymentFirst() {
        if let t = type {
            switch t {
            case .monthly:
                self.paymentViewController?.isFirstLoaded = false
            default:
                break
            }
        }
    }
}
