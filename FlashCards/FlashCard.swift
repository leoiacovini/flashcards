//
//  FlashCard.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 14/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import CoreData

public struct FlashCard {
    
    var title: String
    var question: String
    var answer: String
    
    var dictValue: Dictionary<String, String> {
        get {
            return ["title": title,
                    "question": question,
                    "answer": answer]
        }
    }
    
    public func exportToJson() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self.dictValue, options: [])
    }
    
    static func fromDict(_ dict: Dictionary<String, String>) -> FlashCard? {
        if let title = dict["title"],
            let question = dict["question"],
            let answer = dict["answer"] {
            return FlashCard(title: title, question: question, answer: answer)
        } else {
            return nil
        }
    }
    
    static func fromJsonData(_ data: Data) -> FlashCard? {
        let anyDict = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dict = anyDict as? Dictionary<String, String> {
            return FlashCard.fromDict(dict)
        } else {
            return nil
        }
    }
    
}

public class CDFlashCard: NSManagedObject {
    
    @NSManaged public var title: String
    @NSManaged public var question: String
    @NSManaged public var answer: String
    @NSManaged public var createdAt: Date
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
    }
    
    func delete(context: NSManagedObjectContext) {
        CDFlashCard.delete(flashCard: self, context: context)
    }
    
    var flashCard: FlashCard {
        get {
            return FlashCard(title: title, question: question, answer: answer)
        }
    }
    
}
