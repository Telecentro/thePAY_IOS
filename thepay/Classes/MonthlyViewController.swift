//
//  MonthlyViewController.swift
//  thepay
//
//  Created by xeozin on 2020/08/10.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

class MonthlyViewController: TPAutoCompleteViewController, TPLocalizedController {
    
    @IBOutlet weak var lblPhoneTitle: TPLabel!
    @IBOutlet weak var lblTelecomTitle: TPLabel!
    @IBOutlet weak var lblChargeAmountTitle: TPLabel!
    
//    @IBOutlet weak var tfPhone: TPTextField!
    @IBOutlet weak var tfTelecom: TPTextField!
    @IBOutlet weak var tfAmountDesc: TPTextField!
    
    @IBOutlet weak var tfAmount1: TPTextField!
    @IBOutlet weak var tfAmount2: TPTextField!
    @IBOutlet weak var tfAmount3: TPTextField!
    @IBOutlet weak var tfAmount4: TPTextField!
    
    @IBOutlet weak var sv1: UIStackView!
    @IBOutlet weak var sv2: UIStackView!
    
    // 최초 HIDDEN
    @IBOutlet weak var ivTelecom: UIImageView!
    @IBOutlet weak var lblAddInfo: TPLabel!
    @IBOutlet weak var viewDesc: UIView!
    @IBOutlet weak var lblDesc: TPLabel!
    // 최초 HIDDEN END
    
    @IBOutlet weak var btnRegular: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    
    @IBOutlet weak var amountSelector1: TPDataSelector!
    @IBOutlet weak var amountSelector2: TPDataSelector!
    @IBOutlet weak var amountSelector3: TPDataSelector!
    @IBOutlet weak var amountSelector4: TPDataSelector!
    
    @IBOutlet weak var ivTelecomHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblNavTitle: TPLabel!
    @IBOutlet weak var lblNavSubTitle: TPLabel!
    
    var selector1: TPDataSelector!
    var selector2: TPDataSelector!
    var selector3: TPDataSelector!
    var selector4: TPDataSelector!
    var emptyView = UIView()
    
    var authCtnData: AuthCtnResponse?
    
    var selectTelecom: SPMenuData<SubPreloadingResponse.mthRate>?
    var selectProd: SubPreloadingResponse.amounts?
    
    var paymentViewController: PaymentViewController?
    var type:IntegrateType?
    
    var monthlyData: [SubPreloadingResponse.mthRate]?
    var showData: [SPMenuData<SubPreloadingResponse.mthRate>]?
    
    var isDataSetup = false
    
    var productSortDatas:[[SubPreloadingResponse.amounts]] = []
    
    var changeView:((IntegrateType)->Void)?
    
    var telecomMenu:MenuManager<SubPreloadingResponse.mthRate>?
    var amountMenu1:MenuManager<SubPreloadingResponse.amounts> = MenuManager()
    var amountMenu2:MenuManager<SubPreloadingResponse.amounts> = MenuManager()
    var amountMenu3:MenuManager<SubPreloadingResponse.amounts> = MenuManager()
    var amountMenu4:MenuManager<SubPreloadingResponse.amounts> = MenuManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    func initialize() {
        createMenuEvents()
        tfPhone.delegate = self
    }
    
