//
//  NationListViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/16.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

protocol NationListDelegate {
    func nation(item:NationItem)
}

class NationListViewController: TPBaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var nations: [NationItem]?
    var showNations: [NationItem]?
    var delegate: NationListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        self.setupNavigationBar(type: .basic(title: Localized.title_activity_sel_nation.txt))
        getNationList()
    }
    
    private func getNationList() {
        let countryCode: String = savedInternaltionalCallISO2Code()
        
        let all = DBListManager.getNationList() as? [NationItem]
        let my = all?.filter({ item -> Bool in
            if countryCode == item.countryCode {
                return true
            } else {
                return false
            }
        })
        
        nations = all?.filter({ item -> Bool in
            if countryCode == item.countryCode {
                return false
            } else {
                return true
            }
        })
        
        if let o = my?.first {
            nations?.insert(o, at: 0)
        }
        
        showNations = nations
    }
    
    private func savedInternaltionalCallISO2Code() -> String {
        if let code = UserDefaultsManager.shared.loadInternationalCallISO2() {
            return code
        } else {
            return App.shared.codeLang.countryCode
        }
    }
    
}

extension NationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showNations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NationCell", for: indexPath) as! NationListCell
        let item = showNations?[indexPath.row]
        if let flag = UIImage(named: item?.getImgNm() ?? "") {
            cell.ivNation.image = flag
        } else {
            cell.ivNation.image = UIImage(named: "flag_0")
        }
        
        cell.lblNation.text = item?.nameUs
        cell.lblCode.text = item?.countryNumber
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = showNations?[indexPath.row] {
            delegate?.nation(item: item)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension NationListViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        showNations = nations
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            showNations = nations
        } else {
            showNations = query(searchText)
        }
        
        tableView.reloadData()
    }
    
    private func query(_ text: String) -> [NationItem]? {
        var result:[NationItem] = []
        let query:Array = text.components(separatedBy: " ")
        for item in nations ?? [] {
            for partQuery in query {
                if partQuery.isEmpty {
                    continue
                }
                
                if let _ = item.nameUs.range(of: partQuery, options: .caseInsensitive) {
                    result.append(item)
                }
                
                if let _ = item.countryNumber.range(of: partQuery, options: .caseInsensitive) {
                    if item != result.last {
                        result.append(item)
                    }
                }
            }
        }
        
        return result
    }
}
