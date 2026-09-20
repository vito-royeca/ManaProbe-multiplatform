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
    var items = [FBCollectionItem]()

    @ObservationIgnored
    private let collectionName = "collections"
    
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
            items.removeAll()
            
            var ids = [String]()
            
            if let id = collection.id {
                let snapshot = try await db
                    .collection("\(collectionName)/\(id)/cards")
                    .getDocuments()
                
                for document in snapshot.documents {
                    ids.append(document.documentID)
                    for itemDoc in try await db
                        .collection("\(collectionName)/\(id)/cards/\(document.documentID)/items")
                        .getDocuments()
                        .documents {
                        
                        var item = try itemDoc.data(as: FBCollectionItem.self)
                        item.id = itemDoc.documentID
                        items.append(item)
                    }
                }
            }
            
            if !ids.isEmpty {
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

    func create(name: String,
                description: String? = nil,
                newItems: [[String: FBCollectionItem]]) async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }
        
        isFailed = false
        isBusy = true
        
        let newCollection = FBCollection(uid: user.uid,
                                         name: name,
                                         description: description)
        
        do {
            // create the collection
            let collectionRef = try db.collection(collectionName).addDocument(from: newCollection)
            let collectionDoc = try await collectionRef.getDocument()
            
            // add the card items
            for item in newItems {
                for (k,v) in item {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(v)
                    
                    if var json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: Any] {
                        json["dateAdded"] = FieldValue.serverTimestamp()
                        json["dateUpdated"] = FieldValue.serverTimestamp()
                        
                        try await collectionRef
                            .collection("cards")
                            .document(k)
                            .setData([
                                "dateAdded": FieldValue.serverTimestamp(),
                                "dateUpdated": FieldValue.serverTimestamp()
                            ])
                            
                        try await collectionRef
                            .collection("cards")
                            .document(k)
                            .collection("items")
                            .addDocument(data: json)
                    }
                }
            }

            // update the collection
            try await collectionRef.updateData([
                "dateAdded": FieldValue.serverTimestamp(),
                "dateUpdated": FieldValue.serverTimestamp()
            ])
            collection = try collectionDoc.data(as: FBCollection.self)
            
            isBusy = false
            return true
        } catch {
            isFailed = true
            isBusy = false
            return false
        }
    }

    func update(collection: FBCollection,
                newItems: [[String: FBCollectionItem]]) async throws -> Bool {
        guard let _ = Auth.auth().currentUser,
              let collectionID = collection.id else {
            return false
        }
        
        isFailed = false
        isBusy = true
        
        do {
            // get the collection
            let collectionRef = db.collection(collectionName).document(collectionID)
            let collectionDoc = try await collectionRef.getDocument()
            
            // add the card items
            for item in newItems {
                for (k,v) in item {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(v)
                    
                    if var json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .allowFragments) as? [String: Any] {
                        json["dateAdded"] = FieldValue.serverTimestamp()
                        json["dateUpdated"] = FieldValue.serverTimestamp()
                        
                        try await collectionRef
                            .collection("cards")
                            .document(k)
                            .collection("items")
                            .addDocument(data: json)
                        
                        try await collectionRef
                            .collection("cards")
                            .document(k)
                            .updateData([
                                "dateUpdated": FieldValue.serverTimestamp()
                            ])
                    }
                }
            }
            
            // update the collection
            try await collectionRef.updateData([
                "dateAdded": FieldValue.serverTimestamp(),
                "dateUpdated": FieldValue.serverTimestamp()
            ])
            self.collection = try collectionDoc.data(as: FBCollection.self)

            return true
        } catch {
            isFailed = true
            isBusy = false
            return false
        }
    }
    
    func delete(cardID: String, itemID: String) async throws -> Bool {
        guard let _ = Auth.auth().currentUser,
              let collection,
              let collectionID = collection.id else {
            return false
        }
        
        isFailed = false
        isBusy = true
        
        do {
            var ref = db.collection(collectionName)
                .document(collectionID)
                .collection("cards")
                .document(cardID)
                .collection("items")
                .document(itemID)
            try await ref.delete()
            
            // delete the card if this is the last item
            if try await db.collection(collectionName)
                .document(collectionID)
                .collection("cards")
                .document(cardID)
                .collection("items")
                .getDocuments().documents.isEmpty {
                ref = db.collection(collectionName)
                    .document(collectionID)
                    .collection("cards")
                    .document(cardID)
                try await ref.delete()
            }
                
            
            
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
    
    func getUID() -> String? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        
        return user.uid
    }
}