    private func createMenuEvents() {
        var config = SPMenuConfig()
        config.font = LanguageUtils.fontWithSize(size: 14)
        telecomMenu = MenuManager(config: config)
        telecomMenu?.menu?.selectItem = { [weak self] in
            if let data = $0 {
                self?.selectTelecom = SPMenuData(title: data.mvnoName, data: data)
                self?.selectProd = $0?.amounts?.first
                self?.reloadDataWithAddInfo()
            }
        }
        
        amountMenu1.menu?.selectItem = { [weak self] in
            if let d = $0 {
                self?.updateProductData(d: d)
            }
        }
        
        amountMenu2.menu?.selectItem = { [weak self] in
            if let d = $0 {
                self?.updateProductData(d: d)
            }
        }
        
        amountMenu3.menu?.selectItem = { [weak self] in
            if let d = $0 {
                self?.updateProductData(d: d)
            }
        }
        
        amountMenu4.menu?.selectItem = { [weak self] in
            if let d = $0 {
                self?.updateProductData(d: d)
            }
        }
        
        selector1 = amountSelector1
        selector2 = amountSelector2
        selector3 = amountSelector3
        selector4 = amountSelector4
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
    
    private func updateProductData(d: Any) {
        if isDataSetup {
            if let data = d as? SubPreloadingResponse.amounts {
                DispatchQueue.main.async {
                    self.selectProd = data
                    self.updateInfo()
                    self.setAmountToAmountselectLabels()
                    self.setProductToPaymentView()
                }
            }
        }
    }
    
    func localize() {
        lblPhoneTitle.text = Localized.recharge_number.txt
        lblTelecomTitle.text = Localized.montly_plan_select_telecom_title.txt
        lblChargeAmountTitle.text = Localized.recharge_amount.txt
        tfAmountDesc.placeholder = Localized.hint_select_rate.txt
        
        self.btnRegular.setTitle(Localized.tab_title_charge_normal.txt, for: .normal)
        self.btnMonthly.setTitle(Localized.tab_title_charge_monthly.txt, for: .normal)
        
        self.lblNavTitle.text = NavContents.month.title
        self.lblNavSubTitle.text = NavContents.month.subTitle
    }
    
    private func hasCtn() -> Bool {
        if let cnt = self.params?.count {
            return cnt > 2
        } else {
            return false
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
            
            var authCtnData = AuthCtnResponse.O_DATA()
            authCtnData.ctn = self.params?["ctn"] as? String
            authCtnData.mvno = self.params?["mvno_id"] as? String
            authCtnData.rcgamt = self.params?["rcg_amt"] as? String
            
            self.findData(authCtnData: authCtnData)
        } else {
            self.tfPhone.text = Utils.updatePhoneNumber()
            self.findData(authCtnData: self.authCtnData?.O_DATA)
        }
    }
    
    private func findData(authCtnData: AuthCtnResponse.O_DATA?) {
        if let plan = authCtnData?.plan, plan == "band" {
            let originData = MenuDataConverter.mthRate(value: self.monthlyData)
            for item in originData {
                if item.data.includeBand == "Y" {
                    self.showData?.append(item)
                }
            }
        } else {
            // authCtnData가 nil 인경우
            self.showData = MenuDataConverter.mthRate(value: self.monthlyData)
        }
        
        // 최초 데이터
        selectTelecom = self.showData?.first
//        telecomSelector.telecom = self.showData ?? []
        telecomMenu?.updateData(data: self.showData ?? [])
        
        // 검출 데이터 (텔레콤 선택)
        guard let data = self.showData else { return }
        var idx = 0
        for (index, item) in data.enumerated() {
            let id = String(item.data.mvnoId ?? 0)
            if id == authCtnData?.mvno {
                self.selectTelecom = item
                idx = index
                break
            }
        }
        
        selectProd = selectTelecom?.data.amounts?.first
        telecomMenu?.menu?.reset(idx: idx)
        
        // 검출 데이터 (상품 선택)
        var hasProd = false
        var sameProd:SubPreloadingResponse.amounts?
        guard let prod = selectTelecom?.data.amounts else { return }
        guard let rcgamt = authCtnData?.rcgamt else { return }
        for item in prod {
            let cost = String(item.cost ?? 0)
            if cost == rcgamt {
                sameProd = item
                hasProd = true
            }
        }
        
        // 010-6715-6773 (모빙)
        // mvno_id 리스트에 있을 경우
        
        // mvno_id 리스트에 없는 경우
        // unknown 에서 해당 요금 처리
        // 없으면 uknown 기본값 처리 (36,300)
        if hasProd {
            self.selectProd = sameProd
        } else {
            // 초기화
            // 텔레콤 초기화
            selectTelecom = self.showData?.first
            telecomMenu?.menu?.reset()
            
            // 프로덕트 초기화
            selectProd = selectTelecom?.data.amounts?.first
            
            guard let prod = selectTelecom?.data.amounts else { return }
            guard let rcgamt = authCtnData?.rcgamt else { return }
            for item in prod {
                let cost = String(item.cost ?? 0)
                if cost == rcgamt {
                    self.selectProd = item
                }
            }
        }
    }
    
    private func updateInfo(addInfoString: String? = nil) {
        self.tfTelecom.text = self.selectTelecom?.data.mvnoName
        self.tfAmountDesc.text = self.selectProd?.prodName
        
        if let item = selectProd?.Info1, !item.isEmpty {
            let attrString = item.convertHtml(fontSize: 16)
            
            self.viewDesc.isHidden = false
            self.lblDesc.attributedText = attrString
        }
        
        if let addInfo = addInfoString, !addInfo.isEmpty {
            self.lblAddInfo.isHidden = false
            self.ivTelecom.isHidden = true
            self.lblAddInfo.text = addInfo
        } else {
            self.lblAddInfo.isHidden = true
            self.ivTelecom.isHidden = false
            if let url = URL(string: self.monthlyData?.first?.imageDefaultUrl ?? "") {
                self.ivTelecom.sd_setImage(with: url, placeholderImage: nil, options: .refreshCached) { (img, err, type, url) in
                    var ratio:CGFloat = 0
                    if let image = img {
                        ratio = image.size.height / image.size.width
                        self.ivTelecomHeight.constant = (UIScreen.main.bounds.width + 32) * ratio
                    }
                }
            }
        }
    }
    
    private func reloadDataWithAddInfo(addInfoString: String? = nil) {
        updateInfo(addInfoString: addInfoString)
        sortProductDatas()
        setAmountToAmountselectLabels()
        setProductToPaymentView()
    }
    
    private func setAmountToAmountselectLabels() {
        for (index, sortArray) in productSortDatas.enumerated() {
            var showAmount = sortArray.first
            var findAmount = false
            
            var findIndex = 0
            for (idx, amount) in sortArray.enumerated() {
                if amount.cost == self.selectProd?.cost {
                    showAmount = amount
                    findIndex = idx
                    findAmount = true
                    break
                }
            }
            
            var showAmountString = ""
            if findAmount {
                showAmountString = String(showAmount?.cost ?? 0).currency.won
            } else {
                let cost = showAmount?.cost ?? 0
                if cost < 30000 {
                    showAmountString = "￦ ~29,999"
                } else if cost < 40000 {
                    showAmountString = "￦ 30,000~"
                } else if cost < 50000 {
                    showAmountString = "￦ 40,000~"
                } else {
                    showAmountString = "￦ 50,000~"
                }
            }
            
            switch index {
            case 0:
                tfAmount1.text = showAmountString
                if findAmount {
                    print("🚑 showAmountString \(showAmountString)")
                    amountMenu1.setRow(idx: findIndex)
                }
            case 1:
                tfAmount2.text = showAmountString
                if findAmount {
                    print("🚑 showAmountString \(showAmountString)")
                    amountMenu1.setRow(idx: findIndex)
                }
            case 2:
                tfAmount3.text = showAmountString
                if findAmount {
                    print("🚑 showAmountString \(showAmountString)")
                    amountMenu1.setRow(idx: findIndex)
                }
            case 3:
                tfAmount4.text = showAmountString
                if findAmount {
                    print("🚑 showAmountString \(showAmountString)")
                    amountMenu1.setRow(idx: findIndex)
                }
            default:
                break
            }
        }
    }
    
    private func setProductToPaymentView() {
        guard let data = self.selectProd else { return }
        let d = ProductData(mvnoId: selectTelecom?.data.mvnoId ?? 0, rcgType: selectTelecom?.data.rcgType ?? "", price: data.amount ?? 0)
        d.ctn = self.tfPhone.text?.removeDash() ?? ""
        self.paymentViewController?.loadMonthlyAlarm(type: d.rcgType)
        self.paymentViewController?.updateProductData(data: d)
    }
    
    private func sortProductDatas() {
        self.isDataSetup = false
        
        var sortArr1:[SubPreloadingResponse.amounts] = []
        var sortArr2:[SubPreloadingResponse.amounts] = []
        var sortArr3:[SubPreloadingResponse.amounts] = []
        var sortArr4:[SubPreloadingResponse.amounts] = []
        
        for item in self.selectTelecom?.data.amounts ?? [] {
            if let cost = item.cost {
                if cost < 30000 {
                    sortArr1.append(item)
                } else if cost < 40000 {
                    sortArr2.append(item)
                } else if cost < 50000 {
                    sortArr3.append(item)
                } else {
                    sortArr4.append(item)
                }
            }
        }
        
        var cnt:Int = 0
        cnt = (sortArr1.count > 0 ? 1 : 0) + cnt
        cnt = (sortArr2.count > 0 ? 1 : 0) + cnt
        cnt = (sortArr3.count > 0 ? 1 : 0) + cnt
        cnt = (sortArr4.count > 0 ? 1 : 0) + cnt
        
        productSortDatas.removeAll()
        productSortDatas.append(contentsOf: [sortArr1, sortArr2, sortArr3, sortArr4])
        
        self.insertProductData(sortArray: sortArr1, target: amountMenu1, view: selector1)
        self.insertProductData(sortArray: sortArr2, target: amountMenu2, view: selector2)
        self.insertProductData(sortArray: sortArr3, target: amountMenu3, view: selector3)
        self.insertProductData(sortArray: sortArr4, target: amountMenu4, view: selector4)
        
        self.updateSelectorPosition(cnt: cnt)
        
        self.isDataSetup = true
    }
    
    private func updateSelectorPosition(cnt: Int) {
        let selector: [TPDataSelector] = [selector1, selector2, selector3, selector4]
        
        self.sv1.addArrangedSubview(selector1)
        self.sv1.addArrangedSubview(selector2)
        self.sv2.addArrangedSubview(selector3)
        self.sv2.addArrangedSubview(selector4)
        emptyView.removeFromSuperview()
        
        switch cnt {
        case 0:
            self.sv1.isHidden = true
            self.sv2.isHidden = true
            for item in selector {
                item.removeFromSuperview()
            }
        case 1:
            self.sv1.isHidden = false
            self.sv2.isHidden = true
            for item in selector {
                item.removeFromSuperview()
            }
            for item in selector {
                if !item.isHidden {
                    sv1.addArrangedSubview(item)
                }
            }
        case 2:
            self.sv1.isHidden = false
            self.sv2.isHidden = true
            for item in selector {
                item.removeFromSuperview()
            }
            for item in selector {
                if !item.isHidden {
                    sv1.addArrangedSubview(item)
                }
            }
        case 3:
            self.sv1.isHidden = false
            self.sv2.isHidden = false
            for item in selector {
                item.removeFromSuperview()
            }
            for item in selector {
                if !item.isHidden {
                    sv1.addArrangedSubview(item)
                }
            }
            
            for (index, item) in sv1.subviews.enumerated() {
                if index == 2 {
                    sv2.addArrangedSubview(item)
                    sv2.addArrangedSubview(emptyView)
                }
            }
        case 4:
            self.sv1.isHidden = false
            self.sv2.isHidden = false
        default:
            print("None")
        }
    }
    
    private func insertProductData(sortArray: [SubPreloadingResponse.amounts], target: MenuManager<SubPreloadingResponse.amounts>, view: TPDataSelector) {
        if sortArray.count > 0 {
            target.updateData(data: MenuDataConverter.mthAmount(value: sortArray))
            view.isHidden = false
        } else {
            view.isHidden = true
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

extension MonthlyViewController {
    
    func updateCtn(data: AuthCtnResponse?) {
        guard let d = data?.O_DATA else { return }
        if let ctn = d.ctn {
            self.tfPhone.text = Utils.format(phone: ctn)
        }
        
        findData(authCtnData: d)
        reloadDataWithAddInfo(addInfoString: d.addInfo?.expiredt)
    }
    
    func updateMonthData(data: [SubPreloadingResponse.mthRate]?) {
        self.monthlyData = data
        
        updatePhoneNumber()
        reloadDataWithAddInfo()
    }
    
    // 가입자 조회 실패시 2020.10.20
    func updateUnknown() {
        telecomMenu?.menu?.reset()
    }
}

extension MonthlyViewController {
    // 결제
    func charge() {
        if let ctn = self.tfPhone.text?.removeDash() {
            self.paymentViewController?.charge(ctn: ctn)
        }
    }
    
    @IBAction func showAmount1(_ sender: UIButton) {
        if amountMenu1.count() > 0 {
            amountMenu1.show(sender: sender)
        }
    }
    
    @IBAction func showAmount2(_ sender: UIButton) {
        if amountMenu2.count() > 0 {
            amountMenu2.show(sender: sender)
        }
    }
    
    @IBAction func showAmount3(_ sender: UIButton) {
        if amountMenu3.count() > 0 {
            amountMenu3.show(sender: sender)
        }
    }
    
    @IBAction func showAmount4(_ sender: UIButton) {
        if amountMenu4.count() > 0 {
            amountMenu4.show(sender: sender)
        }
    }
    
    @IBAction func showTelecom(_ sender: UIButton) {
        if telecomMenu?.count() ?? 0 > 0 {
            self.telecomMenu?.show(sender: sender)
        }
    }
    
}

extension MonthlyViewController {
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
            case .regular:
                self.paymentViewController?.isFirstLoaded = false
            default:
                break
            }
        }
    }
}
