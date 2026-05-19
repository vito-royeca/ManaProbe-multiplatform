//
//  SetViewModel.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/12/26.
//

import SwiftUI

import Apollo
import ManaKit

// MARK: - SetViewModel

@MainActor
@Observable
class SetViewModel {
    
    // MARK: - Variables

    var set: SetInfo?
    var language: SetInfo.Language? = nil
    var cards = [CardBasicInfo]()
    
    var isBusy = false
    var isFailed = false
    
    @ObservationIgnored
    var currentCard: CardBasicInfo?
    
    @ObservationIgnored
    var cardIndex = 0

    @ObservationIgnored
    private var setID: String
    
    @ObservationIgnored
    private var languageID: String
    
    // MARK: - Initializers

    init(setID: String, languageID: String) {
        self.setID = setID
        self.languageID = languageID
    }
    
    init(set: SetQuery.Data.Set) {
        self.set = set.fragments.setInfo
        setID = set.id
        languageID = set.languages.first?.id ?? "en"
        language = set.languages.first(where: { $0.id == languageID })
        cards = set.cards.map { $0.fragments.cardBasicInfo }
    }

    // MARK: - Methods
    
    func fetchData() async -> Void {
        guard !isBusy, set == nil else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            
            let setData = try await ManaKitUtilities.shared.set(fetchRemote: false, setID: setID, languageID: language?.id ?? "en")
            set = setData?.fragments.setInfo
            cards = setData?.cards.map { $0.fragments.cardBasicInfo } ?? []
            if language == nil {
                language = (set?.languages ?? []).first(where: { $0.id == languageID })
            }
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func reloadData() async {
        set = nil
        cards.removeAll()
        await fetchData()
    }
}

extension SetViewModel: CardsViewModelDelegate {
    func fetchCards(sortBy: CardsSorter, orderBy: CardsOrderer) async throws -> [ManaKit.CardBasicInfo] {
        cards
    }
}

