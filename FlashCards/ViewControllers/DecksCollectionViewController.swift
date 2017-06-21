//
//  DecksCollectionViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 15/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import CoreData

@objc class CDDecksDataSource: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<CDDeck>!
    var collectionView: UICollectionView!
    var context: NSManagedObjectContext
    var fetchRequest: NSFetchRequest<CDDeck>
    
    init(context: NSManagedObjectContext, collectionView: UICollectionView, fetchRequest: NSFetchRequest<CDDeck> = CDDeck.fetchRequest()) {
        self.context = context
        self.collectionView = collectionView
        self.fetchRequest = fetchRequest
        fetchRequest.fetchBatchSize = 20
    }
    
    func start() throws {
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        try self.fetchedResultsController.performFetch()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let deckCell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCell.reuseIdentifier, for: indexPath) as! DeckCell
        deckCell.deck = fetchedResultsController.fetchedObjects![indexPath.item].deck
        return deckCell
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            print("delete \(indexPath)")
            if let index = indexPath {
             self.collectionView.deleteItems(at: [index])
            }
        case .insert:
            print("insert \(newIndexPath)")
            if let index = newIndexPath {
                self.collectionView.insertItems(at: [index])
            }
        case .update:
            print("update \(indexPath)")
            if let index = indexPath {
                self.collectionView.reloadItems(at: [index])
            }
        default:
            break
        }
    }
    
    func decks(section: Int) -> Array<CDDeck> {
        return self.fetchedResultsController.sections![section].objects as! Array<CDDeck>
    }
    
    func count(section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }
    
    func isEmpty(section: Int) -> Bool {
        return self.fetchedResultsController.sections![section].numberOfObjects == 0
    }
    
    func object(at indexPath: IndexPath) -> CDDeck {
        return self.fetchedResultsController.object(at: indexPath)
    }
    
}

class DecksCollectionViewController: UICollectionViewController {
    
    var assembler: Assembler!
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    var cdDeckDataSource: CDDecksDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cdDeckDataSource = CDDecksDataSource(context: assembler.databaseController.viewContext, collectionView: collectionView!)
        try! cdDeckDataSource.start()
        collectionView?.dataSource = self.cdDeckDataSource
        print(cdDeckDataSource.count(section: 0))
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DecksCollectionViewController.itemLongPress(longPressRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.8
        collectionView?.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func setupUI() {
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
        updateBackgound()
    }
    
    func updateBackgound() {
        UIView.animate(withDuration: 0.4, animations: {
            if self.cdDeckDataSource.isEmpty(section: 0) {
                self.collectionView?.backgroundView?.alpha = 1
            } else {
                self.collectionView?.backgroundView?.alpha = 0
            }
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
    
    @IBAction func unwindToDecksCollectionViewController(segue: UIStoryboardSegue) {
//        assembler.databaseController.viewContext.rollback()
    }
    
}

extension DecksCollectionViewController: NSFetchedResultsControllerDelegate {
    
}
