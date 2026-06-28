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
class CardAllPrintingsViewModel: CardsViewModel  {
    // MARK: - Variables
    
    var card: InnerCardInfo

    // MARK: - Initializers

    init(card: InnerCardInfo) {
        self.card = card
    }
    
    // MARK: - Methods
    
    override func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            cards.removeAll()
            
            cards[""] = try await ManaKitUtilities.shared.cardPrintings(fetchRemote: fetchRemote,
                                                                        id: card.id,
                                                                        languageID: card.language?.id ?? "en")?
                .cards.map { $0.fragments.cardBasicInfo } ?? []
            formatData()
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
}
