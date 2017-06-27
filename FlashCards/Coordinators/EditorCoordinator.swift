//
//  EditorCoordinator.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 27/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import CoreData

protocol EditDeckViewControllerDelegate: Coordinator {
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, save cdDeck: CDDeck)
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, cancel cdDeck: CDDeck)
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, edit cdFlashCard: CDFlashCard?)
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, delete cdFlashCard: CDFlashCard)
}

protocol EditFlashCardViewControllerDelegate: Coordinator {
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, save cdFlashCard: CDFlashCard)
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, pickImageWith handler: ImagePickerDelegateHandler)
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
        navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.3970538261, green: 0.638962799, blue: 1, alpha: 1)
        navigationController.navigationBar.tintColor = UIColor.white
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
    
    func showFlashCardEditor(cdFlashCard: CDFlashCard?) {
        let editFlashCardViewController = loadFromStoryboard(identifier: EditFlashCardViewController.identifier) as! EditFlashCardViewController
        editFlashCardViewController.cdFlashCard = cdFlashCard
        editFlashCardViewController.coordinator = self
        editFlashCardViewController.context = self.context
        navigationController.pushViewController(editFlashCardViewController, animated: true)
    }
    
}

extension EditorCoordinator: EditDeckViewControllerDelegate {
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, save cdDeck: CDDeck) {
        self.context.performAndWait { try! self.context.save() }
        assembler.databaseController.viewContext.performAndWait { self.assembler.databaseController.saveContext() }
        parentCoordinator.didEndEditing(editorCoordinator: self)
    }
    
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, cancel cdDeck: CDDeck) {
        // Clean up contexts before leaving yo guarantee nothing was left behind
        context.reset()
        assembler.databaseController.viewContext.rollback()
        parentCoordinator.didEndEditing(editorCoordinator: self)
    }
    
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, edit cdFlashCard: CDFlashCard?) {
        showFlashCardEditor(cdFlashCard: cdFlashCard)
    }
    
    func editDeckViewController(_ editDeckViewController: EditDeckViewController, delete cdFlashCard: CDFlashCard) {
        cdFlashCard.delete(context: self.context)
        self.cdDeck!.removeCDFlashCard(cdFlashCard)
    }
}

extension EditorCoordinator: EditFlashCardViewControllerDelegate {
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, save cdFlashCard: CDFlashCard) {
        self.cdDeck?.addCDFlashCard(cdFlashCard)
        navigationController.popViewController(animated: true)
    }
    
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, pickImageWith handler: ImagePickerDelegateHandler) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = handler
        editFlashCardViewController.present(imagePickerController, animated: true)
    }
    
}

