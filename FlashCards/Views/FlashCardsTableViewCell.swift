//
//  FlashCardsTableViewCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

class FlashCardTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "FlashCardTableViewCell"
    @IBOutlet weak var titleLabel: UILabel!
    var cdFlashCard: CDFlashCard! {
        didSet {
            self.titleLabel.text = cdFlashCard.title
        }
    }
    
}
