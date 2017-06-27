//
//  DecksCollectionViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 15/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class DecksCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    static let identifier: String = "decksCollectionViewController"
    
    var coordinator: DecksCollectionControllerDelegate!
    var assembler: Assembler!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    var cdDeckDataSource: CDDecksDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cdDeckDataSource = CDDecksDataSource(context: assembler.databaseController.viewContext, collectionView: collectionView!)
        try! cdDeckDataSource.start()
        collectionView?.dataSource = cdDeckDataSource
        collectionView?.register(DeckCell.self, forCellWithReuseIdentifier: DeckCell.reuseIdentifier)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DecksCollectionViewController.itemLongPress(longPressRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.8
        collectionView?.addGestureRecognizer(longPressGestureRecognizer)
        setupUI()
    }
    
    func setupUI() {
        let label = UILabel(frame: collectionView!.bounds)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor.black
        label.text = "☹️\nNo Decks Here"
        self.collectionView?.backgroundView = label
        collectionView?.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBackgound()
    }
    
    func updateBackgound() {
        UIView.animate(withDuration: 0.4, animations: {
            self.collectionView?.backgroundView?.alpha = self.cdDeckDataSource.isEmpty(section: 0) ? 1 : 0
        })
    }
    
    @IBAction func addNewDeck(_ sender: UIBarButtonItem) {
        coordinator.decksCollectionController(self, didEdit: nil)
    }
    
    @objc func itemLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        if longPressRecognizer.state == UIGestureRecognizerState.began {
            if let index = collectionView?.indexPathForItem(at: longPressRecognizer.location(in: self.collectionView)) {
                let cdDeck: CDDeck = self.cdDeckDataSource.object(at: index)
                let alert = UIAlertController(title: "Deck Options", message: "Options for selected deck", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.coordinator.decksCollectionController(self, didDelete: cdDeck)
                    self.updateBackgound()
                }))
                alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { _ in
                    self.coordinator.decksCollectionController(self, didEdit: cdDeck)
                }))
                alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { (action) in
                    self.coordinator.decksCollectionController(self, didShare: cdDeck)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                let popOverFrame = collectionView?.cellForItem(at: index)?.frame
                alert.popoverPresentationController?.sourceRect = popOverFrame!
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DeckCell
        self.coordinator.decksCollectionController(self, didSelect: cell.cdDeck)
    }
    
}
