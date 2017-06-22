//
//  TextInputTableViewCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import SnapKit

class TextInputTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "TextInputTableViewCell"
    var textInput: UITextField! = {
        let textInput: UITextField = UITextField()
        return textInput
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(textInput)
        textInput.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
