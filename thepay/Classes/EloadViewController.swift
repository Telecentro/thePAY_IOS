//
//  EloadViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import SnapKit

enum EloadCellType: String {
    case text               = "text"
    case spinner            = "spinner"
    case nationSpinner      = "nationSpinner"
    case category           = "category"
    case boxLabel           = "boxLabel"
    case image              = "image"
    case phoneNumber        = "phoneNumber"
    case globalPhoneNumber  = "globalPhoneNumber"
    case edittext           = "edittext"
    case viewGroup          = "viewGroup"
}

enum EloadSection: Int {
    case first              = 0
    case second             = 1
    case third              = 2
}

struct CategorySize {
    static var height:Double = 40
    static var marginW: Double = 8
    static var marginH:Double = 4
    static var row: Int = 3
    static var imageEdge = UIEdgeInsets(top: 5, left: -2, bottom: 5, right: 0)
    static var titleEdge = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
}

class EloadViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var bgShadow: UIView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCharge: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
//    @IBOutlet weak var viewChargeBottom: UIView!
    @IBOutlet weak var payment: UIView!
    
    @IBOutlet weak var lblNavTitle: TPLabel!
    @IBOutlet weak var lblNavSubTitle: TPLabel!
    
    private var tfCtn: UITextField?
    private var autoComplete: AutoCompleteViewController?
    private var autoCompleteHeight: NSLayoutConstraint?
    private var autoCompleteLeft: NSLayoutConstraint?
    private var autoCompleteRight: NSLayoutConstraint?
    private var autoCompleteTop: NSLayoutConstraint?
    private var autoCompleteBottom: NSLayoutConstraint?
    private var paymentViewController: PaymentViewController?
    
    private var categoryData: [SubPreloadingResponse.itemLists] = []
    private var eload: [SubPreloadingResponse.eLoad]?
    private var attrData: EloadRealResponse.O_DATA?
    private var remoteData: EloadRealResponse.O_DATA?
    
    var invalidCTN = false
    private var inputs: [UITextField] = []
    private var providerSpinner:EloadSpinnerCell?
    
    private var selectNation: SubPreloadingResponse.eLoad? {
        didSet {
            print("🆔 didSet MVNO : \(selectNation?.mvnoId ?? -1)")
            self.inputs = []
        }
    }
    
    private var selectCategory: SubPreloadingResponse.itemLists? {
        didSet {
            print("🆔 didSet ITEM : \(selectCategory?.itemId ?? "")")
            self.inputs = []
        }
    }
    
    
    private var section1Datas: [EloadRealResponse.eloadList] = []
    private var section2Datas: [EloadRealResponse.eloadList] = []
    private var section3Datas: [EloadRealResponse.eloadList] = []
    
    private var dynamicViews: [EloadRealResponse.eloadList] = []
    private var excuteDynamic = false
    private var amtViewData: EloadRealResponse.eloadList?
    private var tempDynamicProductData: EloadRealResponse.item? // 다이나믹 뷰 중복 방지 비교용
    private var searchKey: String = ""
    private var addParams: [String:String] = [:] {
        didSet {
            for param in self.addParams {
                print("🚸 \(param.key) \(param.value)")
            }
        }
    }
}

extension EloadViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
        
        createAutoComplete()
        actionKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func createAutoComplete() {
        let sb = UIStoryboard(name: Storyboard.Contact, bundle: nil)
        autoComplete = sb.instantiateViewController(withIdentifier: "AutoCompleteViewController") as? AutoCompleteViewController
        autoComplete?.view.layer.borderWidth = 0
        autoComplete?.view.layer.borderColor = UIColor.clear.cgColor
        autoComplete?.view.layer.shadowOffset = CGSize(width: 3, height: 3)
        autoComplete?.view.layer.shadowOpacity = 0.4
        autoComplete?.view.layer.shadowRadius = 10
        autoComplete?.delegate = self
    }
    
    private func actionKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideAutoTableView(noti:)),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func hideAutoTableView(noti: NSNotification) {
        autoComplete?.autoTableView(hidden: true)
    }
    
    func initialize() {
        self.tableView.tableFooterView = self.payment
        self.payment.isHidden = true
        self.paymentViewController?.delegate = self
        
        // section 1 data
        requestSubPreloading(opCode: .eload) { [weak self] (data:[Any]?) -> Void in
            guard let self = self else { return }
            self.eload = App.shared.eLoad
            self.setSection1Datas()
        }
        
        addShadow()
    }
    
    func localize() {
        self.btnSearch.setTitle(Localized.btn_search.txt, for: .normal)
        self.btnCharge.setTitle(Localized.btn_recharge.txt, for: .normal)
        self.lblNavTitle.text = NavContents.eload.title
        self.lblNavSubTitle.text = NavContents.eload.subTitle
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? PaymentViewController {
            self.paymentViewController = vc
            vc.paymentTitle = self.title
            vc.isEload = true
            vc.view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if let vc = segue.destination as? AddressViewController {
            guard let code = self.selectNation?.countryCode else { return }
            self.autoComplete?.autoTableView(hidden: true)
            switch sender {
            case is TPEloadHistoryButton:
                vc.currentType = .recent
            case is TPEloadContractButton:
                vc.currentType = .country
            default:
                break
            }
            if let cell = sender as? EloadInputCell, let indexPath = cell.tfContent.indexPath {
                let viewData = indexPath.section == 1 ? self.section2Datas[indexPath.row] : self.section3Datas[indexPath.row]
                print("🏳️ \(viewData.attr?.autoCompleteType ?? "nil")")
                switch viewData.attr?.autoCompleteType {
                case ACType.email:
                    vc.addressBookType = .eloadEmailHistory
                case ACType.id:
                    vc.addressBookType = .eloadIdHistory
                case ACType.num:
                    vc.addressBookType = .eloadCallHistory
                default:
                    vc.addressBookType = .unknown
                    break
                }
                
                // 탭 결정 2020.12.07
                if let t = cell.type {
                    vc.currentType = t
                }
                
                vc.selectNationCode = code
                vc.item = { contact in
                    switch viewData.attr?.autoCompleteType {
                    case ACType.email:
                        cell.tfContent.text = contact.text
                        viewData.attr?.text = contact.text
                    case ACType.id:
                        cell.tfContent.text = contact.text
                        viewData.attr?.text = contact.text
                    case ACType.num:
                        cell.tfContent.text = contact.callNumber
                        viewData.attr?.text = contact.callNumber
                    default:
                        break
                    }
                }
            }
            
            self.view.endEditing(true)
        }
    }

}

