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

class PaddedUILabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 4)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

class DeckCell: UICollectionViewCell {
    static let reuseIdentifier = "DeckCell"
    
    private var nameLabel: UILabel!
    private var countLabel: PaddedUILabel!
    private var mainView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        nameLabel = UILabel()
        countLabel = PaddedUILabel()
        mainView = UIView()
        
        layer.cornerRadius = 5
        mainView.layer.cornerRadius = 5
        mainView.clipsToBounds = true
        
        countLabel.backgroundColor = #colorLiteral(red: 0.3379045289, green: 0.3379045289, blue: 0.3379045289, alpha: 0.4018354024)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.clipsToBounds = true
        countLabel.layer.cornerRadius = 8
        countLabel.textAlignment = .center
        
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        
        addSubview(mainView)
        mainView.addSubview(nameLabel)
        mainView.addSubview(countLabel)
        
        mainView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.mainView.snp.top).offset(8)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.mainView.snp.bottom).offset(-8)
            make.centerX.equalToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
