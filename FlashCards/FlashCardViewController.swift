//
//  ViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class FlashCardViewController: UIViewController {
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var flashCardScrollView: UIScrollView!
    
    var deck: Deck! {
        didSet {
            self.navigationItem.title = deck.name
        }
    }
    private var allFlashCardsViews: Array<FlashCardView> = []
    private var flashCardsViewsInitiated = false
    
    @IBAction func flipCard(sender: UIButton!) {
        allFlashCardsViews[currentFlashCardIndex].flipCard()
    }
    
    fileprivate var currentFlashCardIndex: Int = 0 {
        didSet {
            updateCounterLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCounterLabel()
        flashCardScrollView.delegate = self
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFlashCardsViewsIfNeeded()
    }
    
    private func setupFlashCardsViewsIfNeeded() {
        if !flashCardsViewsInitiated {
            allFlashCardsViews = []
            for v in flashCardScrollView.subviews { v.removeFromSuperview() }
            flashCardScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(deck.size), height: flashCardScrollView.bounds.height)
            let baseFrame = CGRect(x: 10, y: 25, width: self.view.frame.width - CGFloat(20), height: flashCardScrollView.frame.height - CGFloat(50))
            for (index, card) in deck.flashCards.enumerated() {
                let fcView = FlashCardView(frame: CGRect(x: baseFrame.origin.x + (CGFloat(index) * self.view.frame.width) , y: baseFrame.origin.y, width: baseFrame.width, height: baseFrame.height))
                fcView.flashCard = card
                flashCardScrollView.addSubview(fcView)
                allFlashCardsViews.append(fcView)
            }
            flashCardsViewsInitiated = true
        }
    }
    
    private func updateCounterLabel() {
        counterLabel.text = "\(deck.size == 0 ? 0 : currentFlashCardIndex+1)/\(deck.size)"
    }
    
}

// MARK - UIScrollViewDelegate

extension FlashCardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        currentFlashCardIndex = Int(pageNumber)
    }
}
