//
//  TPCardView.swift
//  thepay
//
//  Created by xeozin on 2020/09/11.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

import UIKit

class TPCardView: UIStackView {
    @IBOutlet weak var svpCardType1: UIStackView!
    @IBOutlet weak var svpCardType2: UIStackView!
    
    @IBOutlet weak var tfCard1: TPTextField!
    @IBOutlet weak var tfCard2: TPTextField!
    @IBOutlet weak var tfCard3: TPTextField!
    @IBOutlet weak var tfCard4: TPTextField!
    @IBOutlet weak var tfCardShort1: TPTextField!
    @IBOutlet weak var tfCardShort2: TPTextField!
    @IBOutlet weak var tfCardShort3: TPTextField!
    @IBOutlet weak var ivCard: UIImageView?
    var cm = CardManager.shared
    
    func getCardNum() -> String {
        
        if cm.isShorterCard() {
            guard let t1 = self.tfCardShort1.text else { return "" }
            guard let t2 = self.tfCardShort2.text else { return "" }
            guard let t3 = self.tfCardShort3.text else { return "" }
            return "\(t1)\(t2)\(t3)"
        } else {
            guard let t1 = self.tfCard1.text else { return "" }
            guard let t2 = self.tfCard2.text else { return "" }
            guard let t3 = self.tfCard3.text else { return "" }
            guard let t4 = self.tfCard4.text else { return "" }
            return "\(t1)\(t2)\(t3)\(t4)"
        }
    }
    
    
    func isValidCardNumber() -> Bool {
        if cm.isShorterCard() {
            if self.tfCardShort1.text.isNilOrEmpty ||
                self.tfCardShort2.text.isNilOrEmpty ||
                self.tfCardShort3.text.isNilOrEmpty {
                return false
            }
        } else {
            if self.tfCard1.text.isNilOrEmpty ||
                self.tfCard2.text.isNilOrEmpty ||
                self.tfCard3.text.isNilOrEmpty ||
                self.tfCard4.text.isNilOrEmpty {
                return false
            }
        }
        
        return true
    }
    
    
    
    private func checkCardNumNilCheck() -> Bool {
        if cm.isShorterCard() {
            if self.tfCardShort1.text.isNilOrEmpty {
                return false
            }
        } else {
            if self.tfCard1.text.isNilOrEmpty {
                return false
            }
        }
        
        return true
    }
    
    
    // 6578 CARD_TYPE_DISCOVER (4)
    // 34 CARD_TYPE_AMERICAN_EXPRESS_SHORTER (3)
    // 6999 CARD_TYPE_DISCOVER_SHORT (5)
    // 35 CARD_TYPE_JCB_SHORT (6)
    func cardNumberChange() {
        if checkCardNumNilCheck() {
            var cardNum = ""
            let cardShort1 = self.tfCardShort1.text ?? ""
            let cardShort2 = self.tfCardShort2.text ?? ""
            let cardShort3 = self.tfCardShort3.text ?? ""
            
            let card1 = self.tfCard1.text ?? ""
            let card2 = self.tfCard2.text ?? ""
            let card3 = self.tfCard3.text ?? ""
            let card4 = self.tfCard4.text ?? ""
            if cm.isShorterCard() {
                cardNum = "\(cardShort1)\(cardShort2)\(cardShort3)"
            } else {
                cardNum = "\(card1)\(card2)\(card3)\(card4)"
            }
            
            // FIXME: Swift 로 변경 필요
            let data = StringUtils.cardFormatPattern(cardNum)
            guard let ctype = CardType(rawValue: Int(data.card_type.rawValue)) else { return }
            
            switch ctype {
            case .CARD_TYPE_AMERICAN_EXPRESS_SHORTER:
                // 아메리칸 익스프레스 카드 (15자리 입력가능)
                // xxxx-xxxxxx-xxxxx
                if cm.cardType != ctype {
                    self.svpCardType1.isHidden = true
                    self.svpCardType2.isHidden = false
                    self.tfCardShort1.becomeFirstResponder()
                    
                    self.tfCard2.text = ""
                    self.tfCard3.text = ""
                    self.tfCard4.text = ""
                    self.tfCardShort2.text = ""
                    self.tfCardShort3.text = ""
                    self.tfCardShort3.placeholder = "00000"
                }
                
                if cm.cardType != .CARD_TYPE_AMERICAN_EXPRESS_SHORTER && !self.tfCard1.text.isNilOrEmpty {
                    self.tfCardShort1.text = self.tfCard1.text
                    self.tfCard1.text = ""
                }
            case .CARD_TYPE_DINERS_CLUB_SHORT:
                // 다이너스 클럽 카드 (14자리 입력가능)
                // xxxx-xxxxxx-xxxx
                if cm.cardType != ctype {
                    self.svpCardType1.isHidden = true
                    self.svpCardType2.isHidden = false
                    self.tfCardShort1.becomeFirstResponder()
                    
                    self.tfCard2.text = ""
                    self.tfCard3.text = ""
                    self.tfCard4.text = ""
                    self.tfCardShort2.text = ""
                    self.tfCardShort3.text = ""
                    self.tfCardShort3.placeholder = "0000"
                }
                
                if cm.cardType != ctype && !self.tfCard1.text.isNilOrEmpty {
                    self.tfCardShort1.text = self.tfCard1.text
                    self.tfCard1.text = ""
                }
            case .CARD_TYPE_JCB_SHORT:
                // JCB 카드 (최소 15자리 ~ 최대 16자리 입력가능)
                // xxxx-xxxx-xxxx-xxx
                // xxxx-xxxx-xxxx-xxxx
                if cm.cardType != ctype && cm.cardType != .CARD_TYPE_NULL {
                    self.svpCardType1.isHidden = false
                    self.svpCardType2.isHidden = true
                    self.tfCard1.becomeFirstResponder()
                    
                    self.tfCard2.text = ""
                    self.tfCard3.text = ""
                    self.tfCard4.text = ""
                    self.tfCardShort2.text = ""
                    self.tfCardShort3.text = ""
                }
                
                if cm.cardType != ctype && !self.tfCardShort1.text.isNilOrEmpty {
                    self.tfCard1.text = self.tfCardShort1.text
                    self.tfCardShort1.text = ""
                }
            default:
                // 기타 카드 (16자리 입력가능)
                if cm.cardType != ctype && cm.cardType != .CARD_TYPE_NULL {
                    self.svpCardType1.isHidden = false
                    self.svpCardType2.isHidden = true
                    self.tfCard1.becomeFirstResponder()
                    
                    self.tfCard2.text = ""
                    self.tfCard3.text = ""
                    self.tfCard4.text = ""
                    self.tfCardShort2.text = ""
                    self.tfCardShort3.text = ""
                }
                
                if cm.cardType != ctype && !self.tfCardShort1.text.isNilOrEmpty {
                    self.tfCard1.text = self.tfCardShort1.text
                    self.tfCardShort1.text = ""
                }
            }
            
            // 새로운 카드타입 변경
            cm.cardType = ctype
            
            guard let ic = ivCard else { return }
            
            if let _ = data.name as String? {
                if let imgPath = data.img_path as String? {
                    ic.image = UIImage(named: imgPath)
                } else {
                    ic.image = UIImage(named: "ic_card")
                }
            } else {
                ic.image = UIImage(named: "ic_card")
            }
        }
    }

}
