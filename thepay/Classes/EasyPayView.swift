//
//  EasyPayView.swift
//  thepay
//
//  Created by 홍서진 on 2021/06/22.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasyPayView: UIStackView {
    @IBOutlet weak var viewGuideRegister: UIView!
    @IBOutlet weak var viewGuidePayment: UIView!
    @IBOutlet weak var viewCarousel: UIView!
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var viewSafeButton: UIView!
    @IBOutlet weak var viewEasyButton: UIView!
    
    
    @IBOutlet weak var lblEasyPayReg: TPLabel!
    @IBOutlet weak var lblEasyPayPwd: TPLabel!
    @IBOutlet weak var lblTitleSecurePaymentAdd: TPLabel!
    @IBOutlet weak var lblContentSecurePaymentAdd: TPLabel!
    @IBOutlet weak var lblTitleEasyPaymentAdd: TPLabel!
    @IBOutlet weak var lblContentEasyPaymentAdd: TPLabel!
    
    
    @IBOutlet weak var collectionView: ScalingCarouselView!
    var easyPayData: [ListEasyResponse.easyPayList]?
    var lastOffsetX:CGFloat = 0
    
    var lastSelectedIndex:IndexPath = IndexPath(row: 0, section: 0)
    var ableToSavePosition = true
    
    var vm:CardViewModel?
    
    func updateEazyPaymentView(type: EasyPaymentType) {
        switch type {
        case .select:
            viewCarousel.isHidden = false
            viewButtons.isHidden = true
            viewGuideRegister.isHidden = true
            viewGuidePayment.isHidden = false
        case .easyAndSafe:
            viewCarousel.isHidden = true
            viewButtons.isHidden = false
            viewEasyButton.isHidden = false
            viewSafeButton.isHidden = false
            viewGuideRegister.isHidden = false
            viewGuidePayment.isHidden = true
        case .easyOnly:
            viewCarousel.isHidden = true
            viewButtons.isHidden = false
            viewEasyButton.isHidden = false
            viewSafeButton.isHidden = true
            viewGuideRegister.isHidden = false
            viewGuidePayment.isHidden = true
        }
    }
    
    func localize() {
        lblEasyPayReg.text = Localized.text_guide_easy_payment_reg.txt
        lblEasyPayPwd.text = Localized.text_guide_after_checking_reg_info_please_enter_pwd.txt
        lblTitleSecurePaymentAdd.text = Localized.text_title_secure_payment_add.txt
        lblContentSecurePaymentAdd.text = Localized.text_content_secure_payment_add.txt
        lblTitleEasyPaymentAdd.text = Localized.text_title_easy_payment_add.txt
        lblContentEasyPaymentAdd.text = Localized.text_content_easy_payment_add.txt
    }
    
    func updateEasyPayData(data: [ListEasyResponse.easyPayList]?) {
        easyPayData = data
        collectionView.reloadData()
    }
    
    func getSelectData() -> ListEasyResponse.easyPayList? {
        return easyPayData?[self.lastSelectedIndex.row]
    }
    
    func resetPosition() {
        collectionView.setContentOffset(CGPoint(x: lastOffsetX, y: 0), animated: true)
    }
}


typealias CarouselDatasource = EasyPayView
extension CarouselDatasource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.easyPayData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        
        if let scalingCell = cell as? EasyPayCollectionCell {
            if let d = self.easyPayData?[indexPath.row] {
                scalingCell.lblCardNum.text = d.cardnum
                scalingCell.lblCreatedDt.text = d.cardRegDt
            }
            scalingCell.ivBackground.image = UIImage(named: "img_easy_pay_big_card\(indexPath.row + 1)")
            scalingCell.scaleMinimum = 1
            scalingCell.scaleDivisor = 20
        }

        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
        
        return cell
    }
}

typealias CarouselDelegate = EasyPayView
extension CarouselDelegate: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ableToSavePosition {
            lastOffsetX = scrollView.contentOffset.x
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
            if let ip = collectionView.indexPathForItem(at: center) {
                lastSelectedIndex = ip
            }
        } else {
            collectionView.setContentOffset(CGPoint(x: lastOffsetX, y: 0), animated: true)
        }
    }
}

private typealias ScalingCarouselFlowDelegate = CardViewController
extension CardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
