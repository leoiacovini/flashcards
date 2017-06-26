//
//  FlashCard.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import CoreData
import UIKit

public struct FlashCard: Codable {
    
    var title: String
    var question: String
    var answer: String
    var questionImage: Data?
    var answerImage: Data?
    
    init(title: String, question: String, answer: String, questionImage: Data? = nil, answerImage: Data? = nil) {
        self.title = title
        self.question = question
        self.answer = answer
        self.questionImage = questionImage
        self.answerImage = answerImage
    }
    
    init(title: String, question: String, answer: String, questionImage: UIImage?, answerImage: UIImage?) {
        let questionImageData: Data? = questionImage != nil ? UIImageJPEGRepresentation(questionImage!, 0.7) : nil
        let answerImageData: Data? = answerImage != nil ? UIImageJPEGRepresentation(answerImage!, 0.7) : nil
        self.init(title: title, question: question, answer: answer, questionImage: questionImageData, answerImage: answerImageData)
    }
    
}

public class CDFlashCard: NSManagedObject {
    
    @NSManaged public var title: String
    @NSManaged public var question: String
    @NSManaged public var answer: String
    @NSManaged public var createdAt: Date
    @NSManaged public var questionImage: Data?
    @NSManaged public var answerImage: Data?
    @NSManaged public var deck: CDDeck
    
    class public func delete(flashCard: CDFlashCard, context: NSManagedObjectContext) {
        context.delete(flashCard)
    }
    
    class public func allFlashCards(context: NSManagedObjectContext) -> Array<CDFlashCard>? {
        do {
            let cdFlashCardss = try context.fetch(CDFlashCard.fetchRequest()) as! Array<CDFlashCard>
            return cdFlashCardss
        } catch {
            print("Error")
            return nil
        }
    }
    
    @nonobjc class public func fetchRequest() -> NSFetchRequest<CDFlashCard> {
        return NSFetchRequest<CDFlashCard>(entityName: "CDFlashCard")
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.createdAt = Date()
    }
    
    convenience init(with flashCard: FlashCard, using context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = flashCard.title
        self.question = flashCard.question
        self.answer = flashCard.answer
        self.questionImage = flashCard.questionImage
        self.answerImage = flashCard.answerImage
    }
    
    func delete(context: NSManagedObjectContext) {
        CDFlashCard.delete(flashCard: self, context: context)
    }
    
    var flashCard: FlashCard {
        get {
            return FlashCard(title: title, question: question, answer: answer)
        }
    }
    
    private func imageToData(_ image: UIImage) -> Data? {
        return UIImageJPEGRepresentation(image, 0.7)
    }
    
    func setQuestionImage(_ image: UIImage) {
        self.questionImage = imageToData(image)
    }
    
    func setAnswerImage(_ image: UIImage) {
        self.answerImage = imageToData(image)
    }
    
}
