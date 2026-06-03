//
//  CardViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 08.09.18.
//

import SwiftUI
import ManaKit

// MARK: - CardViewModel

@MainActor
@Observable
class CardViewModel: CardsNavigatorDisplayDelegate {
    // MARK: - Variables
    
    var card: CardCompleteInfo?
    var faces: [InnerCardInfo]?
    var face: InnerCardInfo?
    var cardList = [InnerCardInfo]()

    var isBusy = false
    var isFailed = false
    
    @ObservationIgnored
    var id: String
    
    // MARK: - Initializers
    
    init(id: String) {
        self.id = id
    }
    
    // MARK: - Methods
    
    func fetchData() async -> Void {
        guard !isBusy, card == nil else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            
            card = try await ManaKitUtilities.shared.card(fetchRemote: false, id: id)?
                .fragments
                .cardCompleteInfo
            
            if let card = card {
                faces = card.faces.map { $0.fragments.innerCardInfo }
                face = faces?.first
            }

            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func reloadData() async {
        card = nil
        faces = nil
        face = nil
        await fetchData()
    }

    // MARK: - CardsNavigatorDisplayDelegate

    func display(card: InnerCardInfo) async {
        id = card.id
        await reloadData()
    }
}
