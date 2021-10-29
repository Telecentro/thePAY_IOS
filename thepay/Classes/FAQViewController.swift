//
//  FAQViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/21.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit
import SafariServices

class FAQViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblSns: TPLabel!
    @IBOutlet weak var lblDesc: TPLabel!
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var cvSnsList: SNSListCollectionView!
    @IBOutlet weak var cvSnsListHeight: NSLayoutConstraint!
    
    var inboundChannels:[SubPreloadingResponse.snsList]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // TODO: FAQ화면 키보드 올리고 뒤로가면 부자연스러움..더 좋은 방법이 있으면 찾아보도록.
        let currentHeightSize: CGFloat = UIScreen.main.bounds.size.height
        let iphone8HeightSize: CGFloat = 667
        if currentHeightSize > iphone8HeightSize {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    internal func initialize() {
        requestSubPreloading(opCode: .snsList) { [weak self] (data:[Any]?) -> Void in
            self?.inboundChannels = App.shared.snsList
            
            let cnt = App.shared.snsList?.count ?? 0
            
            if cnt == 0 {
                self?.cvSnsList.isHidden = true
            } else {
                self?.cvSnsList.data = App.shared.snsList
                self?.cvSnsListHeight.constant = self?.getSnsListHeight(count: cnt) ?? 0
                self?.cvSnsList.reloadData()
            }
        }
        
        cvSnsList.moveSNSList = { item in
            guard let str = item.type, let type = SNSListCollectionViewCell.SNSType(rawValue: str) else { return }
            switch type {
            case .tell:
                guard let schemeURL = URL(string: item.url ?? "") else { return }
                UIApplication.shared.open(schemeURL, options: [:], completionHandler: nil)
            case .schema:
                guard let link = item.url else { return }
                guard let download = item.downloadUrl else { return }
                guard let schemeURL = URL(string: link) else { return }
                
                if UIApplication.shared.canOpenURL(schemeURL) {
                    UIApplication.shared.open(schemeURL, options: [:], completionHandler: nil)
                    
                } else {
                    UIApplication.shared.open(URL(string: download)!, options: [:], completionHandler: nil)
                }
            case .moveLink:
                guard let link = item.url else { return }
                SegueUtils.parseMoveLink(target: self, link: link)
            }
        }
    }
    
    private func getSnsListHeight(count: Int?) -> CGFloat {
        guard let cnt = count else { return 0 }
        let row = cnt / 2
        let add = cnt % 2
        return CGFloat((row + add) * 64) + CGFloat(row * 7)
    }
    
    internal func localize() {
        self.lblSns.text = Localized.faq_contact_sns.txt
        self.lblDesc.text = Localized.text_guide_faq_content.txt
        self.lblTitle.text = Localized.title_activity_faq.txt
    }
    
    // 페북, 카카오, 라인으로 화면 전환
    private func moveSchemes(_ snsType: Int) {
        if let item = inboundChannels?[exist: snsType] {
            guard let link = item.url else { return }
            guard let download = item.downloadUrl else { return }
            guard let schemeURL = URL(string: link) else { return }
            
            if UIApplication.shared.canOpenURL(schemeURL) {
                UIApplication.shared.open(schemeURL, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.open(URL(string: download)!, options: [:], completionHandler: nil)
            }
        }
    }
}
