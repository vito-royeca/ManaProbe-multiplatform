//
//  FirebaseModels.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/3/26.
//

import FirebaseAuth
import FirebaseFirestore

enum CardCondition: String, Codable, CaseIterable {
    case nearMint, lightlyPlayed, moderatelyPlayed, heavilyPlayed, damaged
    
    var description: String {
        switch self {
        case .nearMint: return "Near Mint"
        case .lightlyPlayed: return "Lightly Played"
        case .moderatelyPlayed: return "Moderately Played"
        case .heavilyPlayed: return "Heavily Played"
        case .damaged: return "Damaged"
        }
    }
}

struct FBFavorite: Identifiable, Codable {
    @DocumentID
    var id: String?
    var uid: String
    var cardID: String
    var dateAdded: Foundation.Date
}

struct FBCardItem: Identifiable, Codable, Hashable {
    @DocumentID
    var id: String?
    var isFoil: Bool
    var condition: CardCondition
    var notes: String
    var dateAdded: Foundation.Date?
    var dateUpdated: Foundation.Date?
}

struct FBCard: Identifiable, Codable, Hashable {
    var id: String { cardID }
    var cardID: String
    var items: [FBCardItem]
}

struct FBCollection: Identifiable, Codable, Hashable {
    @DocumentID
    var id: String?
    var uid: String
    var name: String
    var description: String?
    var cards: [FBCard]
    var dateAdded: Foundation.Date?
    var dateUpdated: Foundation.Date?
}

struct FBDeck: Identifiable, Codable {
    @DocumentID
    var id: String?
    var uid: String
    var description: String
    var format: String
    var origAuthor: String
    var mainboard: [FBCard]
    var sideboard: [FBCard]
    var dateAdded: Foundation.Date?
    var dateUpdated: Foundation.Date?
}

