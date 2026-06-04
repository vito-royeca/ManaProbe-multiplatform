//
//  CardAllPrintingsViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/24/26.
//

import SwiftUI
import ManaKit

@MainActor
@Observable
class CardAllPrintingsViewModel {
    // MARK: - Variables
    
    var card: InnerCardInfo
    var cards = [CardBasicInfo]()
    
    var isBusy = false
    var isFailed = false

    // MARK: - Initializers

    init(card: InnerCardInfo) {
        self.card = card
    }
    
    // MARK: - Methods
    
    func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            
            cards = try await ManaKitUtilities.shared.cardPrintings(fetchRemote: fetchRemote,
                                                                    id: card.id,
                                                                    languageID: card.language?.id ?? "en")?
                .cards.map { $0.fragments.cardBasicInfo } ?? []
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
}

extension CardAllPrintingsViewModel: CardsViewModelDelegate {
    func fetchCards(fetchRemote: Bool, sortBy: CardsSorter, orderBy: CardsOrderer) async throws -> [ManaKit.CardBasicInfo] {
        await fetchData(fetchRemote: fetchRemote)
        return cards
    }
}
