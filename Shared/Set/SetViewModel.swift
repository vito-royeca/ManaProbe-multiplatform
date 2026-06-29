//
//  SetViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/12/26.
//

import SwiftUI

import Apollo
import ManaKit

// MARK: - SetViewModel

@MainActor
@Observable
class SetViewModel: CardsViewModel  {
    
    // MARK: - Variables

    var set: SetInfo?
    var language: SetInfo.Language? = nil
    
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
        let langID = set.languages.first?.id ?? "en"
        
        self.setID = set.id
        self.languageID = langID
        
        self.set = set.fragments.setInfo
        self.language = set.languages.first(where: { $0.id == langID })
        super.init(cards: ["" : set.cards.map { $0.fragments.cardBasicInfo }])
    }

    
    // MARK: - Methods
    
    override func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy, set == nil, cards.isEmpty else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            cards.removeAll()
            
            let setData = try await ManaKitUtilities.shared.set(fetchRemote: fetchRemote,
                                                                setID: setID,
                                                                languageID: language?.id ?? "en")
            set = setData?.fragments.setInfo
            cards[""] = setData?.cards.map { $0.fragments.cardBasicInfo } ?? []
            if language == nil {
                language = (set?.languages ?? []).first(where: { $0.id == languageID })
            }
            formatData()
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    override func reloadData() async {
        set = nil
        await super.reloadData()
    }
    
}

