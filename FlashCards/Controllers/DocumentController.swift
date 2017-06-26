//
//  DocumentController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 19/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

class DocumentController {
    
    func saveTmpFile(name: String, data: Data, tmp: Bool = true) -> URL? {
        let tmp: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).deck")
        do {
            try data.write(to: tmp)
            return tmp
        } catch {
            print("Error writing to dir! \(tmp)")
            fatalError()
        }
    }
    
    func createDeckFile(deck: Deck) -> URL? {
        let jsonEnconder = JSONEncoder()
        guard let data = try? jsonEnconder.encode(deck) else { return nil }
        return saveTmpFile(name: deck.name, data: data)
    }
    
    func readDeckFile(url: URL) -> Deck? {
        if let data =  try? Data(contentsOf: url) {
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode(Deck.self, from: data)
        } else {
            return nil
        }
    }
    
}
