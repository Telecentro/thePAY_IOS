//
//  InternationalCallViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import SafariServices
import SPMenu

class InternationalCallViewController: TPAutoCompleteViewController, TPLocalizedController {
    
    enum ProductType: String {
        case KT = "192"
        case SKT = "193"
        
        var index: Int {
            switch self {
            case .KT:
                return 0
            case .SKT:
                return 1
            }
        }
    }
    
    @IBOutlet weak var lblPhoneTitle: UILabel!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblChargeAmountTitle: UILabel!
    @IBOutlet weak var lblLanguageTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet var btnProducts: [UIButton]!
    
//    @IBOutlet weak var tfPhone: TPTextField!
    @IBOutlet weak var tfLanguage: TPTextField!
    @IBOutlet weak var tfAmount: TPTextField!
    
    var menuLang:MenuManager<SubPreloadingResponse.intl.arsLang>? = MenuManager()
    var menuAmount:MenuManager<SubPreloadingResponse.intl.amounts>? = MenuManager()
    
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var btnCharge: UIButton!
    
    @IBOutlet weak var lblNavTitle: TPLabel!
    @IBOutlet weak var lblNavSubTitle: TPLabel!
    
    var intl:[SubPreloadingResponse.intl]? = []
    var selectedItem: SubPreloadingResponse.intl?
    var prodType: ProductType?
    
    var paymentViewController: PaymentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    
    func initialize() {
        self.createMenu()
        
        self.tfPhone.delegate = self
        
        // KT / SKT
        if let prodType = ProductType(rawValue: self.params?["product_type"] as? String ?? "") {
            self.prodType = prodType
        } else {
            self.prodType = ProductType(rawValue: App.shared.pre?.O_DATA?.SelectInternationalCallTab ?? ProductType.KT.rawValue)
        }
        
        requestSubPreloading(opCode: .intl) { [weak self] (data:[Any]?) -> Void in
            guard let self = self else { return }
            self.intl = App.shared.intl
            self.setupButton()
        }
    }
    
    private func createMenu() {
        menuLang = MenuManager()
        menuLang?.menu?.selectItem = { [weak self] in
            guard let self = self else { return }
            if let data = $0 {
                self.tfLanguage.text = data.langName
            }
        }
        
        menuAmount = MenuManager()
        menuAmount?.menu?.selectItem = { [weak self] in
            guard let self = self else { return }
            if let data = $0 {
                self.tfAmount.text = data.amount?.currency.won
                self.selectProduct(data: data)
            }
        }
    }
    
    func localize() {
        self.setupNavigationBar(type: .basic(title: Link.international_call.title))
        self.lblNavTitle.text = NavContents.intercall.title
        self.lblNavSubTitle.text = NavContents.intercall.subTitle
        self.tfPhone.text = Utils.updatePhoneNumber()
        self.lblPhoneTitle.text = Localized.recharge_number.txt
        self.lblProductTitle.text = Localized.recharge_goods.txt
        self.lblLanguageTitle.text = Localized.arslanguage_kt.txt
        self.lblChargeAmountTitle.text = Localized.recharge_amount.txt
        self.btnRate.setTitle(Localized.activity_call_rate.txt, for: .normal)
        self.btnCharge.setTitle(Localized.btn_recharge.txt, for: .normal)
    }
    
    private func setupButton() {
        for b in self.btnProducts {
            b.isSelected = false
        }
        
        let index = self.prodType?.index ?? 0
        self.btnProducts[index].isSelected = true
        self.selectedItem = intl?[index]
        
        menuAmount?.updateData(data: MenuDataConverter.intlAmount(value: self.selectedItem?.amounts))
        menuLang?.updateData(data: MenuDataConverter.intlLang(value: self.selectedItem?.arsLang))
        
        updateDisplay()
    }
    
    private func updateDisplay() {
        // show description
        if let noticeType = self.selectedItem?.noticeType {
            if noticeType == "web" {
                if let noticeContents = self.selectedItem?.noticeContents {
                    self.lblDesc.attributedText = noticeContents.convertHtml(fontSize: 18)
                    self.lblDesc.isHidden = false
                } else {
                    self.lblDesc.isHidden = true
                }
            } else {
                if let noticeContents = self.selectedItem?.noticeContents {
                    self.lblDesc.text = noticeContents
                    self.lblDesc.isHidden = false
                } else {
                    self.lblDesc.isHidden = true
                }
            }
        }
    }
    
    private func selectProduct(data: SubPreloadingResponse.intl.amounts) {
        guard let mvnoId = self.selectedItem?.mvnoId else { return }
        guard let price = data.amount else { return }
        let data = ProductData(mvnoId: mvnoId, rcgType: "I", price: Int(price) ?? 0)
        self.paymentViewController?.updateProductData(data: data)
    }
    
    @IBAction func showContact(_ sender: Any) {
        Utils.getContactPermissions(vc: self, segue: "goContact", sender: sender)
    }
}

extension InternationalCallViewController {
    
    @IBAction func onClickKT(_ sender: TPButton) {
        sender.debounce(delay: 0.1) { [weak self] in
            guard let self = self else { return }
            if self.prodType == .KT { return }
            self.prodType = .KT
            self.setupButton()
        }
    }
    
    @IBAction func onClickSKT(_ sender: TPButton) {
        sender.debounce(delay: 0.1) { [weak self] in
            guard let self = self else { return }
            if self.prodType == .SKT { return }
            self.prodType = .SKT
            self.setupButton()
        }
    }
    
    @IBAction func showRate(_ sender: Any) {
        var urlString = ""
        var titleString = ""
        var moveLink: String?
        switch self.prodType {
        case .KT:
            titleString = Localized.title_activity_rates.txt
            moveLink = App.shared.pre?.O_DATA?.subMoveLinkList?[exist: 1]?.moveLink
        case .SKT:
            titleString = Localized.title_activity_rates_sk.txt
            moveLink = App.shared.pre?.O_DATA?.subMoveLinkList?[exist: 2]?.moveLink
        case .none:
            break
        }
        
        if let url = SegueUtils.parseSchemeWebURL(moveLink: moveLink) {
            urlString = url
        }
        
        if let vc = Link.webview.viewController as? WebViewController {
            vc.needFakeButton = false
            vc.titleString = titleString
            vc.urlString = urlString
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // 충전
    @IBAction func charge(_ sender: Any) {
        let lang = menuLang?.menu?.getItem()?.langCd ?? "2" // English
        self.paymentViewController?.charge(ctn: self.tfPhone.text?.removeDash() ?? "", lang: lang)
    }
    
    // 금액 설정
    @IBAction func showAmountList(_ sender: UIView) {
        menuAmount?.show(sender: sender)
    }
    
    // 언어 설정
    @IBAction func showLanguageList(_ sender: UIView) {
        menuLang?.show(sender: sender)
    }
}

extension InternationalCallViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? PaymentViewController {
            self.paymentViewController = vc
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
                self.tfPhone.text = Utils.format(phone: number)
            }
            self.view.endEditing(true)
        }
    }
}
