//
//  SKTDataViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

protocol SKTDataDelegate {
    func selectProduct(data: SubPreloadingResponse.coupon?)
}

class SKTDataViewController: TPAutoCompleteViewController, TPLocalizedController, SKTDataDelegate {
    
    @IBOutlet weak var lblPhoneTitle: UILabel!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblChargeAmountTitle: UILabel!
//    @IBOutlet weak var tfPhone: UITextField!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblChargeAmount: UILabel!
    @IBOutlet weak var cvAmountList: UIView!
    @IBOutlet weak var blurVIew: UIVisualEffectView!
    @IBOutlet weak var btnRecharge: TPButton!
    
    @IBOutlet weak var lblNavTitle: TPLabel!
    @IBOutlet weak var lblNavSubTitle: TPLabel!
    
    var sktListViewController:SKTListViewController?
    
    var sktLTEData:[SubPreloadingResponse.coupon]? = []
    var selectedLTEData:SubPreloadingResponse.coupon?
    var paymentViewController: PaymentViewController?
    var tapGesture: UITapGestureRecognizer?
    var sktDataDelegate: SKTDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
        addTapEvent()
    }
    
    func initialize() {
        requestSubPreloading(opCode: .coupon) { [weak self] (data:[Any]?) -> Void in
            guard let self = self else { return }
            self.sktLTEData = App.shared.coupon
            self.setupData()
        }
        
        self.tfPhone.delegate = self
        self.tfPhone.keyboardType = .numberPad
        self.tfPhone.text = Utils.updatePhoneNumber()
    }
    
    func localize() {
        self.lblPhoneTitle.text = Localized.recharge_number.txt
        self.lblProductTitle.text = Localized.recharge_goods.txt
        self.lblChargeAmountTitle.text = Localized.recharge_amount.txt
        self.btnRecharge.setTitle(Localized.btn_recharge.txt, for: .normal)
        
        self.lblNavTitle.text = NavContents.skt_data.title
        self.lblNavSubTitle.text = NavContents.skt_data.subTitle
    }
    
    private func setupData() {
        guard let data = self.sktLTEData else {
            exit()
            return
        }
        
        if data.count < 1 {
            exit()
            return
        }
        
        selectProduct(data: data.first)
        
        sktListViewController?.sktLTEData = App.shared.coupon
        sktListViewController?.tableView.reloadData()
    }
    
    internal func addTapEvent() {
        if self.tapGesture == nil {
            self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        }
        
        if let tap = self.tapGesture {
            self.blurVIew.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapHandler() {
        self.showContainerView(show: true)
    }
    
    private func showContainerView(show: Bool) {
        self.blurVIew.isHidden = show
        self.cvAmountList.isHidden = show
        self.tfPhone.resignFirstResponder()
        self.autoComplete?.autoTableView(hidden: true)
    }
    
    func selectProduct(data: SubPreloadingResponse.coupon?) {
        self.showContainerView(show: true)
        self.selectedLTEData = data
        self.lblProduct.text = data?.mvnoName
        self.lblChargeAmount.text = String(data?.price ?? 0).currency.won
        
        guard let mvnoId = data?.mvnoId else { return }
        guard let rcgType = data?.rcgType else { return }
        guard let price = data?.price else { return }
        let data = ProductData(mvnoId: mvnoId, rcgType: rcgType, price: price)
        self.paymentViewController?.updateProductData(data: data)
    }
    
    private func exit() {
        Localized.toast_msg_connect_fail.txt.showErrorMsg(target: self.parent?.view)
        self.navigationController?.popViewController(animated: true)
    }
    
    //    xeozin 2020/09/27 reason: 연락처 권한 버튼 추가
    @IBAction func showContact(_ sender: Any) {
        Utils.getContactPermissions(vc: self, segue: "goContact", sender: sender)
    }
    
    @IBAction func showNoti(_ sender: Any) {
        showConfirmAlert(title: Localized.alert_title_confirm.txt,
                         message: Localized.alert_msg_sklite_guide.txt)
    }
    
    @IBAction func showChargeList(_ sender: Any) {
        self.showContainerView(show: false)
    }
    
    @IBAction func charge(_ sender: Any) {
        if let ctn = self.tfPhone.text?.removeDash() {
            self.paymentViewController?.charge(ctn: ctn)
        }
        
        self.showContainerView(show: true)
    }
}

extension SKTDataViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? PaymentViewController {
            self.paymentViewController = vc
            vc.paymentTitle = self.title
            vc.view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        else if let vc = segue.destination as? SKTListViewController {
            vc.delegate = self
            sktListViewController = vc
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
