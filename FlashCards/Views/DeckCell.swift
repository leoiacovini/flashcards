//
//  DeckCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

class PaddedUILabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 4)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

class DeckCell: UICollectionViewCell {
    static let reuseIdentifier = "DeckCell"
    
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var countLabel: PaddedUILabel!
    @IBOutlet weak private var mainView: UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 5
        self.mainView.layer.cornerRadius = 5
        self.countLabel.backgroundColor = #colorLiteral(red: 0.3379045289, green: 0.3379045289, blue: 0.3379045289, alpha: 0.4018354024)
        
        self.mainView.clipsToBounds = true
        self.countLabel.clipsToBounds = true
        self.countLabel.layer.cornerRadius = 8
    }
    
    var deck: Deck! {
        didSet {
            self.nameLabel.text = self.deck.name
            self.countLabel.text = "\(self.deck.flashCards.count) cards"
            let color = UIColor(hexColor: deck.hexColor)
            self.mainView.backgroundColor = color
            self.backgroundColor = color.darker(by: 30)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: nil)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }

}