extension EloadViewController {
    
    // section 2 data
    private func requestEloadViewAttribute() {
        self.showLoadingWindow()
        let param = EloadRealRequest.Param(mvnoId: String(self.selectNation?.mvnoId ?? 0), itemId: self.selectCategory?.itemId ?? "")
        let req = EloadRealRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam(), showDebug: false) { [weak self] (response:Swift.Result<EloadRealResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.attrData = data.O_DATA
                self.excuteDynamic = false;
                self.dynamicViews.removeAll()
                self.setSection2Datas()
                self.hideLoadingWindow()
            case .failure(let error):
                print(error)
                self.hideLoadingWindow()
                error.processError(target: self)
            }
        }
    }
}

extension EloadViewController {
    
    // 최초 params 데이터 파싱
    private func selectData() {
        self.selectNation = eload?.first
        self.selectCategory = selectNation?.itemLists?.first
    }
    
    /**
     *  전달된 파라미터 값 (Deep Link)
     *  country_type : mvnoId - 국가
     *  product_type : itemId - 상품
     */
    private func setParamData() {
        if self.params?.count == 0 {
            return
        }
        
        if let country_type = self.params?["country_type"] as? String, !country_type.isEmpty {
            for i in self.eload ?? [] {
                if String(i.mvnoId ?? -1) == country_type {
                    self.selectNation = i
                }
            }
        }
        
        if let product_type = self.params?["product_type"] as? String, !product_type.isEmpty {
            for i in self.selectNation?.itemLists ?? [] {
                if i.itemId == product_type {
                    self.selectCategory = i
                }
            }
        }
    }
    
    private func setSection1Datas() {
        self.section1Datas.removeAll()
        
        var attr1 = EloadRealResponse.attr()
        attr1.text = Localized.title_activity_sel_nation.txt
        let viewData1 = EloadRealResponse.eloadList()
        viewData1.viewtype = EloadCellType.text.rawValue
        viewData1.type = EKey.show
        viewData1.attr = attr1
        
        let viewData2 = EloadRealResponse.eloadList()
        viewData2.viewtype = EKey.nationSpinner
        viewData2.type = EKey.show
        
        var attr3 = EloadRealResponse.attr()
        attr3.text = Localized.recharge_goods.txt
        let viewData3 = EloadRealResponse.eloadList()
        viewData3.viewtype = EKey.text
        viewData3.type = EKey.show
        viewData3.attr = attr3
        
        let viewData4 = EloadRealResponse.eloadList()
        viewData4.viewtype = EKey.category
        viewData4.type = EKey.show
        
        let viewData5 = EloadRealResponse.eloadList()
        viewData5.viewtype = EKey.boxLabel
        viewData5.type = EKey.show
        
        self.section1Datas.append(viewData1)
        self.section1Datas.append(viewData2)
        self.section1Datas.append(viewData3)
        self.section1Datas.append(viewData4)
        self.section1Datas.append(viewData5)
        
        self.selectData()   // 기본 데이터 설정 (1)
        self.setParamData() // DeepLink 데이터 설정 (2)
        self.printList(list: self.section1Datas, comment:"🌸 1 DATAS VIEW 🌸")
        self.tableView.reloadData()
        self.requestEloadViewAttribute()
    }
    
    private func setSection2Datas() {
        self.tempDynamicProductData = nil
        self.section2Datas = self.attrData?.eloadList ?? []
        self.printList(list: self.section2Datas, comment:"🌸 2 DATAS VIEW 🌸")
        self.reloadSection(1)
    }
    
    private func setSection3Datas() {
        self.section3Datas = self.remoteData?.eloadList ?? []
        self.printList(list: self.section3Datas, comment:"🌸 3 DATAS VIEW 🌸")
        self.reloadSection(2)
    }
    
    /**
     *  오토컴플리트 (자동완성) 화면에서 제거
     */
    private func removeAutoCompleteView() {
        if let auto = autoComplete {
            auto.view.removeFromSuperview()
        }
    }
    
