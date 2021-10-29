//
//  ContactListCell.swift
//  thepay
//
//  Created by xeozin on 2020/09/18.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class ContactHeaderCell: UITableViewCell {
    @IBOutlet weak var lblDate: TPLabel!
}

class ContactListCell: UITableViewCell {
    
    @IBOutlet weak var ivNation: UIImageView!
    @IBOutlet weak var lblName: TPLabel!
    @IBOutlet weak var lblNumber: TPLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
