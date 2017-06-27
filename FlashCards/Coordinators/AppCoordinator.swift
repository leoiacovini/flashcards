//
//  AppCoordinator.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 27/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import CoreData

protocol Coordinator: class {
    var navigationController: UINavigationController! { get set }
    var childCoordinators: Array<Coordinator> { get set }
    func start()
}

protocol CoordinatorDelegate {
    var coordinator: Coordinator! { get set }
}

extension Coordinator {
    func addChildCoordinator(coordinator: Coordinator) {
        self.childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(coordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== coordinator  }
    }
}

extension Coordinator {
    func loadFromStoryboard(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

protocol DecksCollectionViewControllerDelegate: Coordinator {
    func didTapEditDeck(cdDeck: CDDeck?)
    func didTapShareDeck(cdDeck: CDDeck)
    func didSelectDeck(cdDeck: CDDeck)
    func didDeleteDeck(cdDeck: CDDeck)
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
    
}

extension AppCoordinator: DecksCollectionViewControllerDelegate {
    func didTapEditDeck(cdDeck: CDDeck?) {
        let editorCoordinator = EditorCoordinator(cdDeck: cdDeck, assembler: assembler)
        editorCoordinator.parentCoordinator = self
        addChildCoordinator(coordinator: editorCoordinator)
        editorCoordinator.start()
        navigationController.present(editorCoordinator.navigationController, animated: true, completion: nil)
    }
    
    func didTapShareDeck(cdDeck: CDDeck) {
        let url = self.assembler.documentController.createDeckFile(deck: cdDeck.deck)
        let activityVc = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        navigationController.present(activityVc, animated: true, completion: nil)
    }
    
    func didSelectDeck(cdDeck: CDDeck) {
        let flashCardViewController = loadFromStoryboard(identifier: FlashCardViewController.identifier) as! FlashCardViewController
        flashCardViewController.deck = cdDeck.deck
        self.navigationController.pushViewController(flashCardViewController, animated: true)
    }
    
    func didDeleteDeck(cdDeck: CDDeck) {
        cdDeck.delete(context: self.assembler.databaseController.viewContext)
        self.assembler.databaseController.saveContext()
    }
}

extension AppCoordinator: EditCoordinatorDelegate {
    func didEndEditing(editorCoordinator: EditorCoordinator) {
        editorCoordinator.navigationController.dismiss(animated: true, completion: nil)
        removeChildCoordinator(coordinator: editorCoordinator)
    }
}

protocol EditDeckViewControllerDelegate: Coordinator {
    func didTapSave()
    func didCancel()
    func didEditFlashCard(cdFlashCard: CDFlashCard?)
    func didDeleteFlashCard(cdFlashCard: CDFlashCard)
}

protocol EditFlashCardViewControllerDelegate: Coordinator {
    func didSaveFlashCard(_ cdFlashCard: CDFlashCard)
    func didTapSelectImage(handler: ImagePickerDelegateHandler)
}

class EditorCoordinator: Coordinator {
    
    var navigationController: UINavigationController!
    var parentCoordinator: EditCoordinatorDelegate!
    var childCoordinators: Array<Coordinator> = []
    var assembler: Assembler!
    var cdDeck: CDDeck?
    var context: NSManagedObjectContext!
    
    init(cdDeck: CDDeck?, assembler: Assembler) {
        self.navigationController = UINavigationController()
        self.assembler = assembler
        self.context = assembler.databaseController.viewContext.child()
        self.cdDeck = cdDeck == nil ? CDDeck(context: self.context) : self.context.object(with: cdDeck!.objectID) as! CDDeck
    }
    
    func start() {
        let editDeckViewController = loadFromStoryboard(identifier: EditDeckViewController.identifier) as! EditDeckViewController
        editDeckViewController.coordinator = self
        editDeckViewController.cdDeck = self.cdDeck
        editDeckViewController.tmpContext = self.context
        navigationController.pushViewController(editDeckViewController, animated: true)
    }
    
}

extension EditorCoordinator: EditDeckViewControllerDelegate {
    func didTapSave() {
        self.context.performAndWait { try! self.context.save() }
        assembler.databaseController.viewContext.performAndWait { self.assembler.databaseController.saveContext() }
        parentCoordinator.didEndEditing(editorCoordinator: self)
    }
    
    func didCancel() {
        context.reset()
        parentCoordinator.didEndEditing(editorCoordinator: self)
    }
    
    func didEditFlashCard(cdFlashCard: CDFlashCard?) {
        let editFlashCardViewController = loadFromStoryboard(identifier: EditFlashCardViewController.identifier) as! EditFlashCardViewController
        editFlashCardViewController.cdFlashCard = cdFlashCard
        editFlashCardViewController.coordinator = self
        editFlashCardViewController.context = self.context
        navigationController.pushViewController(editFlashCardViewController, animated: true)
    }
    
    func didDeleteFlashCard(cdFlashCard: CDFlashCard) {
        cdFlashCard.delete(context: self.context)
        self.cdDeck!.removeCDFlashCard(cdFlashCard)
    }
}

extension EditorCoordinator: EditFlashCardViewControllerDelegate {
    func didSaveFlashCard(_ cdFlashCard: CDFlashCard) {
        self.cdDeck?.addCDFlashCard(cdFlashCard)
        navigationController.popViewController(animated: true)
    }
    
    func didTapSelectImage(handler: ImagePickerDelegateHandler) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = handler
        navigationController.present(imagePickerController, animated: true)
    }
}
