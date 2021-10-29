//
//  DynamicMenu.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/29.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class DynamicSideMenu: UIView {
    @IBOutlet weak var lblTitle1: TPLabel!
    @IBOutlet weak var lblTitle2: TPLabel!
    @IBOutlet weak var lblTitle3: TPLabel!
    
    @IBOutlet weak var ivIcon1: UIImageView!
    @IBOutlet weak var ivIcon2: UIImageView!
    @IBOutlet weak var ivIcon3: UIImageView!
    
    var menu1: PreloadingResponse.toggleMenuList?
    var menu2: PreloadingResponse.toggleMenuList?
    var menu3: PreloadingResponse.toggleMenuList?
    
    func updateDisplay(menuList: [PreloadingResponse.toggleMenuList]?) {
        menu1 = menuList?[exist: 0]
        menu2 = menuList?[exist: 1]
        menu3 = menuList?[exist: 2]
        
        if let m1 = menu1, let imgName = m1.iconImg {
            lblTitle1.text = m1.title
            ivIcon1.image = UIImage(named: imgName)
        }
        
        if let m2 = menu2, let imgName = m2.iconImg {
            lblTitle2.text = m2.title
            ivIcon2.image = UIImage(named: imgName)
        }
        
        if let m3 = menu3, let imgName = m3.iconImg {
            lblTitle3.text = m3.title
            ivIcon3.image = UIImage(named: imgName)
        }
    }
}


class DynamicMainMenu: UIView {
    @IBOutlet weak var lblTitle1: TPLabel!
    @IBOutlet weak var lblTitle2: TPLabel!
    @IBOutlet weak var lblTitle3: TPLabel!
    
    @IBOutlet weak var ivIcon1: UIImageView!
    @IBOutlet weak var ivIcon2: UIImageView!
    @IBOutlet weak var ivIcon3: UIImageView!
    
    var menu1: PreloadingResponse.hotKeyList?
    var menu2: PreloadingResponse.hotKeyList?
    var menu3: PreloadingResponse.hotKeyList?
    
    func updateDisplay(menuList: [PreloadingResponse.hotKeyList]?) {
        menu1 = menuList?[exist: 0]
        menu2 = menuList?[exist: 1]
        menu3 = menuList?[exist: 2]
        
        if let m1 = menu1, let imgName = m1.iconImg {
            lblTitle1.text = m1.title
            ivIcon1.image = UIImage(named: imgName)
        }
        
        if let m2 = menu2, let imgName = m2.iconImg {
            lblTitle2.text = m2.title
            ivIcon2.image = UIImage(named: imgName)
        }
        
        if let m3 = menu3, let imgName = m3.iconImg {
            lblTitle3.text = m3.title
            ivIcon3.image = UIImage(named: imgName)
        }
    }
}

