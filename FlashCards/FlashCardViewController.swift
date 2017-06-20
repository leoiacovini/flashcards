//
//  ViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class FlashCardViewController: UIViewController {
    
    @IBOutlet weak private var counterLabel: PaddedUILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    var deck: Deck! {
        didSet {
            self.navigationItem.title = deck.name
        }
    }
    
    fileprivate var currentFlashCardIndex: Int = 0 {
        didSet {
            updateCounterLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCounterLabel()
        collectionView.register(FlashCardView.self, forCellWithReuseIdentifier: FlashCardView.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        if deck.flashCards.isEmpty {
            let label = UILabel(frame: collectionView.bounds)
            label.textAlignment = .center
            label.numberOfLines = 2
            label.text = "☹️\nThis Deck has no FlashCards"
            collectionView.backgroundView = label
        }
        counterLabel.layer.cornerRadius = 10
        counterLabel.clipsToBounds = true
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

extension FlashCardViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deck.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlashCardView.reuseIdentifier, for: indexPath) as! FlashCardView
        cell.flashCard = deck[indexPath.item]
        cell.color = UIColor(hexColor: deck.hexColor)
        return cell
    }
    
}

extension FlashCardViewController: UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let b = collectionView.bounds
        return CGSize(width: b.width - 20, height: b.height - 40)
    }
    
}
