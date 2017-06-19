//
//  DecksCollectionViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 15/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

class DecksCollectionViewController: UICollectionViewController {
    
    var databaseController: DatabaseController!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    var cdDecks: Array<CDDeck>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DecksCollectionViewController.itemLongPress(longPressRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        collectionView?.addGestureRecognizer(longPressGestureRecognizer)
        let label = UILabel(frame: collectionView!.bounds)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = UIColor.black
        label.text = "☹️ \n No Decks Here"
        self.collectionView?.backgroundView = label
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cdDecks = CDDeck.allDecks(using: databaseController.viewContext)
        self.collectionView?.reloadData()
        updateBackgound()
    }
    
    func updateBackgound() {
        if cdDecks.isEmpty {
            collectionView?.backgroundView?.alpha = 1
        } else {
            collectionView?.backgroundView?.alpha = 0
        }
    }
    
    func itemLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        if longPressRecognizer.state == UIGestureRecognizerState.began {
            if let index = collectionView?.indexPathForItem(at: longPressRecognizer.location(in: self.collectionView)) {
                let alert = UIAlertController(title: "Deck Options", message: "Options for selected deck", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.cdDecks[index.row].delete(context: self.databaseController.viewContext)
                    self.cdDecks.remove(at: index.row)
                    self.databaseController.saveContext()
                    self.collectionView?.deleteItems(at: [IndexPath(item: index.row, section: 0)])
                    UIView.animate(withDuration: 0.4, animations: { 
                        self.updateBackgound()
                    })
                }))
                alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { _ in self.performSegue(withIdentifier: "editDeck", sender: index.row) }))
                alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { (action) in
                    let url = DocumentController().createDeckFile(deck: self.cdDecks[index.row].deck)
                    print(self.cdDecks[index.row].deck.convertToDict())
                    let activityVc = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
                    self.present(activityVc, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                let popOverFrame = collectionView?.cellForItem(at: index)?.frame
                alert.popoverPresentationController?.sourceRect = popOverFrame!
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let deckCell = sender as? DeckCell {
            if let flashCardViewController = segue.destination as? FlashCardViewController {
                flashCardViewController.deck = deckCell.deck
            }
        } else if (sender as? UIBarButtonItem) != nil {
            if let editNavigationController = segue.destination as? UINavigationController,
               let newDeckViewController = editNavigationController.viewControllers.first as? EditDeckViewController {
                newDeckViewController.databaseController = self.databaseController
            }
        } else if let index = sender as? Int {
            if let editNavigationController = segue.destination as? UINavigationController,
               let editDeckViewController = editNavigationController.viewControllers.first as? EditDeckViewController {
                editDeckViewController.databaseController = self.databaseController
                editDeckViewController.cdDeck = self.cdDecks[index]
            }
        }
    }
    
    @IBAction func unwindToDecksCollectionViewController(segue: UIStoryboardSegue) {
        databaseController.viewContext.rollback()
    }
    
}

// MARK - UICollectionViewDataSource

extension DecksCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cdDecks.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let deckCell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCell.reuseIdentifier, for: indexPath) as! DeckCell
        deckCell.deck = cdDecks[indexPath.row].deck
        return deckCell
    }

}
