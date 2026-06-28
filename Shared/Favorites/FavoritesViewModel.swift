//
//  FavoritesViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/26/26.
//

import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFirestore
import ManaKit

@MainActor
@Observable
class FavoritesViewModel: CardsViewModel {
    var favorites = [FBFavorite]()
    
    @ObservationIgnored
    private let collentionName = "favorites"
    
    @ObservationIgnored
    private var db = Firestore.firestore()
    
    override func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy, let user = Auth.auth().currentUser else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            cards.removeAll()
            
            let snapshot = try await db
                .collection(collentionName)
                .whereField("uid", isEqualTo: user.uid)
                .order(by: "cardID")
                .getDocuments()
            favorites = snapshot.documents.compactMap { document in
                try? document.data(as: FBFavorite.self)
            }
            
            if !favorites.isEmpty {
                let ids = favorites.map(\.cardID)
                cards[""] = try await ManaKitUtilities.shared.cardsByIDs(fetchRemote: fetchRemote, cardIDs: ids)?
                    .cards.map { $0.fragments.cardBasicInfo } ?? []
            }
            
            formatData()
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func create(card: CardBasicInfo) async throws -> Void {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            let favorite = FBFavorite(uid: user.uid,
                                      cardID: card.id,
                                      dateAdded: Date())
            let ref = try db.collection(collentionName)
                .addDocument(from: favorite)
            let doc = try await ref.getDocument()
            favorites.append(try doc.data(as: FBFavorite.self))
            var array = cards[""] ?? []
            array.append(card)
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func delete(card: CardBasicInfo) async throws -> Void {
        guard let _ = Auth.auth().currentUser,
              let favoriteId = favorites.filter({ $0.cardID == card.id }).first?.id else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            try await db.collection(collentionName).document(favoriteId).delete()
            favorites.removeAll(where: { $0.id == favoriteId })
            for (k,_) in cards {
                var array = cards[k] ?? []
                array.removeAll(where: { $0.id == card.id })
            }
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func createOrDelete(card: CardBasicInfo) async throws {
        if let _ = favorites.filter({ $0.cardID == card.id }).first {
            try await delete(card: card)
        } else {
            try await create(card: card)
        }
    }
    
    func isFavorite(cardID: String) -> Bool {
        guard let _ = Auth.auth().currentUser else {
            return false
        }
        
        return favorites.filter({ $0.cardID == cardID }).count > 0
    }
    
    func handleState(state: AuthenticationState) async {
        if state == .authenticated {
            await fetchData()
        } else if state == .unauthenticated {
            favorites.removeAll()
            cards.removeAll()
        }
    }
}
