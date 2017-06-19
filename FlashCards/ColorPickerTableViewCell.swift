//
//  ColorPickerTableViewCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class ColorPickerTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ColorPickerTableViewCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorPickerView: ColorPickerView!

}
