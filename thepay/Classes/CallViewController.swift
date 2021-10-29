//
//  CallViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/18.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import Contacts


struct ContactInfo: Equatable {
    var countryCode: String?    // kr
    var countryNumber: String?  // 82
    var interNumber: String?    // 00796, 00301
    var callNumber: String?     // 연락처
    var name: String?           // 이름
    var type: String?           // 타입
    var text: String?           // ID, Email
    var date: Date?             // 시간
    var isSelf: Bool = false
    
    public static func ==(lhs: ContactInfo, rhs: ContactInfo) -> Bool {
        lhs.callNumber == rhs.callNumber && lhs.name == rhs.name
    }
}

class CallViewController: TPBaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: AddressDelegate?
    var list: [ContactInfo] = []
    var showList: [ContactInfo] = []
    var nations: [NationItem]?
    var addressBookType = AddressBookType.callHistory
    var countryCode: String = "kr"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        let directionalMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        self.searchBar.directionalLayoutMargins = directionalMargins
    }
    
    func loadContactsListTask() {
        if !checkPermission() { return }
        list.removeAll()
        var myItem: ContactInfo?    // 내정보 아이템
        let items = self.getCountryContactList(countryCode: countryCode, internationalCallNumber: UserDefaultsManager.shared.loadInternationalCallNumber())
        let email = getEmail()
        list = items.filter({ item -> Bool in
            if self.addressBookType == .eloadEmailHistory {
                if isEmailItem(item: item) {
                    if let e = email {
                        if item.text == e {
                            myItem = item
                            return false
                        } else {
                            return true
                        }
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else {
                if item.callNumber?.removeDash() == UserDefaultsManager.shared.loadANI() {
                    myItem = item
                    return false
                } else {
                    if item.callNumber != nil {
                        return true
                    } else {
                        return false
                    }
                }
            }
        })
        showList = list
        if var m = myItem {
            m.isSelf = true
            showList.insert(m, at: 0)
        } else {
            switch self.addressBookType {
            case .rechargeHistory, .callHistory:
                let ani = ContactInfo(countryCode: "kr", countryNumber: "82", interNumber: "", callNumber: UserDefaultsManager.shared.loadANI(), name: "", type: "num", text: "", date: nil, isSelf: true)
                showList.insert(ani, at: 0)
            case .eloadEmailHistory:
                // 구글 로그인 으로 들어온경우
                if myItem == nil && email != nil {
                    let ani = ContactInfo(countryCode: "kr", countryNumber: "82", interNumber: "", callNumber: UserDefaultsManager.shared.loadANI(), name: "", type: "email", text: email, date: nil, isSelf: true)
                    showList.insert(ani, at: 0)
                }
            default:
                break
            }
        }
        
        self.hideLoadingWindow()
        
        self.tableView.reloadData()
    }
    
    private func getEmail() -> String? {
        let email = Utils.getSnsEmail()
        
        if email == "" {
            return nil
        } else {
            return email
        }
    }
    
    private func isEmailItem(item: ContactInfo) -> Bool {
        return item.type == ACType.email && !(item.text?.isEmpty ?? true)
    }
    
    private func checkPermission() -> Bool {
        return true
    }
}

extension CallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactListCell
        
        let item = showList[indexPath.row]
        
        if self.addressBookType == .eloadEmailHistory {
            cell.ivNation.image = UIImage(named: "ic_email")
            cell.lblName.text = item.name
            cell.lblNumber.text = item.text
        } else {
            if let code = item.countryCode, let image = UIImage(named: "flag_\(code)") {
                cell.ivNation.image = image
            }
            cell.lblName.text = item.name
            if let cCode = item.countryNumber, !cCode.isEmpty && cCode != "82" {
                cell.lblNumber.text = "+\(cCode)-\(StringUtils.telFormat(item.callNumber ?? ""))"
            } else {
                cell.lblNumber.text = StringUtils.telFormat(item.callNumber ?? "")
            }
        }
        
        if item.isSelf {
            cell.ivNation.image = UIImage(named: "ic_id")
            cell.lblName.text = Localized.com_my_mobile.txt
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.select(item: showList[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension CallViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        showList = list
        tableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            showList = list
        } else {
            showList = query(searchText) ?? []
        }
        
        tableView.reloadData()
    }
    
    private func query(_ text: String) -> [ContactInfo]? {
        var result:[ContactInfo] = []
        let query:Array = text.components(separatedBy: " ")
        for item in list {
            for partQuery in query {
                if partQuery.isEmpty {
                    continue
                }
                
                if let _ = item.name?.range(of: partQuery, options: .caseInsensitive) {
                    result.append(item)
                }
                
                if let _ = item.callNumber?.range(of: partQuery, options: .caseInsensitive) {
                    if item != result.last {
                        result.append(item)
                    }
                }
            }
        }
        
        return result
    }
    
    
    func getCountryContactList(countryCode: String, internationalCallNumber: String) -> [ContactInfo] {
        
        var result:[ContactInfo] = []
        print("💙 \(countryCode) \(internationalCallNumber)")
        nations = DBListManager.getNationList() as? [NationItem]
        let store = CNContactStore()
        var contacts = [CNContact]()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        store.requestAccess(for: .contacts, completionHandler: {
            (granted , err) in
            //권한 허용 시
            if(granted){
                do {
                    try store.enumerateContacts(with: request) {
                    (contact, stop) in
                        // 이름은 있으나 폰 번호가 없는 경우
                        if !contact.phoneNumbers.isEmpty {
                            contacts.append(contact)
                        }
                    }
                } catch {
                    print("unable to fetch contacts")
                }
            }
            // 권한 비 허용 시
            else {
                let toast = UIAlertController(title: Localized.alert_title_confirm.txt, message: Localized.pre_refuse_contacts_permission.txt, preferredStyle: .alert)
                toast.addAction(UIAlertAction(title: Localized.btn_confirm.txt, style: .default, handler: {
                    (Action) -> Void in
                    let settingsURL = NSURL(string: UIApplication.openSettingsURLString)! as URL
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }))
                self.present(toast, animated: true, completion: nil)
            }
        })
        
        for info in contacts {
            guard let phone = info.phoneNumbers[0].value.value(forKey: "digits") as? String else { return [] }
            
            let phoneNumber = phone.removeDash()
            var removedNumber = StringUtils.removePrefixInterNumber(phoneNumber)
            removedNumber = StringUtils.removeNotNumber(removedNumber)
            
            if let fakeItem:ContactInfo = PhoneUtils.findPrefixNationInfo(src: removedNumber, nations: nations ?? []) {

                // 이메일 일때는 모든 국가를 노출 시킴
                if self.addressBookType != .eloadEmailHistory {
                    if countryCode != "all" {
                        if fakeItem.countryCode != countryCode {
                            continue
                        }
                    }
                }
                
                var item = ContactInfo()
                
                let name = info.familyName + info.givenName
                item.name = name
                item.interNumber = internationalCallNumber
                item.countryCode = fakeItem.countryCode
                item.countryNumber = fakeItem.countryNumber
                item.callNumber = fakeItem.callNumber
                if self.addressBookType == .eloadEmailHistory {
                    item.type = ACType.email
                } else {
                    item.type = ACType.num
                }
                
                // 이메일 정보 추가
                for i in info.emailAddresses {
                    print("🔴 \(i.value as String)")
                    item.text = i.value as String
                }
                
                // 전화번호만 있다면 전화번호를 이름으로
                if !(item.callNumber?.isEmpty ?? true) {
                    if item.name?.isEmpty ?? true {
                        item.name = item.callNumber
                    }
                }
                
                // 중복 방지
                var already = false
                for saved in result {
                    if saved == item {
                        already = true
                        break
                    }
                }
                
                if !already {
                    result.append(item)
                }
            }
        }
        
        return result
    }
}
