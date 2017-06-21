//
//  NewDeckViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 15/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import CoreData

class EditDeckViewController: UIViewController {

    var assembler: Assembler!
    var cdDeck: CDDeck!
    var tempContext: NSManagedObjectContext!
    
    var newFlashCardButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = #colorLiteral(red: 0.2421162659, green: 0.9293702411, blue: 0.2194416056, alpha: 1)
        button.tintColor = UIColor.white
        button.setTitle("New Flash Card", for: UIControlState.normal)
        button.addTarget(self, action: #selector(newFlashCard), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    var deckNameCell: TextInputTableViewCell! {
        didSet {
            deckNameCell.textInput.delegate = self
            deckNameCell.textInput.text = cdDeck.name
            deckNameCell.selectionStyle = UITableViewCellSelectionStyle.none
        }
    }
    var deckColorCell: ColorPickerTableViewCell! {
        didSet {
            let hexColor = cdDeck.hexColor
            deckColorCell.colorPickerView.selectedColor = UIColor(hexColor: hexColor)
            deckColorCell.selectionStyle = UITableViewCellSelectionStyle.none
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tempContext = assembler.databaseController.child()
        navigationController?.navigationBar.tintColor = UIColor.white
        if cdDeck == nil {
            self.cdDeck = CDDeck(context: tempContext)
        } else {
            self.cdDeck = tempContext.object(with: cdDeck.objectID) as! CDDeck
        }
        self.deckNameCell = self.tableView.dequeueReusableCell(withIdentifier: TextInputTableViewCell.reuseIdentifier) as! TextInputTableViewCell
        self.deckColorCell = self.tableView.dequeueReusableCell(withIdentifier: ColorPickerTableViewCell.reuseIdentifier) as! ColorPickerTableViewCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func saveNewDeck(sender: UIButton!) {
        cdDeck.name = deckNameCell.textInput.text!
        cdDeck.hexColor = deckColorCell.colorPickerView.selectedColor?.hexValue ?? "FFFFFF"
        print(tempContext.hasChanges)
        tempContext.performAndWait {
            try! self.tempContext.save()
        }
        assembler.databaseController.viewContext.performAndWait {
             self.assembler.databaseController.saveContext()
        }
        print(assembler.databaseController.viewContext.hasChanges)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func newFlashCard() {
        self.performSegue(withIdentifier: "addFlashCard", sender: newFlashCardButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFlashCard" {
            let editFlashCardViewController = segue.destination as! EditFlashCardViewController
            if let cell = sender as? FlashCardTableViewCell {
                editFlashCardViewController.cdFlashCard = cell.cdFlashCard
            }
            editFlashCardViewController.context = self.tempContext
            editFlashCardViewController.delegate = self
        }
    }

}

// MARK - EditFlashCardViewControllerDelegate

extension EditDeckViewController: EditFlashCardControllerDelegate {
    
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, didSaveFlashCard cdFlashCard: CDFlashCard) {
        editFlashCardViewController.navigationController?.popViewController(animated: true)
        if (tableView.indexPathForSelectedRow == nil) {
            cdDeck.addCDFlashCard(cdFlashCard)
        }
    }
    
}

// MARK - UITextFieldDelegate

extension EditDeckViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.becomeFirstResponder()
        return true
    }

}

// MARK - UITableViewDataSource

extension EditDeckViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : cdDeck.size
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Deck Info" : "Flash Cards"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return self.deckNameCell
            case 1:
                return self.deckColorCell
            default:
                exit(EXIT_FAILURE)
            }
        } else {
            let flashCardCell = self.tableView.dequeueReusableCell(withIdentifier: FlashCardTableViewCell.reuseIdentifier, for: indexPath) as! FlashCardTableViewCell
            flashCardCell.cdFlashCard = cdDeck.cdFlashCardsArray[indexPath.row]
            return flashCardCell
        }
    }
    
}

// MARK - UITableViewDelegate

extension EditDeckViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 && indexPath.row == 1 ? 58 : 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 1 ? self.newFlashCardButton : nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(50)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: "addFlashCard", sender: cell as! FlashCardTableViewCell)
        } else {
            cell?.isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.section == 1 else { return [] }
        return [UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete", handler: { (action, indexPath) in
            let fcTableViewCell = tableView.cellForRow(at: indexPath) as! FlashCardTableViewCell
            let cdFlashCard = fcTableViewCell.cdFlashCard!
            cdFlashCard.delete(context: self.assembler.databaseController.viewContext)
            self.cdDeck.removeCDFlashCard(cdFlashCard)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        })]
    }
    
}
