//
//  ColorPickerTableViewCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import SnapKit

class ColorPickerTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ColorPickerTableViewCell"
    
    var titleLabel: UILabel! = {
       let label = UILabel()
        label.text = "Color"
        return label
    }()
    
    var colorPickerView: ColorPickerView! = ColorPickerView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(titleLabel)
        self.addSubview(colorPickerView)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(8)
            make.bottom.top.equalToSuperview()
        }
        colorPickerView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(8)
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
