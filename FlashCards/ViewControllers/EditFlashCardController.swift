//
//  EditFlashCardTableViewController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit
import CoreData

class ImagePickerDelegateHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let handlerBlock: (UIImage) -> ()
    
    init(handlePickUp block: @escaping (UIImage) -> ()) {
        self.handlerBlock = block
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.handlerBlock(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
}

protocol EditFlashCardControllerDelegate: class {
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, didSaveFlashCard cdFlashCard: CDFlashCard) -> Void
}

class EditFlashCardViewController: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    
    weak var delegate: EditFlashCardControllerDelegate?
    var context: NSManagedObjectContext!
    var cdFlashCard: CDFlashCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboardOnTouch()
        questionTextView.delegate = self
        answerTextView.delegate = self
        if let cdFlashCard = cdFlashCard {
            titleTextField.text = cdFlashCard.title
            questionTextView.text = cdFlashCard.question
            answerTextView.text = cdFlashCard.answer
        }
        setUpPlaceholders()
    }
    
    @IBAction func saveFlashCard(sender: UIButton!) {
        if titleTextField.text!.isEmpty || questionTextView.text!.isEmpty || answerTextView.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Field", message: "There are missing fiels on your flashcard, please fill all of then", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        if cdFlashCard == nil {
            cdFlashCard = CDFlashCard(context: context)
        }
        cdFlashCard.title = titleTextField.text!
        cdFlashCard.question = questionTextView.text!
        cdFlashCard.answer = answerTextView.text!
        delegate?.editFlashCardViewController(self, didSaveFlashCard: cdFlashCard)
    }
    
    let handler = ImagePickerDelegateHandler { (image) in
        print(image)
    }
    
    private func getImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = handler
        present(imagePickerController, animated: true)
    }
    
    @IBAction private func addQuestionImage(sender: UIButton!) {
        getImage()
    }
    
    @IBAction private func addAnswerImage(sender: UIButton!) {
        
    }
    
}

extension EditFlashCardViewController: UITextViewDelegate {
    
    private func setUpPlaceholders() {
        if questionTextView.text.isEmpty {
            self.questionTextView.text = "Question"
            self.questionTextView.textColor = UIColor.lightGray
        }
        if answerTextView.text.isEmpty {
            self.answerTextView.text = "Answer"
            self.answerTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textView == questionTextView ? "Question" : "Answer"
            textView.textColor = UIColor.lightGray
        }
    }
    
}
