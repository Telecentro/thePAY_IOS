//
//  CounselorBalloonCell.swift
//  thepay
//
//  Created by xeozin on 2020/09/11.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class CounselorBalloonCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblCounselorText: TPLabel!
    @IBOutlet weak var lblCounselorDate: TPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgProfile.layer.cornerRadius = self.imgProfile.bounds.size.height / 2
        if let urlString = UserDefaultsManager.shared.loadContactProfile() {
            self.imgProfile.setImage(with: urlString)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