    /**
     *  섹션 리로드
     *  1. 자동완성제거
     *  2. atmViewData 제거
     *  EKey.eloadCalcurate 키에 대해서 ATM Item 으로 판단한다.
     *  기타 필드에 대해서 setFuncWithViewData 함수 재귀를 동작한다.
     */
    private func reloadSection(_ idx: Int) {
        self.removeAutoCompleteView()
        self.amtViewData = nil
        self.providerSpinner = nil
        
        let viewDatas1 = idx == 1 ? self.section2Datas : self.section3Datas
        for viewData1 in viewDatas1 {
            if viewData1.viewtype == EKey.spinner {
                if let selectItem = viewData1.item?[viewData1.getIndex()] {
                    if selectItem.function?.first?.type == EKey.eloadCalcurate && viewData1.type != EKey.hide {
                        self.amtViewData = viewData1
                        print("🉐 Select Spinner AMT Item : \(String(describing: self.amtViewData?.id))")
                    }
                    
                    let viewDatas2 = idx == 1 ? self.section2Datas : self.section3Datas
                    for viewData2 in viewDatas2 {
                        self.setFuncWithViewData(viewData: viewData1, toViewData: viewData2)
                    }
                }
            }
        }
        
        // 해당 섹션을 리로드 [section2Datas 또는 section3Datas]
        // fade 에니메이션 적용
        // 하단 뷰를 재정렬한다.
        if let range = Range(NSMakeRange(idx, 1)) {
            let section = IndexSet(integersIn: range)
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(section, with: .none)
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.setBottomView()
            }
        }
    }
    
    /**
     *  viewDidLayoutSubviews
     *  테이블 뷰의 FooterView 높이를 결정한다.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let footerView = tableView.tableFooterView {

            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var footerFrame = footerView.frame

            // Comparison necessary to avoid infinite loop
            if height != footerFrame.size.height {
                footerFrame.size.height = height
                footerView.frame = footerFrame
                tableView.tableFooterView = footerView
            }
        }
    }
    
    /**
     *  선택된 스피너 아이템이 없으면 (즉, 스피너가 없으면 SearchView로 판단)
     *  선택된 스피너 아이템이 없으면 Search[검색] 버튼 노출
     *  선택된 스피너 아이템이 있으면 Charge[결제] 버튼 노출
     */
    private func setBottomView() {
        let idx = self.amtViewData?.selectItemIndex ?? 0
        let prod = self.amtViewData?.item?[idx]
        
        if prod == nil {
            self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.contentSize.width, height: 30))
            self.addShadow()
            self.setSearchButton()
        }
        
        // prod 아이템이 없으면 이하 구문 실행 안됨
        switch prod?.function?.first?.arg {
        case .arg(let value):
            if let prodArg = value.first {
                self.tableView.tableFooterView = self.payment
                self.payment.isHidden = false
                self.addShadow()
                self.setChargeButton()
                self.setPaymentView(prodArg: prodArg)
            }
        default:
            break
        }
        
        adjustScroll()
    }
    
    private func adjustScroll() {
        let b = self.tableView.contentOffset
        self.tableView.setContentOffset(CGPoint(x: b.x, y: b.y - 1), animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.setContentOffset(CGPoint(x: b.x, y: b.y + 1), animated: true)
        }
    }
    
    private func addShadow() {
        if #available(iOS 13.0, *) {
            var footer:UIView?
            var header:UIView?
            
            header = tableView.tableHeaderView
            footer = tableView.tableFooterView
            bgShadow?.clearConstraints()
            if let v = bgShadow, let h = header, let f = footer  {
                tableView.backgroundView?.addSubview(v)
                if v.superview != nil {
                    v.snp.makeConstraints { m in
                        m.leading.equalToSuperview().offset(15)
                        m.trailing.equalToSuperview().offset(-15)
                        
                        m.top.equalTo(h.snp.bottom).offset(-10)
                        m.bottom.equalTo(f.snp.top).offset(15)
                    }
                }
            }
        } else {
            self.tableView.backgroundColor = .white
            
        }
        
    }
    
    private func setPaymentView(prodArg: EloadRealResponse.arg) {
        guard let mvnoId = Int(prodArg.prodId ?? "0") else { return }
        guard let rcgType = prodArg.rcgType else { return }
        guard let price = prodArg.amount else { return }
        let data = ProductData(mvnoId: mvnoId, rcgType: rcgType, price: Int(price))
        self.paymentViewController?.updateProductData(data: data)
    }
    
    private func setSearchButton() {
//        self.viewChargeBottom.backgroundColor = UIColor(named: "0000FF")
        self.btnSearch.isHidden = false
        self.btnCharge.isHidden = true
    }
    
    private func setChargeButton() {
//        self.viewChargeBottom.backgroundColor = UIColor(named: "EA505A") ?? .red
        self.btnSearch.isHidden = true
        self.btnCharge.isHidden = false
    }
    
    /**
     *  @param viewData 스피너 데이터
     *  @param toViewData 해당 필드
     *  viewData 가 nil 이면 반환한다.
     */
    private func setFuncWithViewData(viewData: EloadRealResponse.eloadList?, toViewData: EloadRealResponse.eloadList?) {
        guard let selectItem = viewData?.item?[viewData?.selectItemIndex ?? 0] else { return }
        
        for f in selectItem.function ?? [] {
            if f.type == EKey.requestDynamicView {
                if let temp = tempDynamicProductData {
                    if temp == selectItem {
                        continue
                    }
                }
                
                self.tempDynamicProductData = selectItem
                // 파라미터 초기화
                resetParam()
                
                switch f.arg {
                case .arg(let value):
                    if let param = value.first?.param {
                        for p in param {
                            self.updateParam(value: p.value, key: p.key, comment: "🅰️")
                        }
                    }
                default:  break
                }
                
                let _ = self.setAPIAddParams()
                self.requestDynamicView()
                break
            } else if f.type == EKey.eloadCalcurate {
                continue
            }
            
            switch f.arg {
            case .string(let names):
                for name in names {
                    if name == toViewData?.id {
                        if f.type == EKey.setPrefix {
                            toViewData?.type = f.type
                            switch f.arg {
                                case .string(let value): toViewData?.attr?.inputType = value[1]
                                default: break
                            }
                        } else {
                            toViewData?.type = f.type
                        }
                    }
                }
            default: break
            }
        }
    }
}

// MARK: 요청
extension EloadViewController {
    
    /**
    *  [ 검색 ]
    *  1. 파라미터 초기화
    *  2. attrData 의 인터페이스 배열을 순회한다.
    *  3. 리모트 뷰 통신을 요청한다.
    */
    @IBAction func search() {
        
        // 파라미터 초기화
        resetParam()
        
        guard let id = selectCategory?.itemId else { return }
        if !id.isEmpty {
            self.updateParam(value: id, key: "itemId", comment: "🆑")
        }
        
        for interface in self.attrData?.interface ?? [] {
            if interface.apiId == "requestRechargePreview" {
                let cnt = (interface.apiKey?.count ?? 0) - 1    // 카운트 1 감소 [배열 인덱스]
                for i in 0...cnt {
                    if let value = interface.apiValue?[i].raw, let key = interface.apiKey?[i] {
                        self.updateParam(value: value, key: key, comment: "🆑")
                    }
                }
                
                if !self.setAPIAddParams() {
                    return
                }
            }
        }
        
        self.printParams()
        self.requestRemoteView()
    }
    
