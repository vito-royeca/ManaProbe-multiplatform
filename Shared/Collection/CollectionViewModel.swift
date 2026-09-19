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
class CollectionViewModel: CardsViewModel {
    var collection: FBCollection?

    @ObservationIgnored
    private let collentionName = "collections"
    
    @ObservationIgnored
    private var db = Firestore.firestore()
    
    init(collection: FBCollection?) {
        self.collection = collection
    }
    
    override func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy, let collection, let _ = Auth.auth().currentUser else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            cards.removeAll()
            
            let ids = collection.cards.map(\.cardID)
            cards[""] = try await ManaKitUtilities.shared.cardsByIDs(fetchRemote: fetchRemote, cardIDs: ids)?
                .cards.map { $0.fragments.cardBasicInfo } ?? []
            
            formatData()
            
            isBusy = false
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

    func update(collection: FBCollection,
                with card: FBCard) async throws -> Bool {
        guard let user = Auth.auth().currentUser,
              let id = collection.id else {
            return false
        }
        
        isFailed = false
        isBusy = true
        
        do {
            var cards = [FBCard]()
            var found = false
            for collectionCard in collection.cards {
                if collectionCard.cardID == card.cardID {
                    var updateCard = collectionCard
                    updateCard.items.append(contentsOf: card.items)
                    cards.append(updateCard)
                    found = true
                } else {
                    cards.append(collectionCard)
                }
            }

            if !found {
                cards.append(card)
            }
            
            let updateData = FBCollection(uid: user.uid,
                                          name: collection.name,
                                          description: collection.description,
                                          cards: cards,
                                          dateUpdated: Date())
//            let updateData: [String: Any] = [
//                "cards": cards,
//                "dateUpdated": Foundation.Date()
//            ]
            
            let ref = db.collection(collentionName).document(id)
            try ref.setData(from: updateData)
//            try await ref.updateData(updateData)
            let doc = try await ref.getDocument()
            self.collection = try doc.data(as: FBCollection.self)
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
}
