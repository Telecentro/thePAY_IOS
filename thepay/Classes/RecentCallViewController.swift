//
//  RecentCallViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/18.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class RecentCallViewController: TPBaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: AddressDelegate?
    var list: [CallHistoryItem] = []
    var listDay: [String] = []
    var listShow: [[CallHistoryItem]] = []
    
    var addressBookType = AddressBookType.callHistory
    var countryCode = "kr"  // 이로드 전용
    var countryNumber = ""
    
    func updateDisplay() {
        if listShow.count == 0 {
            loadContactsListTask()
        }
    }
    
    func loadContactsListTask() {
        
        list.removeAll()
        
        switch addressBookType {
        case .callHistory:
            loadCallHistory()
        case .rechargeHistory:
            loadRechargeHistory()
        case .eloadEmailHistory:
            loadEloadHistory(type: ACType.email)
        case .eloadIdHistory:
            loadEloadHistory(type: ACType.id)
        case .eloadCallHistory:
            loadEloadHistory(type: ACType.num)
        case .unknown:
            list = []
        }
        
        list = list.sorted(by: { (lhs:CallHistoryItem, rhs: CallHistoryItem) -> Bool in
            return lhs.date > rhs.date
        })
        
        listToday()
    }
    
    private func loadCallHistory() {
        list = Utils.getCallHistory()
    }
    
    private func loadRechargeHistory() {
        list = Utils.getRechargeHistory(type: ACType.num, code: Tel.kr)
    }
    
    private func loadEloadHistory(type: String) {
        list = Utils.getEloadHistory(type: type, code: self.countryCode)
    }
    
    private func listToday() {
        if list.count > 0 {
            self.listToday(listData:list)
        } else {
            listShow.removeAll()
            listDay.removeAll()
            self.tableView.reloadData()
        }
    }
    
    private func listToday(listData:[CallHistoryItem]) {
        listShow.removeAll()
        listDay.removeAll()
        
        if list.count > 0 {
            var itemList:[CallHistoryItem] = []
            let format = DateFormatter()
            format.locale = App.shared.locale
            format.dateFormat = "yyyyMMddHHmmss"
            
            guard let firstCall = listData.first else {
                self.tableView.reloadData()
                return
            }
            guard var baseDate = format.date(from: firstCall.date)  else { return }
            
            // 타이틀 추가
            self.appendTitle(baseDate: baseDate)
            
            for hisItem in listData {
                guard let hisDate = format.date(from: hisItem.date) else { return }
                
                if Calendar.current.isDate(baseDate, inSameDayAs: hisDate) {
                    itemList.append(hisItem)
                } else {
                    listShow.append(contentsOf: [itemList])
                    baseDate = hisDate
                    
                    // 타이틀 추가
                    self.appendTitle(baseDate: baseDate)
                    
                    itemList = []
                    itemList.append(hisItem)
                }
            }
            
            listShow.append(contentsOf: [itemList])
        } else {
            listShow.append(contentsOf: [listData]) // 갯수 0개
        }
        
        self.tableView.reloadData()
    }
    
    private func appendTitle(baseDate: Date) {
        let displayFormat = DateFormatter()
        displayFormat.dateFormat = "yyyy.MM.dd"
        let t = displayFormat.string(from: baseDate)
        listDay.append(t)
        print("\(t)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nations = DBListManager.getNationList() as? [NationItem]
        for i in nations ?? [] {
            if i.countryCode == self.countryCode {
                self.countryNumber = i.countryNumber
            }
        }
        self.searchBar.delegate = self
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        let directionalMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        self.searchBar.directionalLayoutMargins = directionalMargins
    }
}

extension RecentCallViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listShow.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listShow[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if listDay.count > section {
            let headerId = "header"
            let header = tableView.dequeueReusableCell(withIdentifier: headerId) as! ContactHeaderCell
            header.lblDate.text = "  \(listDay[section])"
            return header
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactListCell
        
        let item = listShow[indexPath.section][indexPath.row]
        
        switch self.addressBookType {
        case .eloadIdHistory:
            cell.ivNation.image = UIImage(named: "ic_id")
        case .eloadEmailHistory:
            cell.ivNation.image = UIImage(named: "ic_email")
        default:
            if let code = item.countryCode, let image = UIImage(named: "flag_\(code)") {
                cell.ivNation.image = image
            }
        }

        switch self.addressBookType {
        case .callHistory:
            if item.countryCode == "kr" {
                cell.lblName.text = "\(StringUtils.telFormat(item.callNumber))"
            } else {
                cell.lblName.text = "+\(App.shared.nations[item.countryCode] ?? 0) \(StringUtils.telFormat(item.callNumber))"
            }
        case .eloadCallHistory:
            if item.countryCode == "kr" {
                cell.lblName.text = "\(StringUtils.telFormat(item.callNumber))"
            } else {
                // 마이그레이션 데이터는 국가 번호가 없다. 국가 코드만 존재
                // (이로드 전화 목록은 국가 코드로 검색해서 뷰컨트롤러가 결정)
                cell.lblName.text = "+\(self.countryNumber) \(StringUtils.telFormat(item.callNumber))"
            }
        case .rechargeHistory:
            cell.lblName.text = StringUtils.telFormat(item.callNumber)
        default:
            cell.lblName.text = item.callNumber
        }
        
        let formatter = DateFormatter()
        formatter.locale = App.shared.locale
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.date(from: item.date)

        let displayFormatter = DateFormatter()
        displayFormatter.locale = App.shared.locale
        displayFormatter.amSymbol = "AM"
        displayFormatter.amSymbol = "PM"
        displayFormatter.dateFormat = "a hh:mm"
        if let d = date {
            let itemTime = displayFormatter.string(from: d)
            cell.lblNumber.text = "\(itemTime)"
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = ContactInfo()
        let selectItem = listShow[indexPath.section][indexPath.row]
        item.callNumber = selectItem.callNumber
        item.countryNumber = selectItem.countryNumber
        item.countryCode = selectItem.countryCode
        item.interNumber = selectItem.interNumber
        item.text = selectItem.callNumber
        item.name = selectItem.name
        
        self.delegate?.select(item: item)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}


extension RecentCallViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        print("searchBarCancelButtonClicked search bar: \(searchBar)")
        self.listToday()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.listToday()
        } else {
            self.listToday(listData: query(searchText) ?? [])
        }
    }
    
    private func query(_ text: String) -> [CallHistoryItem]? {
        var result:[CallHistoryItem] = []
        let query:Array = text.components(separatedBy: " ")
        for item in list {
            for partQuery in query {
                if partQuery.isEmpty {
                    continue
                }
                
                if let _ = item.name.range(of: partQuery, options: .caseInsensitive) {
                    result.append(item)
                }
                
                if let _ = item.callNumber.range(of: partQuery, options: .caseInsensitive) {
                    if item != result.last {
                        result.append(item)
                    }
                }
            }
        }
        
        return result
    }
}
