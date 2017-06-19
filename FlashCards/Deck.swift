//
//  Deck.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 15/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import CoreData

struct Deck {
    
    var name: String
    var flashCards: Array<FlashCard>
    var hexColor: String
    
    var size: Int {
        get {
            return self.flashCards.count
        }
    }
    
    init(name: String) {
        self.name = name
        self.flashCards = []
        self.hexColor = "CDCDCD"
    }
    
    init(name: String, flashCards: Array<FlashCard>) {
        self.name = name
        self.flashCards = flashCards
        self.hexColor = "CDCDCD"
    }
    
    init(name: String, hexColor: String, flashCards: Array<FlashCard>) {
        self.name = name
        self.hexColor = hexColor
        self.flashCards = flashCards
    }
    
    mutating func insert(flashCard: FlashCard) {
        self.flashCards.append(flashCard)
    }
    
    mutating func remove(at index: Int) {
        self.flashCards.remove(at: index)
    }
    
    func convertToDict() -> Dictionary<String, Any> {
        let dictFlashCards = flashCards.map { $0.dictValue }
        return ["name": name,
                "hexColor": hexColor,
                "flashCards": dictFlashCards]
    }
    
    func exportToJson() -> Data? {
        return try? JSONSerialization.data(withJSONObject: convertToDict(), options: [])
    }
    
    static func fromDict(_ dict: Dictionary<String, Any>) -> Deck? {
        if let flashCardsDic = dict["flashCards"] as? Array<Dictionary<String, String>>,
            let flashCards = (flashCardsDic.map { FlashCard.fromDict($0) } as? Array<FlashCard>),
            let name = dict["name"] as? String,
            let hexColor = dict["hexColor"] as? String {
            return Deck(name: name, hexColor: hexColor, flashCards: flashCards)
        } else {
            return nil
        }
    }
    
    static func fromJsonData(_ data: Data) -> Deck? {
        let anyDict = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dict = anyDict as? Dictionary<String, Any> {
            return Deck.fromDict(dict)
        } else {
            return nil
        }
    }
    
    subscript(index: Int) -> FlashCard {
        get {
            return flashCards[index]
        }
        set {
            flashCards[index] = newValue
        }
    }
    
}

public class CDDeck: NSManagedObject {
    
    @NSManaged public var name: String
    @NSManaged public var hexColor: String
    @NSManaged public var createdAt: Date
    @NSManaged public var flashCards: Set<CDFlashCard>
    
    class public func delete(deck: CDDeck, context: NSManagedObjectContext) {
        context.delete(deck)
    }
    
    class public func allDecks(using context: NSManagedObjectContext) -> Array<CDDeck>? {
        do {
            let cdDecks = try context.fetch(CDDeck.fetchRequest()) as! Array<CDDeck>
            return cdDecks
        } catch {
            print("Error")
            return nil
        }
    }
    
    @nonobjc class public func fetchRequest() -> NSFetchRequest<CDDeck> {
        let fr = NSFetchRequest<CDDeck>(entityName: "CDDeck")
        fr.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return fr
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.createdAt = Date()
    }
    
    convenience init(with deck: Deck, using context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = deck.name
        self.hexColor = deck.hexColor
        self.flashCards = Set<CDFlashCard>(deck.flashCards.map { CDFlashCard(with: $0, using: context) })
    }
    
    func addFlashCard(_ flashCard: FlashCard, using context: NSManagedObjectContext) {
        let cdFlashCard = CDFlashCard(with: flashCard, using: context)
        self.flashCards.insert(cdFlashCard)
    }
    
    func removeCDFlashCard(_ cdFlashCard: CDFlashCard) {
        self.flashCards.remove(cdFlashCard)
    }
    
    func addCDFlashCard(_ cdFlashCard: CDFlashCard) {
        self.flashCards.insert(cdFlashCard)
    }
    
    func delete(context: NSManagedObjectContext) {
        CDDeck.delete(deck: self, context: context)
    }
    
    var size: Int {
        get {
            return self.flashCards.count
        }
    }
    
    var cdFlashCardsArray: Array<CDFlashCard> {
        get {
            return Array(self.flashCards).sorted(by: { $0.createdAt < $1.createdAt })
        }
    }
    
    var deck: Deck {
        get {
            var d = Deck(name: name)
            d.hexColor = hexColor
            d.flashCards = cdFlashCardsArray.map{ $0.flashCard }
            return d
        }
    }
    
    subscript(index: Int) -> CDFlashCard {
        get {
            return self.cdFlashCardsArray[index]
        }
    }
}
