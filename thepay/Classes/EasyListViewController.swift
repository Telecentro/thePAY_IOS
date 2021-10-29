//
//  EasyPayInfoViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/15.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasyListViewController : TPBaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewFooter: UIView!
    @IBOutlet weak var btnDelete: TPButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEasyPaymentAdd: UILabel!
    
    var tempView:UIView?
    
    private var editMode = false
    private var showAddButton = false
    private var listData:[ListEasyResponse.easyPayList]?
    
    private var prev2PhotoData:[String: String]?
    private var prev3CardData:[String: String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
}

// MARK: 버튼 이벤트
extension EasyListViewController {
    
    // 삭제 이벤트
    @IBAction func deleteItem(_ sender: TPButton) {
        editMode = !editMode
        if editMode {
            btnDelete.setTitle(Localized.btn_cancel.txt, for: .normal)
            btnDelete.setImage(nil, for: .normal)
        } else {
            btnDelete.setTitle("", for: .normal)
            btnDelete.setImage(UIImage(named: "ic_edit_easy_pay_card"), for: .normal)
        }
        updateDisplay()
        tableView.reloadData()
    }
    
    private func updateDisplay() {
        if self.showAddButton && !editMode {
            tableView.tableFooterView = tempView
            tempView = nil
        } else {
            tempView = tableViewFooter
            tableView.tableFooterView = UIView()
        }
    }
    
    // 개벌 아이템 삭제
    @IBAction func deleteIndexItem(_ sender: IndexedButton) {
        guard let indexPath = sender.indexPath else { return }
        self.showCheckAlert(title: Localized.alert_title_easy_payment_deletion.txt, message: Localized.alert_content_are_you_sure_delete_easy_payment.txt) { [weak self] in
            if let seq = self?.listData?[exist: indexPath.row]?.easyPaySubSeq {
                self?.deleteEasy(indexPath: indexPath, seq: seq)
            }
        } cancel: { }
    }
    
}

// MARK: 번역, 초기화
extension EasyListViewController: TPLocalizedController {
    
    func localize() {
        lblTitle.text = Localized.text_title_my_easy_payment.txt
        lblEasyPaymentAdd.text = Localized.text_title_easy_payment_added.txt
    }
    
    func initialize() {
        self.tempView = self.tableView.tableFooterView
        
        requestEasyList()
    }
    
}

// MARK: 테이블 뷰
extension EasyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if editMode {
            let c = tableView.dequeueReusableCell(withIdentifier: EasyDeleteListCell.cellIdentifier, for: indexPath) as! EasyDeleteListCell
            c.lblCardName.text = String(listData?[indexPath.row].easyPaySubSeq ?? 0)
            c.lblCardNum.text = listData?[indexPath.row].cardnum
            c.lblCardDate.text = listData?[indexPath.row].cardRegDt
            c.btnDelete.indexPath = indexPath
            
            cell = c
        } else {
            let c = tableView.dequeueReusableCell(withIdentifier: EasyListCell.cellIdentifier, for: indexPath) as! EasyListCell
            c.lblCardName.text = String(listData?[indexPath.row].easyPaySubSeq ?? 0)
            c.lblCardNum.text = listData?[indexPath.row].cardnum
            c.lblCardDate.text = listData?[indexPath.row].cardRegDt
            c.lblCardStatus.text = listData?[indexPath.row].cardStatusMsg
            c.ivCard.image = getCardImage(row: indexPath.row)
            cell = c
        }
        
        
        return cell!
    }
    
    private func getCardImage(row: Int) -> UIImage? {
        switch row {
        case 1:
            return UIImage(named: "img_easy_pay_small_card2")
        case 2:
            return UIImage(named: "img_easy_pay_small_card3")
        case 3:
            return UIImage(named: "img_easy_pay_small_card4")
        case 4:
            return UIImage(named: "img_easy_pay_small_card5")
        default:
            return UIImage(named: "img_easy_pay_small_card1")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !editMode {
            if let seq = listData?[indexPath.row].easyPaySubSeq {
                requestEasyPrepare(seq: String(seq))
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            if let seq = self.listData?[indexPath.row].easyPaySubSeq {
//                deleteEasy(indexPath: indexPath, seq: seq)
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if editMode {
            return 75
        } else {
            return 108
        }
    }
    
    // 아이템 선택
    private func selectItem(data: PreEasyResponse.O_DATA?, msg: String?, seq: String) {
        guard let d = data else { return }
        
        // 초기화
        EasyRegInfo.shared.clean()
        
        // STEP2번 값이 있으면 받기, STEP2,3 값이 있으면 받기
        if let value = d.easyPayStepValue, let step2 = value.step2, let f1 = step2.first {
            EasyRegInfo.shared.step2 = f1
            
            if let step3 = value.step3, let f2 = step3.first {
                EasyRegInfo.shared.step3 = f2
            }
            
            showMsg(msgType: d.msgBoxGubun, resultMsg: msg, easyPaySubSeq: seq, moveLink: d.moveLink)
        } else {
            showMsg(msgType: d.msgBoxGubun, resultMsg: msg, easyPaySubSeq: seq, moveLink: d.moveLink)
        }
    }
    
    // 다음 화면으로 이동
    private func showMsg(msgType: String?, resultMsg: String?, easyPaySubSeq: String, moveLink: String?) {
        guard let type = msgType, let msg = resultMsg else { return }
        switch type {
        case "alert":
            self.showCheckAlert(title: Localized.alert_title_confirm.txt, message: msg) {
                // 선택한 카드의 seq값을 담기 [String: String]
                print("이전스텝 값 없음 - 카드리스트 선택한 카드 seq 값 : \(easyPaySubSeq)")
                if let m = moveLink {
                    SegueUtils.parseMoveLink(target: self, link: m, addParams: [UDP.seq:easyPaySubSeq])
                }
            } cancel: { }
        case "toast":
            msg.showErrorMsg(target: self.view)
        default:
            break
        }
    }
    
    // 리스트 갱신 (통신 결과)
    private func successEasyPayList(list: [ListEasyResponse.easyPayList]?) {
        listData = list
        tableView.reloadData()
    }
    
}

// MARK: 통신
extension EasyListViewController {
    
    // 테이블 뷰 셀 선택
    private func requestEasyPrepare(seq: String) {
        let params = PreEasyRequest.Param(easyPaySubSeq: seq)
        let req = PreEasyRequest(param: params)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<PreEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                self.selectItem(data: data.O_DATA, msg: data.O_MSG, seq: seq)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // 리스트 요청
    private func requestEasyList() {
        let params = ListEasyRequest.Param(opCode: FLAG.A)
        let req = ListEasyRequest(param: params)
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<ListEasyResponse, TPError>) -> Void in
            switch response {
            case .success(let data):
                self.showAddButton = data.O_DATA?.easyPayAddFlag == FLAG.Y
                self.updateDisplay()
                self.successEasyPayList(list: data.O_DATA?.easyPayList)
            case .failure(let error):
                error.processError(target: self)
            }
            self.hideLoadingWindow()
        }
    }
    
    // 삭제 요청
    private func deleteEasy(indexPath: IndexPath, seq:Int) {
        let params = DeleteEasyRequest.Param(easyPaySubSeq: String(seq))
        let req = DeleteEasyRequest(param: params)
        self.showLoadingWindow()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { (response: Swift.Result<DeleteEasyResponse, TPError>) -> Void in
            switch response {
            case .success(_):
                // 삭제 후 이동페이지
                self.requestEasyList()
            case .failure(let error):
                print(error)
            }
            
            self.hideLoadingWindow()
        }
    }
}
