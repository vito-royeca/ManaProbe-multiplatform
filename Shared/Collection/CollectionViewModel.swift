//
//  CollectionViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/8/26.
//

import Foundation

import Apollo
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFirestore
import ManaKit

@MainActor
@Observable
class CollectionViewModel {
    var collection: FBCollection?
    var isBusy = false
    var isFailed = false

    @ObservationIgnored
    private let collentionName = "collections"
    
    @ObservationIgnored
    private var db = Firestore.firestore()
    
    init(collection: FBCollection?) {
        self.collection = collection
    }
    
    func fetchData() async -> Void {
        guard !isBusy,
            let _ = Auth.auth().currentUser else {
            return
        }

        isFailed = false
        isBusy = true
        
        await fetchCardsData()
        
        isBusy = false
    }
    
    private func fetchCardsData(fetchRemote: Bool = false) async -> Void {
        guard let collection, cards.isEmpty else {
            return
        }
        
        do {
            let ids = collection.cards.map(\.cardID)
            cards[""] = try await ManaKitUtilities.shared.cardsByIDs(fetchRemote: fetchRemote, cardIDs: ids)?
                .cards.map { $0.fragments.cardBasicInfo } ?? []
                
        } catch {
            isFailed = true
            isBusy = false
        }
    }

    func create(name: String,
                description: String? = nil,
                card: FBCard) async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        
        isFailed = false
        isBusy = true
        
        let newCollection = FBCollection(uid: user.uid,
                                         name: name,
                                         description: description,
                                         cards: [card],
                                         dateAdded: Date(),
                                         dateUpdated: Date())
        
        do {
            let ref = try db.collection(collentionName).addDocument(from: newCollection)
            let doc = try await ref.getDocument()
            collection = try doc.data(as: FBCollection.self)
            
            isBusy = false
            return true
        } catch {
            isFailed = true
            isBusy = false
            return false
        }
    }

    func update(collectionUpdate: FBCollection,
                name: String,
                description: String? = nil,
                card: FBCard) async throws -> Bool {
        guard let user = Auth.auth().currentUser,
              let id = collectionUpdate.id else {
            return false
        }
        
        isFailed = false
        isBusy = true
        
        var cards = collectionUpdate.cards
        if let index = cards.firstIndex(where: { $0.cardID == card.cardID }) {
            var existingCard = cards.remove(at: index)

            if card.quantity > 0 {
                existingCard.quantity = card.quantity
                existingCard.isFoil = card.isFoil
                existingCard.condition = card.condition
                existingCard.notes = card.notes
                cards.append(existingCard)
            }
        } else {
            cards.append(card)
        }
        
        let collectionData = FBCollection(uid: user.uid,
                                      name: name,
                                      description: description,
                                      cards: cards,
                                      dateUpdated: Date())
        
        do {
            let ref = db.collection(collentionName).document(id)
            try ref.setData(from: collectionData)
            let doc = try await ref.getDocument()
            collection = try doc.data(as: FBCollection.self)
            isBusy = false
            return true
        } catch {
            isFailed = true
            isBusy = false
            return false
        }
    }
    
//    func calculateTotalValue(for collection: FBCollection) -> (Double,Double) {
//        var normalTotal = 0.0
//        var foilTotal = 0.0
//        
//        for card in collection.cards {
//            if card.isFoil {
//                
//            }
//        }
//        
//        return (normalTotal, foilTotal)
//    }



    // MARK: - CardsViewModelDelegate

    func fetchCards(fetchRemote: Bool, sortBy: CardsSorter, orderBy: CardsOrderer) async throws{
        await fetchCardsData(fetchRemote: fetchRemote)
    }
    
    var cards = [String: [CardBasicInfo]]()
}
