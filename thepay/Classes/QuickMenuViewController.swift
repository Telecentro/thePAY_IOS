//
//  QuickMenuViewController.swift
//  thepay
//
//  Created by xeozin on 2020/07/15.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

class QuickMenuCell: UITableViewCell {
    @IBOutlet weak var btnQuickMenu: TPButton!
}

class QuickMenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnQuickMenu: TPButton!
    
    var didTapMenu: ((String) -> Void)?
    
    var handleFrame: ((UITableView) -> CGRect?)?
    var clickButton: ((Int) -> Void)?
    var menuData: [PreloadingResponse.hotKeyList] = App.shared.pre?.O_DATA?.hotKeyList ?? []
    let preButtonCnt = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        if let f = self.handleFrame?(self.tableView) {
            self.btnQuickMenu.frame = f
        }
    }
    
    func updateTableView() {
        self.tableView.reloadData()
    }
    
    @IBAction func pressClose(_ sender: Any?) {
//        self.view.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
//            self.view.alpha = 0
        }) { b in
            self.dismiss(animated: false) {
                self.clickButton?(0)
            }
        }
    }
    
    @IBAction func pressQuickMenu(_ sender: UIButton) {
        self.clickButton?(sender.tag)
//        self.view.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
//            self.view.alpha = 0
        }) { b in
            self.dismiss(animated: false) { [weak self] in
                guard let moveLink = self?.menuData[sender.tag].moveLink else { return }
                self?.didTapMenu?(moveLink)
            }
        }
    }
    
}

extension QuickMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData.count - preButtonCnt
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickMenuCell", for: indexPath) as! QuickMenuCell
        cell.selectionStyle = .none
        tableView.separatorStyle = .none
        cell.btnQuickMenu.tag = indexPath.row + preButtonCnt
        cell.btnQuickMenu.titleLabel?.numberOfLines = 3
        cell.btnQuickMenu.setTitle(menuData[indexPath.row + preButtonCnt].title, for: .normal)
        if let imgURL = menuData[indexPath.row + preButtonCnt].iconImg {
            cell.btnQuickMenu.setImage(UIImage(named: imgURL), for: .normal)            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.alpha = 0
//        UIView.animate(
//            withDuration: 0.5,
//            delay: 0.1 * Double(indexPath.row),
//            animations: {
//                cell.alpha = 1
//        })
//    }
//
}

