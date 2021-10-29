//
//  AutoCompleteViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/25.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

protocol AutoCompleteDelegate {
    func updateAutoCompleteHeight(height: Int)
    func selectItem(phoneNumber: String)
    func hiddenAutoComplete(hidden: Bool)
}

class AutoCompleteViewController: UIViewController {
    
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    private var autoCompleteList: [AutoCompleteItem] = []
    private var rechargeList: [AutoCompleteItem] = []
    private var height = 0
    
    static let cellHeight = 44
    
    var delegate:AutoCompleteDelegate?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoTableView(hidden: true)
        
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
    }
    
    func updateData(type: String, code: String) {
        rechargeList = Utils.getAutoCompleteHistory(type: type, code: code)
        reload()
    }
    
    func processingAutoTable(text: String, type: String?, code: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { [weak self] t in
            self?.search(text: text, type: type ?? "", code: code)
        })
    }
    
    private func search(text: String, type: String, code: String) {
        let removeDashText = text.removeDash()
        if removeDashText.count < 3 || rechargeList.isEmpty {
            autoTableView(hidden: true)
            return
        }
        
        autoCompleteList = []
        
        autoCompleteList = rechargeList.filter({ item -> Bool in
            if type == ACType.email || type == ACType.id {
                if item.isNotValidTextItem() {
                    return false
                }
                
                if item.text.contains(removeDashText) {
                    return true
                } else {
                    return false
                }
            }
            return Utils.isValidAutoCompleteItem(item: item, text: removeDashText, type: type, code: code)
        })
        
        if autoCompleteList.isEmpty {
            autoTableView(hidden: true)
            return
        }
        
        let maxHeight = AutoCompleteViewController.cellHeight * 3
        height = (AutoCompleteViewController.cellHeight * autoCompleteList.count) > maxHeight ? maxHeight : (AutoCompleteViewController.cellHeight * autoCompleteList.count)
        
        delegate?.updateAutoCompleteHeight(height: height)
        autoTableView(hidden: false)
        reload()
    }
    
    private func reload() {
        autoCompleteTableView.reloadData()
    }
    
    func autoTableView(hidden: Bool) {
        delegate?.hiddenAutoComplete(hidden: hidden)
        autoCompleteTableView.isHidden = hidden
    }
}

extension AutoCompleteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🟣 count \(autoCompleteList.count)")
        return autoCompleteList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(AutoCompleteViewController.cellHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactListCell
        guard let txt = autoCompleteList[exist: indexPath.row]?.text else {
            return UITableViewCell()
        }
        
        cell.lblName.text = txt
        if (txt.first?.isNumber ?? false) {
            let code = autoCompleteList[indexPath.row].code
            cell.ivNation.image = UIImage(named: "flag_\(code)")
            cell.ivNation.superview?.isHidden = false
        } else {
            cell.ivNation.superview?.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        autoTableView(hidden: true)
        delegate?.selectItem(phoneNumber: autoCompleteList[indexPath.row].text)
    }
    
}


