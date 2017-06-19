//
//  DeckCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

class DeckCell: UICollectionViewCell {
    static let reuseIdentifier = "DeckCell"
    
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var countLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
    
    var deck: Deck! {
        didSet {
            self.nameLabel.text = self.deck.name
            self.countLabel.text = "\(self.deck.flashCards.count) cards"
            self.backgroundColor = UIColor(hexColor: deck.hexColor)
        }
    }
}
