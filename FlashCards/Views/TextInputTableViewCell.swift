//
//  TextInputTableViewCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

class TextInputTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "TextInputTableViewCell"
    @IBOutlet weak var textInput: UITextField!
}
