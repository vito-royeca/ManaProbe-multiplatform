//
//  SearchViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 7/30/26.
//

import SwiftUI
import ManaKit

// MARK: - SearchViewModel

@MainActor
@Observable
class SearchViewModel: CardsViewModel {
    
    // MARK: - Variables
    
    var query = ""
    
    // MARK: - Methods
    
    override func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy, !query.isEmpty else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            cards.removeAll()
            
            let searchData = try await ManaKitUtilities.shared.cardsSearch(fetchRemote: fetchRemote,
                                                                           query: query)
            cards[""] = searchData?.cards.map { $0.fragments.cardBasicInfo } ?? []
            formatData()
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
}
