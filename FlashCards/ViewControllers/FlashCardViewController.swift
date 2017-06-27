//
//  ViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class FlashCardViewController: UIViewController {
    static let identifier: String = "flashCardViewController"
    
    @IBOutlet weak private var counterLabel: PaddedUILabel!
    @IBOutlet weak private var collectionView: UICollectionView!
    var coordinator: FlashCardViewControllerDelegate!
    
    var cdDeck: CDDeck! {
        didSet {
            self.navigationItem.title = cdDeck.name
        }
    }
    
    private var currentFlashCardIndex: Int = 0 {
        didSet {
            updateCounterLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(FlashCardView.self, forCellWithReuseIdentifier: FlashCardView.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updateCounterLabel()
    }
    
    private func setupUI() {
        updateCounterLabel()
        collectionView.backgroundColor = UIColor.clear
        if cdDeck.flashCards.isEmpty {
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
        counterLabel.text = "\(cdDeck.size == 0 ? 0 : currentFlashCardIndex+1)/\(cdDeck.size)"
    }
    
    @IBAction func editDeck(sender: UIBarButtonItem!) {
        coordinator.flashCardViewController(self, edit: cdDeck)
    }
    
    @IBAction func shareDeck(sender: UIBarButtonItem!) {
        coordinator.flashCardViewController(self, share: cdDeck)
    }
    
}

// MARK - UIScrollViewDelegate

extension FlashCardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = (scrollView.contentOffset.x + 10) / scrollView.frame.size.width
        currentFlashCardIndex = Int(pageNumber)
    }
}

extension FlashCardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cdDeck.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlashCardView.reuseIdentifier, for: indexPath) as! FlashCardView
        cell.flashCard = cdDeck[indexPath.item].flashCard
        cell.color = UIColor(hexColor: cdDeck.hexColor)
        return cell
    }
    
}

extension FlashCardViewController: UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let b = collectionView.bounds
        return CGSize(width: b.width - 20, height: b.height - 40)
    }
    
}
