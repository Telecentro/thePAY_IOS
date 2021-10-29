//
//  EasySuccessViewController.swift
//  thepay
//
//  Created by 홍서진 on 2021/07/13.
//  Copyright © 2021 Duo Labs. All rights reserved.
//

import UIKit

class EasySuccessViewController : TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var lblTitle: TPLabel!
    @IBOutlet weak var lblCardNum: UILabel!
    @IBOutlet weak var btnOK: TPButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        initialize()
    }
    
    func localize() {
        lblTitle.text = Localized.text_title_easy_payment_added.txt
        btnOK.setTitle(Localized.activity_secure_number_keypad_ok.txt, for: .normal)
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let backBtn = UIBarButtonItem(customView: btn)
        backBtn.title = ""
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    func initialize() {
        fillCardNum()
    }
    
    private func fillCardNum() {
        if let cardNum = EasyRegInfo.shared.cardNum {
            lblCardNum.text = maskCardNum(cardNum)
        } else {
            if let step3 = EasyRegInfo.shared.step3, let number = step3.CARD_NUMBER {
                guard let data = Data(base64Encoded: number) else { return }
                guard let str = String(data: AES256.decriptionAES256NotEncDate(data: data), encoding: .utf8) else { return }
                lblCardNum.text = maskCardNum(str)
            }
        }
    }
    
    private func maskCardNum(_ num: String) -> String {
        if num.count == 16 {
            return maskBasicCardNum(num: num)
        } else {
            return maskShorterCardNum(num: num)
        }
    }
    
    private func maskBasicCardNum(num: String?) -> String {
        return [
            String(num?[0...3] ?? ""),
            String(num?[4...7] ?? ""),
            "****",
            String(num?[12...] ?? "")
        ].joined(separator: "-")
    }
    
    private func maskShorterCardNum(num: String?) -> String {
        return [
            String(num?[0...3] ?? ""),
            "*****",
            String(num?[10...] ?? "")
        ].joined(separator: "-")
    }
    
    @IBAction func pressOK(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
