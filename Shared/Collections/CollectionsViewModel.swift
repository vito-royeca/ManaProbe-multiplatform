//
//  CollectionsViewModel.swift
//  ManaGuide
//
//  Created by Vito Royeca on 5/3/26.
//

import Apollo
import FirebaseAuth
import FirebaseAuthSwiftUI
import FirebaseFirestore
import ManaKit

@MainActor
@Observable
class CollectionsViewModel {
    var collections = [FBCollection]()
    var selectedCollection: FBCollection?
    
    var isBusy = false
    var isFailed = false
    
    @ObservationIgnored
    private let collentionName = "collections"
    
    @ObservationIgnored
    private var db = Firestore.firestore()
    
    func fetchData() async -> Void {
        guard let user = Auth.auth().currentUser,
            collections.isEmpty else {
            return
        }
        
        isFailed = false
        isBusy = true
        
        do {
            let snapshot = try await db
                .collection(collentionName)
                .whereField("uid", isEqualTo: user.uid)
                .order(by: "name")
                .getDocuments()
            collections = snapshot.documents.compactMap { document in
                try? document.data(as: FBCollection.self)
            }
            selectedCollection = collections.first

            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
}
