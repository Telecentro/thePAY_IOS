//
//  LangViewController.swift
//  thepay
//
//  Created by xeozin on 2020/06/27.
//  Copyright © 2020 DuoLabs. All rights reserved.
//

import UIKit

enum SelectLangType {
    case first      // 최초 언어선택 (가입전)
    case normal     // 일반 언어선택
}

class LanguageCell: UITableViewCell {
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblLanguage: TPLabel!
    @IBOutlet weak var btnSelect: TPButton!
    var bSelected: Bool = false
}

class LangViewController: TPBaseViewController, TPLocalizedController {
    
    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet weak var lblTitle: TPLabel!
    
    var selectLanguage: CodeLang = App.shared.codeLang
    var selectLangType: SelectLangType = .normal
    var languages:[CodeLang] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        localize()
        
        // LanguageUtils.printFont()
    }
    
    func initialize() {
        languages = [
            CodeLang.CodeLangUSA,
            CodeLang.CodeLangCHN,
            CodeLang.CodeLangPHI,
            CodeLang.CodeLangUZB,
            CodeLang.CodeLangCAM,
            CodeLang.CodeLangMMR,
            CodeLang.CodeLangMMY,
            CodeLang.CodeLangNPL,
            CodeLang.CodeLangVNM,
            CodeLang.CodeLangTHA,
            CodeLang.CodeLangIDN,
            CodeLang.CodeLangMNG,
            CodeLang.CodeLangRUS,
            CodeLang.CodeLangLKA,
            CodeLang.CodeLangBGD,
            CodeLang.CodeLangPAK,
            CodeLang.CodeLangLAO,
            CodeLang.CodeLangKOR
        ]
        
        tblLanguage.reloadData()
    }
    
    func localize() {
        switch self.selectLangType {
        case .first:
            self.setupNavigationBar(type: .languageFirst)
        case .normal:
            self.setupNavigationBar(type: .languageNormal)
        }
        
        self.title = Localized.menu_language.txt
        self.lblTitle.text = Localized.menu_language.txt
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        LanguageUtils.saveLanguage(lang: self.selectLanguage)
        
        switch self.selectLangType {
        case .first:
            SegueUtils.openMenu(target: self, link: .terms)
        case .normal:
            App.shared.intro = .lang
            self.navigationController?.backToIntro()
        }
    }
}

extension LangViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        
        let lang = self.languages[indexPath.row]
        
        cell.lblLanguage.text = lang.nationName
        let imageName = "flags_\(lang.flagCode)"
        cell.imageView?.image = UIImage(named: imageName)
        if self.languages[indexPath.row] == self.selectLanguage {
            cell.btnSelect.isSelected = true
        } else {
            cell.btnSelect.isSelected = false
        }
        
        // 미얀마 폰트 변경
//        if lang == .CodeLangMMR {
//            let fontDesc = UIFontDescriptor(name: CustomFont.MMR.fontName, size: cell.lblLanguage.font.pointSize)
//            let f = UIFont(descriptor: fontDesc, size: cell.lblLanguage.font.pointSize)
//            
//            // iOS 14.01, iPhone 6 plus (.LastReport)
//            if f.familyName == CustomFont.MMR.fontName {
//                cell.lblLanguage.font = UIFont(name: CustomFont.MMR.fontName, size: cell.lblLanguage.font.pointSize)
//            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let idx = self.languages.indexes(of: selectLanguage).first else { return }
        let lastIndexPath = IndexPath(row: idx, section: 0)
        selectLanguage = self.languages[indexPath.row]
        tableView.reloadRows(at: [indexPath, lastIndexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
