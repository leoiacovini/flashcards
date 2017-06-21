//
//  CDDeckDataSource.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 21/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CDDecksDataSource: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
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
            if let index = indexPath {
                self.collectionView.deleteItems(at: [index])
            }
        case .insert:
            if let index = newIndexPath {
                self.collectionView.insertItems(at: [index])
            }
        case .update:
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