    /**
     *  [ 결제 ]
     *  1. 파라미터 초기화
     *  2. attrData 의 인터페이스 배열을 순회한다.
     *  3. 마지막에 ItemId 를 추가한다.
     *  4. eloadCharge 통신을 요청한다.
     */
    @IBAction func charge() {
        
        // 파라미터 초기화
        resetParam()
        
        for interface in self.attrData?.interface ?? [] {
            if interface.apiId == "requestRechargePreview" {
                let cnt = (interface.apiKey?.count ?? 0) - 1    // 카운트 1 감소 [배열 인덱스]
                for i in 0...cnt {
                    if let value = interface.apiValue?[i].raw, let key = interface.apiKey?[i] {
                        self.updateParam(value: value, key: key, comment: "🆑")
                    }
                }
                
                if !self.setAPIAddParams() {
                    return
                }
            }
        }
        
        for interface in self.remoteData?.interface ?? [] {
            if interface.apiId == "requestRechargePreview" {
                let cnt = (interface.apiKey?.count ?? 0) - 1    // 카운트 1 감소 [배열 인덱스]
                for i in 0...cnt {
                    if let value = interface.apiValue?[i].raw, let key = interface.apiKey?[i] {
                        self.updateParam(value: value, key: key, comment: "🆑")
                    }
                }
                
                if !self.setAPIAddParams(remote: true) {
                    return
                }
            }
        }
        
        // 2020.11.13 (itemId 추가)
        if !invalidCTN {
            // min_val 확인
            self.updateParam(value: self.selectCategory?.itemId ?? "", key: Key.RcgEloadV3.itemId, comment: "🅾️")
            self.printParams()
            self.paymentViewController?.eloadCharge(addParams: self.addParams)
        }
    }
    
    
    private func printParams() {
        print("⛑ Params Created ♨️♨️♨️♨️♨️♨️♨️♨️")
        for param in self.addParams {
            print("✅ \(param.key) \(param.value)")
        }
        print("⛑ Params Created ♨️♨️♨️♨️♨️♨️♨️♨️")
    }
    
    // section 3 data (Nepal Internet)
    private func requestRemoteView() {
        self.showLoadingWindow()
        guard let mvnoId = self.selectNation?.mvnoId else {
            return
        }
        let req = EloadRemoteRequest(mvnoId: String(mvnoId))
        let newParam = req.getNewParam(addParams)
        API.shared.request(url: req.getAPI(), param: newParam, showDebug: false) { [weak self] (response:Swift.Result<EloadRealResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.remoteData = data.O_DATA
                self.setSection3Datas()
                self.hideLoadingWindow()
            case .failure(let error):
                self.hideLoadingWindow()
                error.processError(target: self)
            }
        }
    }
    
    // section 2 data (add)
    private func requestDynamicView() {
        self.excuteDynamic = true
        let req = EloadDynamicRequest()
        let newParam = req.getNewParam(addParams)
        API.shared.request(url: req.getAPI(), param: newParam, showDebug: false) { [weak self] (response:Swift.Result<EloadRealResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                if !self.excuteDynamic { return }   // 2020.10.15 이로드 다이나믹뷰 잔상 제거
                
                var index = 0
                
                if self.dynamicViews.count > 0 {
                    if let idx = self.section2Datas.firstIndex(where: { $0 === self.dynamicViews.first }) {
                        index = idx
                        let count = (self.dynamicViews.count + idx) - 1
                        let range = idx...count
                        self.section2Datas.removeSubrange(range)
                    }
                } else {
                    for item in self.section2Datas {
                        if item.viewtype == "viewGroup" {
                            if let idx = self.section2Datas.firstIndex(where: { $0 === item }) {
                                index = idx
                                self.section2Datas.remove(at: idx)
                                break
                            }
                        }
                    }
                }
                
                self.dynamicViews = data.O_DATA?.eloadList ?? []
                self.printList(list: self.dynamicViews, comment:"🌸 DYNAMIC VIEW 🌸")
                self.section2Datas.insert(contentsOf: self.dynamicViews, at: index)
                self.reloadSection(1)
            case .failure(let error):
                error.processError(target: self)
            }
        }
    }
    
