//
//  ContactDetailViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/14.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit
import SDWebImage

class ContactDetailViewController: TPBaseViewController {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
    var hiddenCloseButton = true
    var imgString: String?
    var textDate: [String]?
    var imgData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnClose.isHidden = hiddenCloseButton
        
        // xeozin 2020/09/26 SafePhotoViewController에서 보낸 이미지 데이터
        if let imgData = imgData {
            self.imgView.image = UIImage(data: imgData)
        }
        
        guard let date = textDate else { return }
        self.setupNavigationBar(type: .basic(title: "\(date[0]) / \(date[1])"))
        if let urlString = imgString {
            self.imgView.setImage(with: urlString)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        if self.isModal {
            self.dismiss(animated: false)
            
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
