//
//  FlashCardView.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import SnapKit

class FlashCardView: UICollectionViewCell {
    static let reuseIdentifier: String = "flashCardCell"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    var messageTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    var mainView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var flipButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    var flipped: Bool = false
    var flashCard: FlashCard! {
        didSet {
            updateGUI()
        }
    }
    
    var color: UIColor! {
        didSet {
            self.mainView.backgroundColor = color
            self.flipButton.backgroundColor = color.lighter(by: 20)
            self.mainView.layer.borderColor = color.darker(by: 20)!.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        flipButton.addTarget(self, action: #selector(flipCard(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(mainView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(messageTextView)
        mainView.addSubview(flipButton)
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4.0
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        mainView.layer.cornerRadius = 10
        mainView.layer.borderWidth = 1.0
        mainView.layer.masksToBounds = true
        flipButton.layer.shadowColor = UIColor.black.cgColor
        flipButton.layer.shadowOffset = CGSize(width: 0, height: -2)
        flipButton.layer.shadowOpacity = 0.4
        flipButton.layer.shadowRadius = 2.0
    }
    
    private func setupConstraints() {
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        flipButton.snp.makeConstraints { (make) in
            make.bottom.trailing.leading.equalToSuperview()
            make.height.equalTo(48)
        }
        messageTextView.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalTo(flipButton.snp.top).offset(8)
        }
    }
    
    private func updateGUI() {
        titleLabel.text = self.flashCard.title
        updateText()
        let title = flipped ? "Show Question" :  "Show Answer"
        self.flipButton.setTitle(title, for: UIControlState.normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGUI()
    }
    
    private func updateText() {
        let attributtedString: NSMutableAttributedString!
        let imageAttachment = NSTextAttachment()
        if flipped {
            attributtedString = NSMutableAttributedString(string: flashCard.answer + "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)])
            if let image = flashCard.answerImage {
                imageAttachment.image = UIImage(data: image)
                let oldWidth = imageAttachment.image?.size.width
                let scaleFactor = oldWidth! / (messageTextView.frame.size.width - 10)
                imageAttachment.image = UIImage(cgImage: imageAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
                attributtedString.append(NSAttributedString(attachment: imageAttachment))
            }
        } else {
            attributtedString = NSMutableAttributedString(string: flashCard.question + "\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)])
            if let image = flashCard.questionImage {
                imageAttachment.image = UIImage(data: image)
                let oldWidth = imageAttachment.image?.size.width
                let scaleFactor = oldWidth! / (messageTextView.frame.size.width - 10)
                imageAttachment.image = UIImage(cgImage: imageAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
                attributtedString.append(NSAttributedString(attachment: imageAttachment))
            }
        }
        messageTextView.attributedText = attributtedString
    }
    
    @objc func flipCard(sender: UIButton!) {
        let options: UIViewAnimationOptions = [.transitionFlipFromRight]
        flipped = !flipped
        UIView.transition(with: self, duration: 0.4, options: options, animations: {
            self.updateGUI()
        }, completion: nil)
    }

}
