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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
}

protocol EditFlashCardControllerDelegate: class {
    func editFlashCardViewController(_ editFlashCardViewController: EditFlashCardViewController, didSaveFlashCard cdFlashCard: CDFlashCard) -> Void
}

class EditFlashCardViewController: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var addQuestionImageButton: UIButton!
    @IBOutlet weak var addAnswerImageButton: UIButton!
    
    weak var delegate: EditFlashCardControllerDelegate?
    var context: NSManagedObjectContext!
    var cdFlashCard: CDFlashCard!
    var questionImage: UIImage? {
        didSet {
            self.addQuestionImageButton.setBackgroundImage(questionImage, for: .normal)
        }
    }
    var answerImage: UIImage? {
        didSet {
            self.addAnswerImageButton.setBackgroundImage(answerImage, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboardOnTouch()
        questionTextView.delegate = self
        answerTextView.delegate = self
        if let cdFlashCard = cdFlashCard {
            titleTextField.text = cdFlashCard.title
            questionTextView.text = cdFlashCard.question
            answerTextView.text = cdFlashCard.answer
            questionImage = cdFlashCard.questionImage != nil ? UIImage(data: cdFlashCard.questionImage!) : #imageLiteral(resourceName: "add")
            answerImage = cdFlashCard.answerImage != nil ?  UIImage(data: cdFlashCard.answerImage!): #imageLiteral(resourceName: "add")
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
        if let image = questionImage { cdFlashCard.setQuestionImage(image) }
        if let image = answerImage { cdFlashCard.setAnswerImage(image) }
        delegate?.editFlashCardViewController(self, didSaveFlashCard: cdFlashCard)
    }
    
    private func getImage(handler: ImagePickerDelegateHandler) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = handler
        present(imagePickerController, animated: true)
    }
    
    var questionImageHandler: ImagePickerDelegateHandler!
    var answerImageHandler: ImagePickerDelegateHandler!
    
    @IBAction private func addQuestionImage(sender: UIButton!) {
        questionImageHandler = ImagePickerDelegateHandler(handlePickUp: { image in
            self.questionImage = image
        })
        getImage(handler: questionImageHandler)
    }
    
    @IBAction private func addAnswerImage(sender: UIButton!) {
        answerImageHandler = ImagePickerDelegateHandler(handlePickUp: { image in
            self.answerImage = image
        })
        getImage(handler: answerImageHandler)
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
