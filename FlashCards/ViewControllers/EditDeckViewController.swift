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
    static let identifier: String = "editDeckViewController"
    
    @IBOutlet weak var tableView: UITableView!
    var coordinator: EditDeckViewControllerDelegate!
    var cdDeck: CDDeck!
    var tmpContext: NSManagedObjectContext!
    
    var newFlashCardButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = #colorLiteral(red: 0.2680124154, green: 0.8599500317, blue: 0.09030772692, alpha: 1)
        button.tintColor = UIColor.white
        button.setTitle("New Flash Card", for: UIControlState.normal)
        button.addTarget(self, action: #selector(newFlashCard), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    var deckNameCell: TextInputTableViewCell! {
        didSet {
            deckNameCell.textInput.delegate = self
            deckNameCell.textInput.placeholder = "Deck Name"
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

    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboardOnTouch()
        
        tableView.register(ColorPickerTableViewCell.self, forCellReuseIdentifier: ColorPickerTableViewCell.reuseIdentifier)
        tableView.register(TextInputTableViewCell.self, forCellReuseIdentifier: TextInputTableViewCell.reuseIdentifier)
        tableView.register(FlashCardTableViewCell.self, forCellReuseIdentifier: FlashCardTableViewCell.reuseIdentifier)
        
        deckNameCell = tableView.dequeueReusableCell(withIdentifier: TextInputTableViewCell.reuseIdentifier) as! TextInputTableViewCell
        deckColorCell = tableView.dequeueReusableCell(withIdentifier: ColorPickerTableViewCell.reuseIdentifier) as! ColorPickerTableViewCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func saveNewDeck(sender: UIButton!) {
        cdDeck.name = deckNameCell.textInput.text!
        cdDeck.hexColor = deckColorCell.colorPickerView.selectedColor?.hexValue ?? "CDCDCD"
        coordinator.didTapSave()
    }
    
    @objc func newFlashCard() {
        coordinator.didEditFlashCard(cdFlashCard: nil)
    }
    
    @IBAction private func dismissEditDeckController(sender: UIBarButtonItem!) {
        coordinator.didCancel()
    }

}

// MARK - UITextFieldDelegate

extension EditDeckViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
                fatalError()
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
        let cell = tableView.cellForRow(at: indexPath) as! FlashCardTableViewCell
        if indexPath.section == 1 {
            coordinator.didEditFlashCard(cdFlashCard: cell.cdFlashCard)
        } else {
            cell.isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.section == 1 else { return [] }
        return [UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete", handler: { (action, indexPath) in
            let fcTableViewCell = tableView.cellForRow(at: indexPath) as! FlashCardTableViewCell
            self.coordinator.didDeleteFlashCard(cdFlashCard: fcTableViewCell.cdFlashCard!)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        })]
    }
    
}
