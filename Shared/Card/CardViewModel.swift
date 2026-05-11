//
//  CardViewModel.swift
//  ManaGuide
//
//  Created by Jovito Royeca on 08.09.18.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//

import SwiftUI
import ManaKit

struct CardArray: Hashable {
    let selectedCard: InnerCardInfo
    let cards: [String: [CardBasicInfo]]
}

// MARK: - CardViewModel

@MainActor
@Observable
class CardViewModel {
    // MARK: - Variables
    
    var card: CardCompleteInfo?
    var faces: [InnerCardInfo]?
    var face: InnerCardInfo?
    var cardList = [InnerCardInfo]()

    var hasPrevious = false
    var hasNext = false

    var isBusy = false
    var isFailed = false
    
    @ObservationIgnored
    private var cardArray: CardArray
    
    // MARK: - Initializers
    
    init(cardArray: CardArray) {
        self.cardArray = cardArray
    }

    init(card: CardCompleteInfo, cards: [String: [CardBasicInfo]] = [String: [CardBasicInfo]]()) {
        self.card = card
        self.cardArray = CardArray(selectedCard: card.fragments.innerCardInfo,
                                   cards: cards)
    }
    
    // MARK: - Methods
    
    func fetchData() async -> Void {
        guard !isBusy, card == nil else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            
            clearData()
            
            let response = try await ManaKitUtilities.shared.apollo.fetch(query: CardQuery(id: cardArray.selectedCard.id))
            card = response.data?.card?.fragments.cardCompleteInfo
            
            if let card = card {
                faces = card.faces.map { $0.fragments.innerCardInfo }
                face = faces?.first
                cardArray = CardArray(selectedCard: card.fragments.innerCardInfo,
                                      cards: cardArray.cards)
            }

            formatData()
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func formatData() -> Void {
        
    }

    func reloadData() async {
        card = nil
        faces = nil
        face = nil
//        clearData()
        await fetchData()
    }

    private func clearData() {
        
    }
}

extension CardViewModel {
    func updateNavigation() {
        var index = 0
        var cardCount = 0
        
        for (_,v) in cardArray.cards {
            cardCount += v.count
            
            for card in v {
                index += 0
                
            }
        }
        hasPrevious = index != 0
//        hasNext =
    }
    func goToNext() async {
        guard hasNext else {
            return
        }
        
    }
    
    func goToPrevious() async {
        guard hasPrevious else {
            return
        }
        
    }
}
