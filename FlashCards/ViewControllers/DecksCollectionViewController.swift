//
//  DecksCollectionViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 15/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit


class DecksCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var assembler: Assembler!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    var cdDeckDataSource: CDDecksDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cdDeckDataSource = CDDecksDataSource(context: assembler.databaseController.viewContext, collectionView: collectionView!)
        try! cdDeckDataSource.start()
        collectionView?.dataSource = self.cdDeckDataSource
        collectionView?.register(DeckCell.self, forCellWithReuseIdentifier: DeckCell.reuseIdentifier)
        collectionView?.backgroundColor = UIColor.white
        
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
        label.text = "☹️ \n No Decks Here"
        self.collectionView?.backgroundView = label
        navigationController?.navigationBar.tintColor = UIColor.white
        updateBackgound()
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
    
    @objc func itemLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        if longPressRecognizer.state == UIGestureRecognizerState.began {
            if let index = collectionView?.indexPathForItem(at: longPressRecognizer.location(in: self.collectionView)) {
                let alert = UIAlertController(title: "Deck Options", message: "Options for selected deck", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.cdDeckDataSource.object(at: index).delete(context: self.assembler.databaseController.viewContext)
                    self.assembler.databaseController.saveContext()
                    self.updateBackgound()
                }))
                alert.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { _ in self.performSegue(withIdentifier: "editDeck", sender: index.row) }))
                alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { (action) in
                    let url = self.assembler.documentController.createDeckFile(deck: self.cdDeckDataSource.object(at: index).deck)
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
                newDeckViewController.assembler = self.assembler
            }
        } else if let index = sender as? Int {
            if let editNavigationController = segue.destination as? UINavigationController,
               let editDeckViewController = editNavigationController.viewControllers.first as? EditDeckViewController {
                editDeckViewController.assembler = self.assembler
                editDeckViewController.cdDeck = self.cdDeckDataSource.object(at: IndexPath(item: index, section: 0))
            }
        }
    }
    
    @IBAction func unwindToDecksCollectionViewController(segue: UIStoryboardSegue) { }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DeckCell
        performSegue(withIdentifier: "deckSelected", sender: cell)
    }
    
}
