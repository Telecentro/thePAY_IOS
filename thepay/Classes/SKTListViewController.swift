//
//  SKTListViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/05.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class SKTListCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
}

class SKTListViewController: TPBaseViewController, TPLocalizedController {
    @IBOutlet weak var tableView: UITableView!
    var sktLTEData:[SubPreloadingResponse.coupon]? = []
    var delegate: SKTDataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.setContentOffset(CGPoint(x:0, y:0), animated: false)
    }
    
    func initialize() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func localize() {}
}

extension SKTListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sktData = sktLTEData else { return 0}
        return sktData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SKTListCell", for: indexPath) as! SKTListCell
        if let data = sktLTEData {
            cell.lblTitle.text = data[indexPath.row].mvnoName
            cell.lblPrice.text = "￦ \(String(data[indexPath.row].price ?? 0).currency)"
            cell.lblDesc.attributedText = data[indexPath.row].Info1?.convertHtml(fontSize: 12)
            if let urlString = data[indexPath.row].img1 {
                cell.imgView.setImage(with: urlString)
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let data = sktLTEData {
            delegate?.selectProduct(data: data[indexPath.row])
        }
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
}
