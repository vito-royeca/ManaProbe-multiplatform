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

struct FBCollectionItem: Identifiable, Codable, Hashable {
    @DocumentID
    var id: String?
    var cardID: String
    var isFoil: Bool
    var condition: CardCondition
    var notes: String?
    var dateAcquired: Foundation.Date?
    var placeAcquired: String?
    var purchaseCurrencyCode: String?
    var purchasePrice: Double?
    var dateAdded: Foundation.Date?
    var dateUpdated: Foundation.Date?
    
    enum CodingKeys: String, CodingKey {
        case id,
            cardID,
            isFoil,
            condition,
            notes,
            dateAcquired,
            placeAcquired,
            purchaseCurrencyCode,
            purchasePrice,
            dateAdded,
            dateUpdated
    }
    
    init(cardID: String,
         isFoil: Bool,
         condition: CardCondition) {
        self.cardID = cardID
        self.isFoil = isFoil
        self.condition = condition
    }

    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let id = try container.decodeIfPresent(String.self, forKey: .id) {
            self.id = id
        }
        
        if let cardID = try container.decodeIfPresent(String.self, forKey: .cardID) {
            self.cardID = cardID
        } else {
            cardID = ""
        }
        
        if let isFoil = try container.decodeIfPresent(Bool.self, forKey: .isFoil) {
            self.isFoil = isFoil
        } else {
            isFoil = false
        }
        
        if let condition = try container.decodeIfPresent(String.self, forKey: .condition) {
            self.condition = CardCondition(rawValue: condition) ?? .lightlyPlayed
        } else {
            condition = .lightlyPlayed
        }
        
        if let notes = try container.decodeIfPresent(String.self, forKey: .notes) {
            self.notes = notes
        } else {
            notes = ""
        }

        do {
            if let dateAcquired = try container.decodeIfPresent(Double.self, forKey: .dateAcquired) {
                self.dateAcquired = Date(timeIntervalSinceReferenceDate: dateAcquired)
            }
        } catch {
            if let dateAcquired = try container.decodeIfPresent(Double.self, forKey: .dateAcquired) {
                self.dateAcquired = Date(timeIntervalSinceReferenceDate: dateAcquired)
            }
        }
        
        if let placeAcquired = try container.decodeIfPresent(String.self, forKey: .placeAcquired) {
            self.placeAcquired = placeAcquired
        }
        if let purchaseCurrencyCode = try container.decodeIfPresent(String.self, forKey: .purchaseCurrencyCode) {
            self.purchaseCurrencyCode = purchaseCurrencyCode
        }
        if let purchasePrice = try container.decodeIfPresent(Double.self, forKey: .purchasePrice) {
            self.purchasePrice = purchasePrice
        }
        
        do {
            if let dateAdded = try container.decodeIfPresent(Foundation.Date.self, forKey: .dateAdded) {
                self.dateAdded = dateAdded
            }
        } catch {
            if let dateAdded = try container.decodeIfPresent(Double.self, forKey: .dateAdded) {
                self.dateAdded = Date(timeIntervalSinceReferenceDate: dateAdded)
            }
        }
        
        do {
            if let dateUpdated = try container.decodeIfPresent(Foundation.Date.self, forKey: .dateUpdated) {
                self.dateUpdated = dateUpdated
            }
        } catch {
            if let dateUpdated = try container.decodeIfPresent(Double.self, forKey: .dateUpdated) {
                self.dateUpdated = Date(timeIntervalSinceReferenceDate: dateUpdated)
            }
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(cardID, forKey: .cardID)
        try container.encode(isFoil, forKey: .isFoil)
        try container.encode(condition, forKey: .condition)
        if let notes {
            try container.encode(notes, forKey: .notes)
        }
        if let dateAcquired {
            try container.encode(dateAcquired, forKey: .dateAcquired)
        }
        if let placeAcquired {
            try container.encode(placeAcquired, forKey: .placeAcquired)
        }
        if let purchaseCurrencyCode {
            try container.encode(purchaseCurrencyCode, forKey: .purchaseCurrencyCode)
        }
        if let purchasePrice {
            try container.encode(purchasePrice, forKey: .purchasePrice)
        }
        if let dateAdded {
            try container.encode(dateAdded, forKey: .dateAdded)
        }
        if let dateUpdated {
            try container.encode(dateUpdated, forKey: .dateUpdated)
        }
    }
}

struct FBCollection: Identifiable, Codable, Hashable {
    @DocumentID
    var id: String?
    var uid: String
    var name: String
    var description: String?
    var count: Int?
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
//    var mainboard: [FBCard]
//    var sideboard: [FBCard]
    var dateAdded: Foundation.Date?
    var dateUpdated: Foundation.Date?
}

