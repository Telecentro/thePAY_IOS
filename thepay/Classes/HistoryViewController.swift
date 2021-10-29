//
//  PaymentHistoryViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/07.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

struct SegmentType {
    static let charge   = 0
    static let cash     = 1
    static let point    = 2
}

class HistoryCell: UITableViewCell {
    @IBOutlet weak var lblDate: TPLabel!
    @IBOutlet weak var lblAmount: TPCountLabel!
    @IBOutlet weak var lblGB: TPLabel!
    @IBOutlet weak var lblState: TPLabel!
    @IBOutlet weak var btnState: TPButton!
}

struct SearchCondition {
    var dayRow = 0
    var resultRow = 0
    var itemRow = 0
    var ioRow = 0
}

class HistoryViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var tfBlank: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var smControl: UISegmentedControl!
    @IBOutlet weak var btnUpdate: TPButton!
    @IBOutlet weak var btnSearch: TPButton!
    
    @IBOutlet weak var lblMyCash: TPCountLabel!
    @IBOutlet weak var lblMyPoint: TPCountLabel!
    @IBOutlet weak var lblMyAccount: TPLabel!
    @IBOutlet weak var lblDate: TPLabel!
    @IBOutlet weak var lblPrice: TPLabel!
    @IBOutlet weak var lblItem: TPLabel!
    @IBOutlet weak var lblState: TPLabel!
    @IBOutlet weak var viewBankBG: UIView!
    
    private var chargeResponse: RechargeHistoryResponse?
    private var cashResponse: CashHistoryResponse?
    private var pointResponse: PointHistoryResponse?
    
    private var day:[[String:String]] = [[:]]
    private var result:[[String:String]] = [[:]]
    private var item:[[String:String]] = [[:]]
    private var io:[[String:String]] = [[:]]
    
    private let daysCode = "daysCode"
    private let daysEngNames = "dayEnName"
    private let stateCode = "stateCode"
    private let stateName = "stateName"
    private let itemCode = "itemCode"
    private let itemName = "itemName"
    private let ioCode = "ioCode"
    private let ioName = "ioName"

    private var searchRow = SearchCondition()
    private var lastSearchRow:SearchCondition?
    
    private var segNumber: Int = 0
    private var seqValue: Int = 0
    
    private var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .white
        return picker
    } ()
    
    private var toolBar: UIToolbar = {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.backgroundColor = UIColor(named: "Primary")
        
        let done = UIBarButtonItem(title: Localized.btn_confirm.txt, style: .done, target: self, action: #selector(pressDone))
        let cancel = UIBarButtonItem(title: Localized.btn_cancel.txt, style: .done, target: self, action: #selector(pressCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([cancel, flexibleSpace, done], animated: false)
        
        done.tintColor = .white
        cancel.tintColor = .white
        return toolbar
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
        
    func localize() {
        self.btnSearch.setTitle(Localized.btn_search_setting.txt, for: .normal)
        self.smControl.setFontSize(fontSize: 14)
        self.smControl.setTitle(Localized.tab_recharge.txt, forSegmentAt: SegmentType.charge)
        self.smControl.setTitle(Localized.tab_cash.txt, forSegmentAt: SegmentType.cash)
        self.smControl.setTitle(Localized.tab_point.txt, forSegmentAt: SegmentType.point)
        self.lblDate.text = Localized.history_title_date.txt
        self.lblPrice.text = Localized.history_title_price.txt
        self.lblItem.text = Localized.history_title_item.txt
        self.lblState.text = Localized.history_title_result.txt
        self.lblMyCash.text = "￦ \(UserDefaultsManager.shared.loadMyCash()?.currency ?? "")"
        self.lblMyPoint.text = "ⓟ \(UserDefaultsManager.shared.loadMyPoint()?.currency ?? "")"
        self.lblMyAccount.text = UserDefaultsManager.shared.loadMyBankAccount()
        self.imgView.image = UIImage(named: UserDefaultsManager.shared.loadBankImgName() ?? "")
        if self.imgView.image == nil {
            viewBankBG.isHidden = true
        }
    }
    
    func initialize() {
        self.historyTableView.dataSource = self
        self.historyTableView.delegate = self
        self.historyTableView.separatorStyle = .none
        self.picker.dataSource = self
        self.picker.delegate = self
        self.tfBlank.tintColor = .clear
        self.tfBlank.inputView = self.picker
        self.tfBlank.inputAccessoryView = self.toolBar
        generateData()
        // 최초 통신
        requestHistoryRecharge()
    }
    
    // 새로고침 버튼
    @IBAction func pressUpdate(_ sender: UIButton) {
        self.btnUpdate.imageView?.transform = CGAffineTransform.identity
        self.btnUpdate.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            self.btnUpdate.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        requestRemains()
    }
    
    // 세그먼트 버튼
    @IBAction func moveSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case SegmentType.charge:
            requestHistoryRecharge()
        case SegmentType.cash:
            requestHistoryCash()
        case SegmentType.point:
            requestHistoryPoint()
        default: break
        }
        
        self.segNumber = sender.selectedSegmentIndex
        self.searchRow.itemRow = 0
        self.searchRow.ioRow = 0
        self.searchRow.resultRow = 0
        self.picker.reloadAllComponents()
        
        selectRow()
    }
    
    // 조건검색 버튼
    @IBAction func searchSetting(_ sender: Any) {
        if tfBlank.isFirstResponder {
            return
        }
        self.tfBlank.becomeFirstResponder()
        selectRow()
    }
    
    private func selectRow() {
        if segNumber == SegmentType.charge {
            picker.selectRow(self.searchRow.dayRow, inComponent: 0, animated: false)
            picker.selectRow(self.searchRow.resultRow, inComponent: 1, animated: false)
            picker.selectRow(self.searchRow.itemRow, inComponent: 2, animated: false)
        } else if segNumber == SegmentType.cash || segNumber == SegmentType.point {
            picker.selectRow(self.searchRow.dayRow, inComponent: 0, animated: false)
            picker.selectRow(self.searchRow.ioRow, inComponent: 1, animated: false)
        }
    }
    
    private func resetCondition() {
//        self.searchRow.itemRow = 0
//        self.searchRow.resultRow = 0
        self.selectRow()
    }
    
    @IBAction func showError(_ sender: UIButton) {
        self.showLoadingWindow()
        guard let ctn = UserDefaultsManager.shared.loadANI() else { return }
        let lang = UserDefaultsManager.shared.loadNationCode()
        let param = RcgFailNoteRequest.Param(ctn: ctn , rcgSeq: String(sender.tag), langCode: lang)
        let req = RcgFailNoteRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam2()) { [weak self] (response:Swift.Result<RcgFailNoteResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                if let data = data.O_DATA {
                    let lowNoteVisible = data.noteVisible?.lowercased()
                    let lowNoteSize = data.noteSize?.lowercased()
                    let lowNoteType = data.noteType?.lowercased()
                    
                    if lowNoteVisible == NoteVisible.y.rawValue {
                        switch lowNoteSize {
                        case NoteSize.f.rawValue:
                            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PushHistory") as? PushHistoryViewController else { return }
                            vc.title = data.noteTitle
                            vc.contents = data.noteContents
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        case NoteSize.a.rawValue:
                            if lowNoteType == NoteType.web.rawValue {
                                self.showConfirmHTMLAlert(title: data.noteTitle, htmlString: data.noteContents ?? "")
                                
                            } else if lowNoteType == NoteType.text.rawValue {
                                self.showConfirmAlert(title: data.noteTitle, message: data.noteContents ?? "")
                            }
                            
                        default: break
                        }
                    }
                }
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
}

// MARK: - Extension
extension HistoryViewController {
    // 피커 데이터 생성
    private func generateData() {
        day = [[daysCode:"1", daysEngNames:"1 Day"],
               [daysCode:"7", daysEngNames:"7 Day"],
               [daysCode:"15", daysEngNames:"15 Day"],
               [daysCode:"30", daysEngNames:"30 Day"]]
        
        result = [[stateCode:"", stateName:"All"],
                  [stateCode:"2", stateName:"Success"],
                  [stateCode:"1", stateName:"Processing"],
                  [stateCode:"0", stateName:"Waiting"],
                  [stateCode:"9", stateName:"Fail"]]
        
        item = [[itemCode:"", itemName:"All"],
                [itemCode:"V", itemName:"Voice"],
                [itemCode:"D", itemName:"Data"],
                [itemCode:"I", itemName:"Int,Card"]]
        
        io = [[ioCode:"", ioName:"All"],
              [ioCode:"I", ioName:"Deposit"],
              [ioCode:"O", ioName:"Withdraw"],
              [ioCode:"T", ioName:"Trans"]]
    }
    
    // 피커 선택 버튼
    @objc private func pressDone() {
        switch segNumber {
        case SegmentType.charge:
            requestHistoryRecharge()
        case SegmentType.cash:
            requestHistoryCash()
        case SegmentType.point:
            requestHistoryPoint()
        default: break
        }
        
        self.tfBlank.endEditing(true)
    }
    
    // 피커 취소 버튼
    @objc private func pressCancel() {
        self.tfBlank.endEditing(true)
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segNumber {
        case SegmentType.charge:
            if let chargeData = self.chargeResponse?.O_DATA?.rcgList {
                return chargeData.count
            }
        case SegmentType.cash:
            if let cashData = self.cashResponse?.O_DATA?.cashList {
                return cashData.count
            }
        case SegmentType.point:
            if let pointData = self.pointResponse?.O_DATA?.pointList {
                return pointData.count
            }
        default: break
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.selectionStyle = .none
        cell.btnState.isHidden = true
        
        switch segNumber {
        case SegmentType.charge:
            if let data = self.chargeResponse?.O_DATA?.rcgList {
//                self.seqValue = data[indexPath.row].rcgSeq ?? 0
                if data[indexPath.row].rcgCode == "2" { // 서버에서 내려준 rcgCode 값
                    cell.btnState.isHidden = true
                } else {
                    cell.btnState.isHidden = false
                }
                cell.btnState.tag = data[indexPath.row].rcgSeq ?? 0
                cell.lblAmount.text = data[indexPath.row].rcgAmt?.currency
                cell.lblGB.text = data[indexPath.row].rcgType
                cell.lblDate.text = "\(data[indexPath.row].rday ?? "")\n\(data[indexPath.row].rcgTime ?? "")"
                cell.lblState.text = data[indexPath.row].rcgStatus
                cell.btnState.setTitle(data[indexPath.row].rcgStatus, for: .normal)
            }
            
        case SegmentType.cash:
            if let data = self.cashResponse?.O_DATA?.cashList {
                cell.lblAmount.text = String(data[indexPath.row].cashAmt ?? 0).currency
                cell.lblGB.text = data[indexPath.row].cashType
                cell.lblDate.text = "\(data[indexPath.row].cashDay ?? "")\n\(data[indexPath.row].cashTime ?? "")"
                cell.lblState.text = data[indexPath.row].cashMethod
                cell.btnState.setTitle(data[indexPath.row].cashMethod, for: .normal)
            }
            
        case SegmentType.point:
            if let data = self.pointResponse?.O_DATA?.pointList {
                cell.lblAmount.text = String(data[indexPath.row].pointAmt ?? 0).currency
                cell.lblGB.text = data[indexPath.row].pointType
                cell.lblDate.text = "\(data[indexPath.row].pointDay ?? "")\n\(data[indexPath.row].pointTime ?? "")"
                cell.lblState.text = data[indexPath.row].pointMethod
                cell.btnState.setTitle(data[indexPath.row].pointMethod, for: .normal)
            }
        default: break
        }
        
        return cell
    }
}

// MARK: - UIPickerViewDelegate
extension HistoryViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // PickerView 열
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if segNumber == SegmentType.charge {
            return 3
        } else if segNumber == SegmentType.cash || segNumber == SegmentType.point {
            return 2
        }
        
        return 0
    }
    
    // PickerView 값 넣기
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if segNumber == SegmentType.charge {
            switch component {
            case 0:
                return day[row][daysEngNames]
            case 1:
                return result[row][stateName]
            case 2:
                return item[row][itemName]
            default: break
            }

        } else if segNumber == SegmentType.cash || segNumber == SegmentType.point {
            switch component {
            case 0:
                return day[row][daysEngNames]
            case 1:           // picker component가 순서대로 넣어야돼서 item -> state로
                return io[row][ioName]
            default: break
            }
        }

        return nil
    }
    
    // PickerView 갯수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if segNumber == SegmentType.charge {
            switch component {
            case 0:
                return day.count
            case 1:
                return result.count
            case 2:
                return item.count
            default: break
            }

        } else if segNumber == SegmentType.cash || segNumber == SegmentType.point {
            switch component {
            case 0:
                return day.count
            case 1:       // picker component가 순서대로 넣어야돼서 item -> state로
                return io.count
            default: break
            }
        }
        
        return 0
    }
    
    // PickerView 고르기
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if segNumber == SegmentType.charge {
            switch component {
            case 0:
                self.searchRow.dayRow = row
            case 1:
                self.searchRow.resultRow = row
            case 2:
                self.searchRow.itemRow = row
            default: break
            }

        } else if segNumber == SegmentType.cash || segNumber == SegmentType.point {
            switch component {
            case 0:
                self.searchRow.dayRow = row
            case 1:       // picker component가 순서대로 넣어야돼서 item -> state로
                self.searchRow.ioRow = row
            default: break
            }
        }
    }
}

