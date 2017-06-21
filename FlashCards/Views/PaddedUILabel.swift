//
//  PaddedLabel.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 21/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class PaddedUILabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 4)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
