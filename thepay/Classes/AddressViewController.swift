//
//  AddressViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/16.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

enum ContactType {
    case recent
    case country
    case contact
}

class CallButton: UIButton {
    var type: ContactType?
}

enum AddressBookType {
    case callHistory
    case rechargeHistory
    case eloadIdHistory
    case eloadEmailHistory
    case eloadCallHistory
    case unknown
}

protocol AddressDelegate {
    func select(item: ContactInfo)
}

class AddressViewController: TPBaseViewController {
    @IBOutlet weak var btnRecent: CallButton!
    @IBOutlet weak var btnCountry: CallButton!
    @IBOutlet weak var btnContact: CallButton!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var faceHeight: NSLayoutConstraint!
    @IBOutlet weak var viewRecent: UIView!
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var viewContact: UIView!
    @IBOutlet weak var ivFlag: UIImageView!
    
    var vc1: RecentCallViewController?
    var vc2: CountryCallViewController?
    var vc3: ContactCallViewController?
    
    var item: ((ContactInfo)->())?
    
    var currentType = ContactType.recent
    
    var selectNationCode = "kr"
    
    var addressBookType = AddressBookType.callHistory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRecent.type = .recent
        btnCountry.type = .country
        btnContact.type = .contact
        updateButton()
        updateDisplay(type: currentType)
        ivFlag.image = UIImage(named: "flag_\(selectNationCode)")
    }
    
    private func updateButton() {
        
        switch addressBookType {
        case .callHistory:
            self.btnRecent.setImage(sel: "ic_time_sel", nor: "ic_time_nor")
            self.btnContact.setImage(sel: "ic_contact_sel", nor: "ic_contact_nor")
            break
        case .eloadCallHistory, .eloadEmailHistory, .rechargeHistory:
            self.btnContact.isHidden = true
            self.ivFlag.isHidden = true
            self.btnRecent.setImage(sel: "ic_time_sel", nor: "ic_time_nor")
            self.btnCountry.setImage(sel: "ic_contact_sel", nor: "ic_contact_nor")
        case .eloadIdHistory:
            self.btnCountry.isHidden = true
            self.btnContact.isHidden = true
            self.ivFlag.isHidden = true
            self.buttonHeight.constant = 0
            self.faceHeight.constant = 20
        case .unknown:
            self.btnRecent.isHidden = true
            self.btnContact.isHidden = true
            self.ivFlag.isHidden = true
            self.buttonHeight.constant = 0
            self.faceHeight.constant = 20
        }
    }
    
    @IBAction func pressMenu(_ sender: CallButton) {
        if sender.type != currentType {
            updateDisplay(type: sender.type)
        }
    }
    
    private func updateDisplay(type: ContactType?) {
        guard let t = type else { return }
        currentType = t
        switch type {
        case .recent:
            setupNavigationBar(type: .basic(title: nil))
            btnRecent.isUserInteractionEnabled = false
            btnCountry.isUserInteractionEnabled = true
            btnContact.isUserInteractionEnabled = true
            btnRecent.isSelected = true
            btnCountry.isSelected = false
            btnContact.isSelected = false
            viewRecent.isHidden = false
            viewCountry.isHidden = true
            viewContact.isHidden = true
            vc1?.addressBookType = self.addressBookType
            vc1?.updateDisplay()
        case .country:
            setupNavigationBar(type: .basic(title: nil))
            btnRecent.isUserInteractionEnabled = true
            btnCountry.isUserInteractionEnabled = false
            btnContact.isUserInteractionEnabled = true
            btnRecent.isSelected = false
            btnCountry.isSelected = true
            btnContact.isSelected = false
            viewRecent.isHidden = true
            viewCountry.isHidden = false
            viewContact.isHidden = true
            vc2?.updateDisplay()
        case .contact:
            setupNavigationBar(type: .basic(title: nil))
            btnRecent.isUserInteractionEnabled = true
            btnCountry.isUserInteractionEnabled = true
            btnContact.isUserInteractionEnabled = false
            btnRecent.isSelected = false
            btnCountry.isSelected = false
            btnContact.isSelected = true
            viewRecent.isHidden = true
            viewCountry.isHidden = true
            viewContact.isHidden = false
            vc3?.updateDisplay()
        case .none:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecentCallViewController {
            vc.delegate = self
            vc.countryCode = self.selectNationCode
            vc1 = vc
        }
        
        if let vc = segue.destination as? CountryCallViewController {
            vc.delegate = self
            vc.countryCode = self.selectNationCode
            vc.addressBookType = self.addressBookType
            vc2 = vc
        }
        
        // Call History 전용 (국제전화)
        if let vc = segue.destination as? ContactCallViewController {
            vc.delegate = self
            vc.countryCode = "all"
            vc3 = vc
        }
    }
}

extension AddressViewController: AddressDelegate {
    func select(item: ContactInfo) {
        self.item?(item)
    }
}
