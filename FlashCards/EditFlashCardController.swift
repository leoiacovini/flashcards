//
//  EditFlashCardTableViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

protocol EditFlashCardControllerDelegate: class {
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, didSaveFlashCard cdFlashCard: CDFlashCard) -> Void
}

class EditFlashCardViewController: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    
    weak var delegate: EditFlashCardControllerDelegate?
    var databaseController: DatabaseController!
    var cdFlashCard: CDFlashCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cdFlashCard = cdFlashCard {
            titleTextField.text = cdFlashCard.title
            questionTextField.text = cdFlashCard.question
            answerTextField.text = cdFlashCard.answer
        }
    }
    
    @IBAction func saveFlashCard(sender: UIButton!) {
        if titleTextField.text!.isEmpty || questionTextField.text!.isEmpty || answerTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Field", message: "There are missing fiels on your flashcard, please fill all of then", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        if cdFlashCard == nil {
            cdFlashCard = CDFlashCard(context: databaseController.viewContext)
        }
        cdFlashCard.title = titleTextField.text!
        cdFlashCard.question = questionTextField.text!
        cdFlashCard.answer = answerTextField.text!
        delegate?.editFlashCardViewController(self, didSaveFlashCard: cdFlashCard)
    }
    
}