    /**
     *  파라미터를 업데이트한다.
     *  @params remote 리모트 뷰일 경우 section3Datas 를 순회한다.
     *  setAPIAddParams[재귀] 또는 addEditTextAPIKeyValue[유효성체크] 함수의 반환이 false 라면 구문을 종료한다.
     */
    private func setAPIAddParams(remote: Bool = false) -> Bool {
        print("🈸🈸♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️")
        for codeName in addParams.values {
            let codeFrame = codeName.components(separatedBy: EKey.separator)
            if codeFrame.count != 2 { continue }    // continue
            let codeId = codeFrame[0].replacingOccurrences(of: EKey.prefixSharp, with: "")
            let codeKey = codeFrame[1].replacingOccurrences(of: EKey.suffix, with: "")
            
            let item = remote ? self.section3Datas : self.section2Datas
            
            for viewData in item {
                if viewData.id == codeId {
                    if viewData.viewtype == EKey.spinner {
                        let idx = viewData.getIndex()
                        guard let prodData = viewData.item?[idx] else { return false }
                        guard let apiKey = viewData.apiKey else { return false }
                        
                        for (i, key) in apiKey.enumerated() {
                            if key == codeKey {
                                if let value = prodData.apiValue?[i] {
                                    let updateValue = value.raw
                                    self.updateParam(value:updateValue, key: key, comment: "🅱️")
                                    if updateValue.hasPrefix(EKey.prefix) {
                                        if (!self.setAPIAddParams()) {
                                            print("♨️♨️♨️♨️♨️♨️♨️♨️🈚️♨️🈚️♨️🈚️♨️🈚️")
                                            return false
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if !self.addEditTextAPIKeyValue(viewData: viewData) {
                            print("♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️🈚️🈚️🈚️🈚️")
                            return false
                        }
                    }
                }
            }
        }
        
        print("♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️♨️🈸🈸")
        
        return true
    }
    
    private func addEditTextAPIKeyValue(viewData: EloadRealResponse.eloadList) -> Bool {
        var validateText = viewData.attr?.text
        
        if validateText.isNilOrEmpty {
            if viewData.attr?.inputType == EKey.email {
                Localized.eload_email_valid_check_error.txt.showErrorMsg(target: self.view)
            } else {
                Localized.toast_invalid_format_number.txt.showErrorMsg(target: self.view)
            }

            return false
        }
        
        var returnValue = ""
        
        for value in viewData.apiValue ?? [] {
            returnValue = value.raw
            
            if returnValue.contains(EKey.inputValue) {
                if viewData.attr?.inputType == EKey.number || viewData.attr?.inputType == EKey.date {
                    if let txt = validateText {
                        validateText = txt.extractNumberString
                    }
                } else if (viewData.attr?.inputType == EKey.email) {
                    if !(validateText?.isEmail ?? false) {
                        Localized.eload_email_valid_check_error.txt.showErrorMsg(target: self.view)
                        return false
                    }
                }
                
                returnValue = returnValue.replacingOccurrences(of: EKey.inputValue, with: validateText ?? "")
            }
            
            if returnValue.contains(EKey.getPrefix) {
                let replaceText = viewData.attr?.inputPrefix != nil ? viewData.attr?.inputPrefix : ""
                returnValue = returnValue.replacingOccurrences(of: EKey.getPrefix, with: replaceText ?? "")
            }
            
            if returnValue.contains(EKey.getCountryCode) {
                let replaceText = viewData.attr?.countryCode != nil ? viewData.attr?.countryCode : ""
                returnValue = returnValue.replacingOccurrences(of: EKey.getCountryCode, with: replaceText ?? "")
            }
            
            if viewData.apiKey?.first == EKey.CTN {
                let minVal: Int = Int(viewData.attr?.min_val ?? "0") ?? 0
                let ctnCount: Int = viewData.attr?.text?.count ?? 0
                if minVal > ctnCount {
                    String(format: Localized.eload_min_length_error.txt, minVal).showErrorMsg(target: self.view)
                    invalidCTN = true
                }
                self.searchKey = viewData.attr?.text ?? ""
                print("👉 self.searchKey \(self.searchKey)")
            }
        }
        
        self.updateParam(value:returnValue, key: viewData.apiKey?.first ?? "", comment: "🆎")
        
        return true
    }
    
    // 전달 파라미터 초기화
    private func resetParam() {
        self.invalidCTN = false
        self.addParams = [:]
        print("⛑ Params Initialize ♨️♨️♨️♨️♨️♨️♨️♨️")
    }
    
    /**
     *  전달 파라미터 업데이트
     *  🅾️ : ItemId 파싱
     *  🆑 : Interface 파싱
     *  🅱️ : Spinner 파싱
     *  🆎 : Validation 완료 파싱
     */
    private func updateParam(value: String, key: String, comment: String = "⛈") {
        print("☘️ UPDATE! value : [\(value)] key : \(key) \(comment)")
        addParams.updateValue(value, forKey: key)
    }
    
    // 디버그 용
    private func printList(list: [EloadRealResponse.eloadList], comment: String) {
        print(comment)
        for i in list {
            if let type = i.viewtype, let id = i.id {
                if type == EKey.text {
                    print("🌺 type \(type) title [\(i.attr?.text.bin ?? "")]")
                } else {
                    print("🌺 type \(type) id \(id)")
                }
            }
        }
        print(comment)
    }
}

// MARK: 테이블 뷰
extension EloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch EloadSection(rawValue: section) {
        case .first:
            return self.section1Datas.count
        case .second:
            return self.section2Datas.count
        case .third:
            return self.section3Datas.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var viewData: [EloadRealResponse.eloadList] = []
        
        switch EloadSection(rawValue: indexPath.section) {
        case .first:
            viewData = self.section1Datas
        case .second:
            viewData = self.section2Datas
        case .third:
            viewData = self.section3Datas
        case .none:
            break
        }
        
        let data = viewData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.viewtype.bin, for: indexPath)
        print("🎩 data.viewtype.bin \(data.viewtype.bin)")
        switch EloadCellType(rawValue: data.viewtype.bin) {
        case .viewGroup:
            break
        case .text:
            if let text = cell as? EloadTextCell {
                text.lblContent.text = data.attr?.text.bin
            }
        case .nationSpinner:
            if let nationSpinner = cell as? EloadNationCell {
                let data = MenuDataConverter.nations(value: self.eload)
                nationSpinner.menuManager.updateData(data: data)
                nationSpinner.menuManager.menu?.selectItem = { [weak self] d in
                    if let data = d {
                        if data.countryCode != self?.selectNation?.countryCode {
                            self?.selectNation = d
                            self?.selectCategory = data.itemLists?.first
                            self?.tableView.reloadData()
                            self?.requestEloadViewAttribute()
                        }
                    }
                }
                
                let index = data.enumerated().filter({self.selectNation! == $0.element.data }).map({$0.offset})
                let idx = index.first ?? 0
                nationSpinner.menuManager.menu?.reset(idx: idx)
                nationSpinner.ivNation.image = UIImage(named: "flag_\(self.selectNation?.countryCode ?? "0")")
                nationSpinner.tfContent.text = self.selectNation?.mvnoName
            }
        case .spinner:
            if let spinner = cell as? EloadSpinnerCell {
                let eload = viewData[indexPath.row].item ?? []
                spinner.menuManager.menu?.row = viewData[indexPath.row].getIndex()
                spinner.tfContent?.text = eload[exist: spinner.menuManager.menu?.row ?? 0]?.text
                spinner.menuManager.updateData(data: MenuDataConverter.eload(value: eload))
                spinner.menuManager.menu?.selectItem = { [weak self] d in
                    guard let self = self else { return }
                    
                    // 2021.09.07
                    spinner.tfContent?.text = eload[exist: spinner.menuManager.menu?.row ?? 0]?.text
                    // 2021.09.07
                    
                    if let selector = d {
                        if selector.function?.first?.type == EKey.eloadCalcurate {
                            // eloadCalcurate (금액 설정)
                            self.selectPicker(row: spinner.menuManager.menu?.row ?? 0, indexPath: indexPath)
                        } else {
                            // setPrefix (타입 설정)
                            self.selectPicker(row: spinner.menuManager.menu?.row ?? 0, indexPath: indexPath)
                            self.removeRemoteView()
                        }
                    }
                }
                            
                // id is Provider
                if let b = data.id?.contains("Merchant") {
                    if b {
                        providerSpinner = spinner
                    }
                }
                
            }
        case .category:
            if let category = cell as? EloadCategoryCell {
                self.categoryData = self.selectNation?.itemLists ?? []
                category.collectionView.delegate = self
                category.collectionView.dataSource = self
                category.collectionView.reloadData()
                print("🧤 Reload Category Data (\(self.selectNation?.mvnoName ?? ""))")
                print("--------------------------------------------------------------")
                for i in self.categoryData {
                    print("🥼 Reload Category Data Item (\(i.itemId ?? ""))")
                }
                print("--------------------------------------------------------------")
            }
        case .boxLabel:
            if let boxLabel = cell as? EloadBoxLabelCell {
                boxLabel.tfContent.text = self.selectCategory?.itemName
            }
        case .image:
            if let image = cell as? EloadImageCell {
                if let url = URL(string: data.attr?.contentUrl ?? "") {
                    image.ivContent.sd_setImage(with: url, completed: nil)
                }
            }
        case .phoneNumber:
            if let phoneNumber = cell as? EloadPhoneCell {
                phoneNumber.lblPrefix.text = data.attr?.countryCode
                phoneNumber.tfContent.placeholder = data.attr?.hint
                phoneNumber.tfContent.text = data.attr?.text
                
                switch data.attr?.autoCompleteType {
                case ACType.num:
                    phoneNumber.btnHistory.isHidden = false
                    phoneNumber.btnContact.isHidden = false
                    phoneNumber.line.isHidden = false
                    break
                default:
                    phoneNumber.btnHistory.isHidden = true
                    phoneNumber.btnContact.isHidden = true
                    phoneNumber.line.isHidden = true
                    break
                }
                
                phoneNumber.tfContent.indexPath = indexPath
                phoneNumber.tfContent.delegate = self
                phoneNumber.btnHistory.indexPath = indexPath
                phoneNumber.btnContact.indexPath = indexPath
            }
        case .globalPhoneNumber:
            if let globalPhoneNumber = cell as? EloadGlobalPhoneCell {
                globalPhoneNumber.lblPrefix.text = data.attr?.countryCode
                globalPhoneNumber.tfContent.placeholder = data.attr?.hint
                globalPhoneNumber.tfContent.text = data.attr?.text
                
                switch data.attr?.autoCompleteType {
                case ACType.num:
                    globalPhoneNumber.btnHistory.isHidden = false
                    globalPhoneNumber.btnContact.isHidden = false
                    globalPhoneNumber.line.isHidden = false
                    break
                default:
                    globalPhoneNumber.btnHistory.isHidden = true
                    globalPhoneNumber.btnContact.isHidden = true
                    globalPhoneNumber.line.isHidden = true
                    break
                }
                
                globalPhoneNumber.tfContent.indexPath = indexPath
                globalPhoneNumber.btnHistory.indexPath = indexPath
                globalPhoneNumber.btnContact.indexPath = indexPath
                globalPhoneNumber.tfContent.delegate = self
            }
        case .edittext:
            if let edittext = cell as? EloadEmailCell {
                edittext.lblPrefix.text = data.attr?.inputPrefix
                edittext.tfContent.placeholder = data.attr?.hint
                edittext.tfContent.text = data.attr?.text
                
                switch data.attr?.inputType {
                case EKey.email:
                    edittext.tfContent.keyboardType = .emailAddress
                case EKey.number, EKey.date:
                    edittext.tfContent.keyboardType = .numberPad
                case EKey.password:
                    edittext.tfContent.keyboardType = .default
                    edittext.tfContent.isSecureTextEntry = true
                default:
                    edittext.tfContent.keyboardType = .default
                    break
                }
                
                switch data.attr?.autoCompleteType {
                case ACType.email, ACType.num:
                    edittext.btnHistory.isHidden = false
                    edittext.btnContact.isHidden = false
                    edittext.line.isHidden = false
                    break
                case ACType.id:
                    edittext.btnHistory.isHidden = false
                    edittext.btnContact.isHidden = true
                    edittext.line.isHidden = true
                default:
                    edittext.btnHistory.isHidden = true
                    edittext.btnContact.isHidden = true
                    edittext.line.isHidden = true
                    break
                }
                
                edittext.tfContent.indexPath = indexPath
                edittext.btnHistory.indexPath = indexPath
                edittext.btnContact.indexPath = indexPath
                edittext.tfContent.delegate = self
            }
        default:
            break
        }
        
        return cell
    }
    
    private func selectPicker(row: Int, indexPath: IndexPath) {
        let viewData = indexPath.section == 1 ? self.section2Datas[indexPath.row] : self.section3Datas[indexPath.row]
        
        let idx = viewData.getIndex()
        
        if let currentSelectItem = viewData.item?[idx], let selectItem = viewData.item?[row] {
            if currentSelectItem == selectItem {
                return
            }
        }
        
        viewData.selectItemIndex = row
        
        if self.section3Datas.count > 0 {
            self.reloadSection(2)
        } else {
            self.reloadSection(1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var viewData: [EloadRealResponse.eloadList] = []
        
        switch EloadSection(rawValue: indexPath.section) {
        case .first:
            viewData = self.section1Datas
        case .second:
            viewData = self.section2Datas
        case .third:
            viewData = self.section3Datas
        case .none:
            break
        }
        
        let data = viewData[indexPath.row]
        
        if data.type == EKey.hide {
            return 0
        }
        
        switch EloadCellType(rawValue: data.viewtype.bin) {
        case .image:
            return 50
        case .category:
            if let cnt = self.selectNation?.itemLists?.count, cnt > 0 {
                let row = ceil(Double(cnt) / Double(CategorySize.row))
                let height = row * CategorySize.height
                let margin = row * CategorySize.marginH
                let collectionViewHeight = CGFloat(height + margin)
                
                return collectionViewHeight + 8 // 높이 추가 (8) 2020.10.09
            } else {
                return 0
            }
        default:
            break
        }
        
        return UITableView.automaticDimension
    }
}

// MARK: 컬렉션 뷰 (카테고리 버튼 드로잉)
extension EloadViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EKey.category, for: indexPath)
        if let category = cell as? EloadCollectionCategoryCell {
            let item = categoryData[indexPath.row]
            let title = item.title?.replacingOccurrences(of: "\u{0C}", with: "")
            category.lbl.text = title
            category.btn.index = indexPath.row
            if let url = URL(string: item.imageDefaultUrl ?? "") {
                category.btn.sd_setBackgroundImage(with: url, for: .normal)
            }
            
            if let url = URL(string: item.imageSelectUrl ?? "") {
                category.btn.sd_setBackgroundImage(with: url, for: .selected)
            }
            
            category.btn.imageView?.contentMode = .scaleAspectFit
            category.btn.imageEdgeInsets = CategorySize.imageEdge
            category.btn.titleEdgeInsets = CategorySize.titleEdge
            category.btn.titleLabel?.numberOfLines = 2
            category.btn.addTarget(self, action: #selector(onClickCategoryButton), for: .touchUpInside)
            
            if let idx = Int(self.selectCategory?.sortNo ?? "0") {
                let i = idx - 1
                if indexPath.row == i {
                    category.btn.isSelected = true
                } else {
                    category.btn.isSelected = false
                }
            }
        }
        return cell
    }
    
    @objc func onClickCategoryButton(sender: CheckButton) {
        // 2020.10.30 키보드 내려올때 텍스트 남아 있는 에러 수정
        self.view.endEditing(true)
        
        guard let data = self.selectNation?.itemLists?[sender.index] else { return }
        
        if data == self.selectCategory {
            return
        }
        
        self.removeRemoteView()
        
        if showFailMsg(data: data) {
            return
        }
        
        
        /* 카테고리 컨텐츠 리로드 */
        let indexPath = IndexPath(row: 3, section: 0)
        if let cell = self.tableView.cellForRow(at: indexPath) as? EloadCategoryCell {
            cell.collectionView.reloadData()
        }
        
        /* boxLabelCell 재설정 */
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? EloadBoxLabelCell {
            cell.tfContent.text = data.itemName
        }
        
        self.selectCategory = data
        requestEloadViewAttribute()
    }
    
    private func showFailMsg(data: SubPreloadingResponse.itemLists) -> Bool {
        // itemFailure 1일 경우 공사중??
        let itemFailure = data.itemFailure?.raw
        if itemFailure == "1" {
            data.itemFailMsg?.showErrorMsg(target: self.view)
            return true
        }
        
        return false
    }
    
    private func removeRemoteView() {
        if self.remoteData != nil {
            self.searchKey = ""
            self.remoteData = nil
            self.setSection3Datas()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("🎯 Category CollectionView Selected \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.size.width - CGFloat(CategorySize.marginW)) / CGFloat(CategorySize.row)
        return CGSize(width: width, height: CGFloat(CategorySize.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(CategorySize.marginH)
    }
}

// MARK: - 자동완성 델리게이터
extension EloadViewController: AutoCompleteDelegate, UIScrollViewDelegate {
    func updateAutoCompleteHeight(height: Int) {
        self.autoCompleteHeight?.constant = CGFloat(height)
    }
    
    func selectItem(phoneNumber: String) {
        self.select(text: phoneNumber)
        self.tfCtn?.resignFirstResponder()
    }
    
    func hiddenAutoComplete(hidden: Bool) {
        self.autoComplete?.view?.isHidden = hidden
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoComplete?.autoTableView(hidden: true)
    }
}


// MARK: - 텍스트필드 델리게이터
extension EloadViewController: UITextFieldDelegate {
    
    private func addAutoCompleteView(auto:AutoCompleteViewController ,stackView: UIView) {
        print("🔺 \(stackView.convert(stackView.frame, to: self.view))")
        self.view.addSubview(auto.view)
        self.autoCompleteTop?.isActive = false
        self.autoCompleteLeft?.isActive = false
        self.autoCompleteRight?.isActive = false
        self.autoCompleteBottom?.isActive = false
        auto.view.translatesAutoresizingMaskIntoConstraints = false
        if let _ = self.tableView.tableFooterView {
            self.autoCompleteLeft = auto.view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
            self.autoCompleteLeft?.isActive = true
            self.autoCompleteRight = auto.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            self.autoCompleteRight?.isActive = true
            self.autoCompleteTop = auto.view.topAnchor.constraint(equalTo: stackView.bottomAnchor)
            self.autoCompleteTop?.isActive = true
        } else {
            self.autoCompleteLeft = auto.view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
            self.autoCompleteLeft?.isActive = true
            self.autoCompleteRight = auto.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            self.autoCompleteRight?.isActive = true
            self.autoCompleteBottom = auto.view.bottomAnchor.constraint(equalTo: stackView.topAnchor)
            self.autoCompleteBottom?.isActive = true
        }

        if let _ = autoCompleteHeight {
        } else {
            self.autoCompleteHeight = auto.view.heightAnchor.constraint(equalToConstant: 0)
            self.autoCompleteHeight?.isActive = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        autoComplete?.autoTableView(hidden: true)
        if let tf = textField as? TPTextField {
            print("🔺 \(tf.indexPath ?? IndexPath(row: -1, section: -1))")
            self.tfCtn = tf
            if !self.inputs.contains(tf) {
                self.inputs.append(tf)
            }
        }
        if let auto = autoComplete {
            guard let tf = self.tfCtn as? TPTextField else { return }
            guard let indexPath = tf.indexPath else { return }
            let viewData = indexPath.section == 1 ? self.section2Datas[indexPath.row] : self.section3Datas[indexPath.row]
            autoComplete?.updateData(type: viewData.attr?.autoCompleteType ?? "num", code: self.selectNation?.countryCode ?? "")

            if let stackView = textField.superview {
                addAutoCompleteView(auto: auto, stackView: stackView)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tf = textField as? TPTextField else { return }
        guard let indexPath = tf.indexPath else { return }
        
        var viewData:EloadRealResponse.eloadList?
        
        if indexPath.section == 1 {
            if indexPath.row < self.section2Datas.count {
                viewData = self.section2Datas[indexPath.row]
            }
        } else if indexPath.section == 2 {
            if indexPath.row < self.section3Datas.count {
                viewData = self.section3Datas[indexPath.row]
            }
        }
        
        if viewData?.attr?.text != tf.text {
            viewData?.attr?.text = tf.text
            print("🔴 \(tf.text ?? "") \(viewData?.attr?.text ?? "")")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let tf = textField as? TPTextField else { return false }
        guard let indexPath = tf.indexPath else { return false }
        let viewData = indexPath.section == 1 ? self.section2Datas[indexPath.row] : self.section3Datas[indexPath.row]
        let cursorPosition:Int? = getPosition(textField: textField)
        
        if viewData.type == EKey.hide {
            return false // 숨겨진 아이템일 경우 반환
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            viewData.attr?.text = currentText
            textField.text = currentText
            print("🔴 \(currentText)")
            return true // 반환 TRUE
        }
        
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if remoteData != nil && updatedText != self.searchKey {
            self.removeRemoteView()
        }
        
        if updatedText.count > Int(viewData.attr?.max_val ?? "0") ?? 0 {
            let maxVal: Int = Int(viewData.attr?.max_val ?? "0") ?? 0
            String(format: Localized.eload_max_length_error.txt, maxVal).showErrorMsg(target: self.view)
            if string == "" {
                return true
            } else {
                return false // 값을 초과한 경우 반환
            }
        }
        
        if textField.keyboardType == .numberPad {
            // ০১২৩৪৫৬৭৮৯০১২৩৪৫৬৭৮৯
            if !updatedText.isNumber {
                "\(Localized.toast_empty_tel.txt)\n(\(updatedText))".showErrorMsg(target: self.view)
                return false // 숫자가 아닌 경우 반환
            }
            
            // 아라비안 숫자 변환
            updatedText = LanguageUtils.getArabianSentence(string: updatedText).extractNumberString
            viewData.attr?.text = updatedText
            textField.text = updatedText
            updateNumberInput(textField: textField, updatedText: updatedText, position: cursorPosition, string: string)
            autoComplete?.processingAutoTable(text: updatedText, type: viewData.attr?.autoCompleteType, code: self.selectNation?.countryCode ?? "")
            return false // 숫자를 체크하고 반환
        } else {
            // 아라비안 숫자 변환
            if updatedText.isNumber {
                updatedText = LanguageUtils.getArabianSentence(string: updatedText).extractNumberString
            }
            
            viewData.attr?.text = updatedText
            textField.text = updatedText
            updateNumberInput(textField: textField, updatedText: updatedText, position: cursorPosition, string: string)
            autoComplete?.processingAutoTable(text: updatedText, type: viewData.attr?.autoCompleteType, code: self.selectNation?.countryCode ?? "")
            return false // 반환 TRUE
        }
    }
    
    private func getPosition(textField: UITextField) -> Int? {
        if let selectedRange = textField.selectedTextRange {
            return textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        } else {
            return nil
        }
    }
    
    // 백스페이스 또는 숫자 (전화번호) 입력
    private func updateNumberInput(textField: UITextField, updatedText: String, position: Int?, string: String) {
        guard let p = position else { return }
        if string == "" {
            Utils.setTextFieldPosition(textField: textField, position: p - 1)
        } else {
            Utils.setTextFieldPosition(textField: textField, position: p + 1)
        }
        print("🟢 \(updatedText) 🟢 \(string)")
    }
    
    // 백스페이스 또는 문자열 (이메일, ID) 입력
//    private func updateTextInput(textField: UITextField, updatedText: String, position: Int?) {
//        guard let p = position else { return }
//        Utils.setTextFieldPosition(textField: textField, position: p)
//        print("🟢 \(updatedText)")
//    }
}

// MARK: - 전화번호 델리게이터
extension EloadViewController {
    @IBAction func showProvider(_ sender: UIButton) {
        providerSpinner?.menuManager.show(sender: sender)
    }
    
    //    xeozin 2020/09/27 reason: 연락처 권한 버튼 추가
    @IBAction func showContact(_ sender: Any?) {
        var p: IndexPath?
        var contactType: ContactType?
        switch sender {
        case is TPEloadHistoryButton:
            p = (sender as? TPEloadHistoryButton)?.indexPath
            contactType = .recent
        case is TPEloadContractButton:
            p = (sender as? TPEloadContractButton)?.indexPath
            contactType = .country
        default:
            return
        }
        guard let path = p else { return }
        if let cell = self.tableView.cellForRow(at: path) as? EloadPhoneCell {
            self.tfCtn = cell.tfContent
            cell.type = contactType
            Utils.getContactPermissions(vc: self, segue: "goContact", sender: cell)
        }
        
        if let cell = self.tableView.cellForRow(at: path) as? EloadGlobalPhoneCell {
            self.tfCtn = cell.tfContent
            cell.type = contactType
            Utils.getContactPermissions(vc: self, segue: "goContact", sender: cell)
        }
        
        if let cell = self.tableView.cellForRow(at: path) as? EloadEmailCell {
            self.tfCtn = cell.tfContent
            cell.type = contactType
            Utils.getContactPermissions(vc: self, segue: "goContact", sender: cell)
        }
    }
    
    func select(text: String) {
        guard let tf = self.tfCtn as? TPTextField else { return }
        guard let indexPath = tf.indexPath else { return }
        let viewData = indexPath.section == 1 ? self.section2Datas[indexPath.row] : self.section3Datas[indexPath.row]
        
        tf.text = text
        viewData.attr?.text = text
    }
}

extension EloadViewController: PaymentViewControllerDelegate {
    
    func validEloadCTN(isValid: Bool) {
        if isValid {
            self.saveCtn()
        }
    }
    
    private func saveCtn() {
        for tf in inputs {
            guard let tf = tf as? TPTextField else { return }
            guard let indexPath = tf.indexPath else { return }
            let viewData = indexPath.section == 1 ? self.section2Datas[indexPath.row] : self.section3Datas[indexPath.row]
            guard let type = viewData.attr?.autoCompleteType else { return }
            guard let ctn = viewData.attr?.text else { return }
            guard let code = self.selectNation?.countryCode else { return }
            guard let mvnoId = self.selectNation?.mvnoId else { return }
            guard let itemId = self.selectCategory?.itemId else { return }
            Utils.saveAutoCompleteNumber(
                saveType: .eload, code: code,
                mvno: String(mvnoId),
                type: type,
                text: ctn,
                cate: itemId)
        }
    }
}
