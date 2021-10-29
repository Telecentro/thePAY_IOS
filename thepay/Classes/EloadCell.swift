//
//  EloadCell.swift
//  thepay
//
//  Created by xeozin on 2020/08/20.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SPMenu

class EloadCollectionCategoryCell: UICollectionViewCell {
    @IBOutlet weak var btn: CheckButton!
    @IBOutlet weak var lbl: TPLabel!
}

class EloadTextCell: UITableViewCell {
    @IBOutlet weak var lblContent: UILabel!
}

class EloadNationCell: UITableViewCell {
    var menuManager:MenuManager<SubPreloadingResponse.eLoad> = MenuManager(callFirst: false, showSelectedItem: false, config: SPMenuConfig(type: .image))
    @IBOutlet weak var ivNation: UIImageView!
    @IBOutlet weak var tfContent: TPTextField!
    @IBAction func show(_ sender: UIButton) {
        menuManager.show(sender: sender)
    }
}

class EloadSpinnerCell: UITableViewCell {
    var menuManager:MenuManager<EloadRealResponse.item> = MenuManager(callFirst: false, showSelectedItem: false)
    @IBOutlet weak var tfContent: TPTextField!
    @IBAction func show(_ sender: UIButton) {
        menuManager.show(sender: sender)
    }
}

class CheckButton: TPButton {
    var index: Int = 0
}

class EloadCategoryCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
}

class EloadBoxLabelCell: UITableViewCell {
    @IBOutlet weak var tfContent: TPTextField!
}

class EloadImageCell: UITableViewCell {
    @IBOutlet weak var ivContent: UIImageView!
    
    override func prepareForReuse() {
        ivContent.image = nil
    }
}

class EloadInputCell: UITableViewCell {
    @IBOutlet weak var lblPrefix: UILabel!
    @IBOutlet weak var tfContent: TPTextField!
    @IBOutlet weak var btnHistory: TPEloadHistoryButton!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var btnContact: TPEloadContractButton!
    
    var type: ContactType?
    
    var indexPath: IndexPath?
}

class EloadPhoneCell: EloadInputCell {
//    @IBOutlet weak var lblPrefix: UILabel!
//    @IBOutlet weak var tfContent: TPTextField!
//    @IBOutlet weak var btnContact: TPEloadContractButton!
//
//    var indexPath: IndexPath?
}

class EloadGlobalPhoneCell: EloadInputCell {
//    @IBOutlet weak var lblPrefix: UILabel!
//    @IBOutlet weak var tfContent: TPTextField!
//    @IBOutlet weak var btnContact: TPEloadContractButton!
//
//    var indexPath: IndexPath?
}


class EloadEmailCell: EloadInputCell {
//    @IBOutlet weak var lblPrefix: UILabel!
//    @IBOutlet weak var tfContent: TPTextField!
//    @IBOutlet weak var btnContact: TPEloadContractButton?
//
//    var indexPath: IndexPath?
    
}
