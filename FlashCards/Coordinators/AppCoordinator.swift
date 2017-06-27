//
//  AppCoordinator.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 27/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

protocol DecksCollectionControllerDelegate: Coordinator {
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didEdit cdDeck: CDDeck?)
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didShare cdDeck: CDDeck)
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didSelect cdDeck: CDDeck)
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didDelete cdDeck: CDDeck)
}

protocol FlashCardViewControllerDelegate {
    func flashCardViewController(_ flashCardViewController: FlashCardViewController, edit cdDeck: CDDeck)
    func flashCardViewController(_ flashCardViewController: FlashCardViewController, share cdDeck: CDDeck)
}

protocol EditCoordinatorDelegate: Coordinator {
    func didEndEditing(editorCoordinator: EditorCoordinator)
}

class AppCoordinator: Coordinator {
    
    var navigationController: UINavigationController!
    var childCoordinators: Array<Coordinator> = Array()
    var assembler: Assembler
    
    init(rootViewController: UINavigationController, assembler: Assembler) {
        self.navigationController = rootViewController
        self.assembler = assembler
        navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.3970538261, green: 0.638962799, blue: 1, alpha: 1)
        navigationController.navigationBar.tintColor = UIColor.white
    }
    
    func start() {
        showDecksCollectionView()
    }
    
    func showDecksCollectionView() {
        let decksCollectionViewController = loadFromStoryboard(identifier: DecksCollectionViewController.identifier) as! DecksCollectionViewController
        decksCollectionViewController.coordinator = self
        decksCollectionViewController.assembler = self.assembler
        navigationController.pushViewController(decksCollectionViewController, animated: true)
    }
    
    func showEditorCoordinator(cdDeck: CDDeck?) {
        let editorCoordinator = EditorCoordinator(cdDeck: cdDeck, assembler: assembler)
        editorCoordinator.parentCoordinator = self
        addChildCoordinator(coordinator: editorCoordinator)
        editorCoordinator.start()
        presentCoordinator(editorCoordinator)
    }
    
    func showShareDeckActivityViewController(on viewController: UIViewController, deck: Deck) {
        let url = self.assembler.documentController.createDeckFile(deck: deck)
        let activityVc = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        viewController.present(activityVc, animated: true, completion: nil)
    }
    
    func showFlashCardsViewController(cdDeck: CDDeck) {
        let flashCardViewController = loadFromStoryboard(identifier: FlashCardViewController.identifier) as! FlashCardViewController
        flashCardViewController.cdDeck = cdDeck
        flashCardViewController.coordinator = self
        self.navigationController.pushViewController(flashCardViewController, animated: true)
    }
    
}

extension AppCoordinator: DecksCollectionControllerDelegate {
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didEdit cdDeck: CDDeck?) {
        showEditorCoordinator(cdDeck: cdDeck)
    }
    
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didShare cdDeck: CDDeck) {
        showShareDeckActivityViewController(on: decksCollectionController, deck: cdDeck.deck)
    }
    
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didSelect cdDeck: CDDeck) {
        showFlashCardsViewController(cdDeck: cdDeck)
    }
    
    func decksCollectionController(_ decksCollectionController: DecksCollectionViewController, didDelete cdDeck: CDDeck) {
        cdDeck.delete(context: self.assembler.databaseController.viewContext)
        self.assembler.databaseController.saveContext()
    }
}

extension AppCoordinator: FlashCardViewControllerDelegate {
    func flashCardViewController(_ flashCardViewController: FlashCardViewController, edit cdDeck: CDDeck) {
        showEditorCoordinator(cdDeck: cdDeck)
    }
    
    func flashCardViewController(_ flashCardViewController: FlashCardViewController, share cdDeck: CDDeck) {
        showShareDeckActivityViewController(on: flashCardViewController, deck: cdDeck.deck)
    }
}

extension AppCoordinator: EditCoordinatorDelegate {
    func didEndEditing(editorCoordinator: EditorCoordinator) {
        editorCoordinator.navigationController.dismiss(animated: true, completion: nil)
        removeChildCoordinator(coordinator: editorCoordinator)
    }
}
