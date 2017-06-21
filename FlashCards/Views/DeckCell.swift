//
//  DeckCell.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class DeckCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "DeckCell"
    private static let cornerRadius: CGFloat = CGFloat(5)
    
    private var nameLabel: UILabel! = {
        let nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        return nameLabel
    }()
    
    private var countLabel: PaddedUILabel! = {
        let countLabel = PaddedUILabel()
        countLabel.backgroundColor = #colorLiteral(red: 0.3379045289, green: 0.3379045289, blue: 0.3379045289, alpha: 0.4018354024)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 8
        countLabel.textAlignment = .center
        return countLabel
    }()
    
    private var mainView: UIView! = {
        let mainView = UIView()
        mainView.layer.cornerRadius = DeckCell.cornerRadius
        mainView.clipsToBounds = true
        return mainView
    }()
    
    var deck: Deck! {
        didSet {
            self.nameLabel.text = self.deck.name
            self.countLabel.text = "\(self.deck.flashCards.count) cards"
            let color = UIColor(hexColor: deck.hexColor)
            self.mainView.backgroundColor = color
            self.backgroundColor = color.darker(by: 30)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        layer.cornerRadius = DeckCell.cornerRadius
        self.addSubview(mainView)
        mainView.addSubview(nameLabel)
        mainView.addSubview(countLabel)
        mainView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-8)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.mainView.snp.top).offset(8)
            make.centerX.leading.trailing.equalToSuperview()
        }
        countLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.mainView.snp.bottom).offset(-8)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        increaseSize()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        decreaseSize()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        decreaseSize()
    }
    
    private func decreaseSize() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func increaseSize() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: nil)
    }
    
}
