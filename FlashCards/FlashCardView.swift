//
//  FlashCardView.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class XIBView: UIView {
    
    var xibView: UIView!
    
    func xibName() -> String {
        return ""
    }
    
    func xibSetup() {
        xibView = loadViewFromNib()
        xibView.frame = bounds
        xibView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(xibView)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: xibName(), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
}

@IBDesignable class FlashCardView: XIBView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageTextView: UITextView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var flipButton: UIButton!
    var flipped: Bool = false
    
    override func xibName() -> String {
        return "FlashCardView"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
        xibView.backgroundColor = UIColor.clear
        xibView.layer.shadowColor = UIColor.black.cgColor
        xibView.layer.shadowOffset = CGSize(width: 0, height: 3)
        xibView.layer.shadowOpacity = 0.5
        xibView.layer.shadowRadius = 4.0
        xibView.layer.shadowPath = UIBezierPath(roundedRect: xibView.bounds, cornerRadius: 10).cgPath
        xibView.layer.shouldRasterize = true
        xibView.layer.rasterizationScale = UIScreen.main.scale
        
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1.0
        contentView.layer.masksToBounds = true
        
        flipButton.layer.shadowColor = UIColor.black.cgColor
        flipButton.layer.shadowOffset = CGSize(width: 0, height: -2)
        flipButton.layer.shadowOpacity = 0.4
        flipButton.layer.shadowRadius = 2.0
    }
    
    var flashCard: FlashCard! {
        didSet {
            updateGUI()
        }
    }
    
    func updateGUI() {
        titleLabel.text = self.flashCard.title
        messageTextView.text = flipped ? flashCard.answer : flashCard.question
        let title = flipped ? "Show Question" :  "Show Answer"
        self.flipButton.setTitle(title, for: UIControlState.normal)
    }
    
    @IBAction func flipCard(sender: UIButton! = nil) {
        let options: UIViewAnimationOptions = [.transitionFlipFromRight]
        flipped = !flipped
        UIView.transition(with: self, duration: 0.4, options: options, animations: {
            self.updateGUI()
        }, completion: nil)
    }

}
