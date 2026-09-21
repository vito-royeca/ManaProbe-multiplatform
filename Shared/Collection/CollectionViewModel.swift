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
    var items = [String: [FBCollectionItem]]()
    var selectedCardForEdit: CardBasicInfo? = nil
    var selectedItemForEdit: FBCollectionItem? = nil

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
                    var set = Set<FBCollectionItem>()
                    
                    for itemDoc in try await db
                        .collection("\(collectionName)/\(id)/cards/\(document.documentID)/items")
                        .getDocuments()
                        .documents {
                            var item = try itemDoc.data(as: FBCollectionItem.self)
                            item.id = itemDoc.documentID
                            set.insert(item)
                    }
                    items[document.documentID] = Array(set)
                }
            }
            
            if !ids.isEmpty {
                cards[""] = try await ManaKitUtilities.shared.cardsByIDs(fetchRemote: fetchRemote, cardIDs: ids)?
                    .cards.map { $0.fragments.cardBasicInfo } ?? []
            }
            
            formatData()
            
            isBusy = false
        } catch {
            print(error)
            isFailed = true
            isBusy = false
        }
    }

    func save() async throws {
        guard let _ = Auth.auth().currentUser,
            let collection,
            let collectionID = collection.id else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            // get the collection
            let collectionRef = db
                .collection(collectionName)
                .document(collectionID)
            

            // update the collection
            try await collectionRef.updateData([
                "name": collection.name,
                "description": collection.description ?? "",
                "dateUpdated": FieldValue.serverTimestamp()
            ])
            
            isBusy = false
        } catch {
            print(error)
            isFailed = true
            isBusy = false
        }
    }
    
    func create(name: String,
                description: String? = nil,
                newItems: [FBCollectionItem]) async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        let newCollection = FBCollection(uid: user.uid,
                                         name: name,
                                         description: description,
                                         count: newItems.count)
        
        do {
            // create the collection
            let collectionRef = try db
                .collection(collectionName)
                .addDocument(from: newCollection)
            let encoder = JSONEncoder()
            
            // add the card items
            for item in newItems {
                let data = try encoder.encode(item)
                
                if var json = try JSONSerialization.jsonObject(with: data,
                                                               options: .allowFragments) as? [String: Any] {
                    json["dateAdded"] = FieldValue.serverTimestamp()
                    json["dateUpdated"] = FieldValue.serverTimestamp()
                    
                    try await collectionRef
                        .collection("cards")
                        .document(item.cardID)
                        .setData([
                            "dateAdded": FieldValue.serverTimestamp(),
                            "dateUpdated": FieldValue.serverTimestamp()
                        ])
                        
                    try await collectionRef
                        .collection("cards")
                        .document(item.cardID)
                        .collection("items")
                        .addDocument(data: json)
                }
            }

            // update the collection
            try await collectionRef.updateData([
                "dateAdded": FieldValue.serverTimestamp(),
                "dateUpdated": FieldValue.serverTimestamp()
            ])
            
            isBusy = false
        } catch {
            print(error)
            isFailed = true
            isBusy = false
        }
    }

    func update(collection: FBCollection,
                newItems: [FBCollectionItem]) async throws {
        guard let _ = Auth.auth().currentUser,
              let collectionID = collection.id else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            // get the collection
            let collectionRef = db
                .collection(collectionName)
                .document(collectionID)
            let encoder = JSONEncoder()

            // add the card items
            for item in newItems {
                let data = try encoder.encode(item)
                
                if var json = try JSONSerialization.jsonObject(with: data,
                                                               options: .allowFragments) as? [String: Any] {
                    json["dateAdded"] = FieldValue.serverTimestamp()
                    json["dateUpdated"] = FieldValue.serverTimestamp()
                    
                    try await collectionRef
                        .collection("cards")
                        .document(item.cardID)
                        .setData([
                            "dateAdded": FieldValue.serverTimestamp(),
                            "dateUpdated": FieldValue.serverTimestamp()
                        ])
                    
                    try await collectionRef
                        .collection("cards")
                        .document(item.cardID)
                        .collection("items")
                        .addDocument(data: json)
                }
            }
            
            // update the collection
            try await collectionRef.updateData([
                "dateUpdated": FieldValue.serverTimestamp(),
                "count": (collection.count ?? 0) + 1
            ])
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func update(item: FBCollectionItem) async throws {
        guard let _ = Auth.auth().currentUser,
              let collectionID = collection?.id,
              let itemID = item.id else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            // get the collection
            let collectionRef = db
                .collection(collectionName)
                .document(collectionID)
            // get the item
            let itemRef = db
                .collection(collectionName)
                .document(collectionID)
                .collection("cards")
                .document(item.cardID)
                .collection("items")
                .document(itemID)
            let encoder = JSONEncoder()
            let data = try encoder.encode(item)
            
            if var json = try JSONSerialization.jsonObject(with: data,
                                                           options: .allowFragments) as? [String: Any] {
                json["dateUpdated"] = FieldValue.serverTimestamp()
                
                try await itemRef
                    .updateData(json)
            }
            
            // update the collection
            try await collectionRef.updateData([
                "dateUpdated": FieldValue.serverTimestamp()
            ])
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func delete(item: FBCollectionItem) async throws {
        guard let _ = Auth.auth().currentUser,
              let collection,
              let collectionID = collection.id else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            // get the collection
            let collectionRef = db
                .collection(collectionName)
                .document(collectionID)
            
            let deleteItemRef = db.collection(collectionName)
                .document(collectionID)
                .collection("cards")
                .document(item.cardID)
                .collection("items")
                .document(item.id ?? "")
            try await deleteItemRef.delete()
            
            // delete the cards cpllection if this is the last item
            if try await db.collection(collectionName)
                .document(collectionID)
                .collection("cards")
                .document(item.cardID)
                .collection("items")
                .getDocuments().documents.isEmpty {
                
                let deleteCardsRef = db.collection(collectionName)
                    .document(collectionID)
                    .collection("cards")
                    .document(item.cardID)
                try await deleteCardsRef.delete()
            }
            
            // update the collection
            try await collectionRef.updateData([
                "dateUpdated": FieldValue.serverTimestamp(),
                "count": (collection.count ?? 0) - 1
            ])
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
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
