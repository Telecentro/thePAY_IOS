//
//  MyBalloonCell.swift
//  thepay
//
//  Created by xeozin on 2020/09/10.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class MyBalloonCell: UITableViewCell {
    @IBOutlet weak var lblMyText: TPLabel!
    @IBOutlet weak var lblMyDate: TPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