// MARK: - 통신
extension HistoryViewController {
    func requestRemains() {
        let req = RemainsRequest()
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RemainsResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                print("request reamins: \(data)")
                self.lblMyCash.text = "￦ \(String(data.O_DATA?.cash ?? 0).currency)"
                self.lblMyPoint.text = "ⓟ \(String(data.O_DATA?.point ?? 0).currency)"
                self.lblMyAccount.text = data.O_DATA?.virAccountId
                self.imgView.image = UIImage(named: data.O_DATA?.imgNm ?? "")

            case .failure(let error):
                // .timeout 에러에 대해서 예외처리 (아무 동작 안함)
                error.processError(target: self, type: .remain)
            }
        }
    }
    
//    충전내역
    func requestHistoryRecharge() {
        self.showLoadingWindow()
        let day = self.day[searchRow.dayRow][daysCode] ?? ""
        let status = self.result[searchRow.resultRow][stateCode] ?? ""
        let type = self.item[searchRow.itemRow][itemCode] ?? ""
        let param = RechargeHistoryRequest.Param(DAY: day, rcgStatus: status, rcgType: type)
        let req = RechargeHistoryRequest(param: param)
        API.shared.request(url: req.getAPI(), param: req.getParam()) { [weak self] (response:Swift.Result<RechargeHistoryResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.chargeResponse = data
                self.historyTableView.reloadData()
                
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    func requestHistoryCash() {
        self.showLoadingWindow()
        let day = self.day[searchRow.dayRow][daysCode] ?? ""
        let io = self.io[searchRow.ioRow][ioCode] ?? ""
        let param2 = CashHistoryRequest.Param(DAY: day, IO: io)
        let req2 = CashHistoryRequest(param: param2)
        API.shared.request(url: req2.getAPI(), param: req2.getParam()) { [weak self] (response:Swift.Result<CashHistoryResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.cashResponse = data
                self.historyTableView.reloadData()
                
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
    
    func requestHistoryPoint() {
        self.showLoadingWindow()
        let day = self.day[searchRow.dayRow][daysCode] ?? ""
        let io = self.io[searchRow.ioRow][ioCode] ?? ""
        let param3 = PointHistoryRequest.Param(DAY: day, IO: io)
        let req3 = PointHistoryRequest(param: param3)
        print(self.searchRow)
        API.shared.request(url: req3.getAPI(), param: req3.getParam()) { [weak self] (response:Swift.Result<PointHistoryResponse, TPError>) -> Void in
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.pointResponse = data
                self.historyTableView.reloadData()
                
            case .failure(let error):
                error.processError(target: self)
            }
            
            self.hideLoadingWindow()
        }
    }
}
