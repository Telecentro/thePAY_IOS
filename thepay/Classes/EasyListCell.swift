//
//  EasyListCell.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/14.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit


class IndexedButton: TPButton {
    var indexPath:IndexPath?
}

class EasyListCell: UITableViewCell {
    static let cellIdentifier: String = "EasyCell"
    @IBOutlet weak var lblCardName: UILabel!
    @IBOutlet weak var lblCardNum: UILabel!
    @IBOutlet weak var lblCardDate: UILabel!
    @IBOutlet weak var lblCardStatus: UILabel!
    @IBOutlet weak var ivCard: UIImageView!
}

class EasyDeleteListCell: UITableViewCell {
    static let cellIdentifier: String = "EasyDeleteCell"
    @IBOutlet weak var lblCardName: UILabel!
    @IBOutlet weak var lblCardNum: UILabel!
    @IBOutlet weak var lblCardDate: UILabel!
    
    @IBOutlet weak var btnDelete: IndexedButton!
}
