//
//  TextViewController.swift
//  thepay
//
//  Created by xeozin on 2020/09/16.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TextViewController: TPBaseViewController {
    @IBOutlet weak var lblContents: TPLabel!
    var titleString: String?
    var contents: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar(type: .basic(title: titleString ?? ""))
        self.lblContents.numberOfLines = 0
        if let con = self.contents {
            self.lblContents.attributedText = con.convertHtml(fontSize: 14)
        }
    }
}
