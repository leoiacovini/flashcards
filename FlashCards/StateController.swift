//
//  StateController.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 17/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import Foundation

class StateController {
    
    var decks: Array<Deck> = [Deck(name: "Teste", flashCards: [FlashCard(title: "FlashCard", question: "Teste?", answer: "Isso"),
                                                               FlashCard(title: "Outro FlashCard", question: "Uma Outra Pergunta", answer: "Essa é a resposta")])]
    
}
