//
//  CardGuideViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/16.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

enum CardImageType {
    case cardnum
    case valid
    case sample
}

class CardGuideViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var btnClose: TPButton!
    var cardImageType: CardImageType?
    var cardImageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        self.btnClose.setTitle(Localized.btn_confirm.txt, for: .normal)
    }
    
    func initialize() {
        switch cardImageType {
        case .cardnum:
            self.imgCard.image = UIImage(named: cardImageString ?? "")
        case .valid:
            self.imgCard.image = UIImage(named: cardImageString ?? "")
        case .sample:
            self.imgCard.image = UIImage(named: cardImageString ?? "")
            
        default: break
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
