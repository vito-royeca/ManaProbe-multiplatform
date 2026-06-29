//
//  CardRoute.swift
//  Manaprobe
//
//  Created by Vito Royeca on 6/29/26.
//

import ManaKit

enum CardRoute: Hashable {
    case details(selectedCard: InnerCardInfo, navigator: (any CardsNavigatorDelegate)?)
    case printings(card: InnerCardInfo)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .details(let selectedCard, _):
            hasher.combine(0) // Unique seed for this case
            hasher.combine(selectedCard)
        case .printings(let value):
            hasher.combine(1) // Unique seed for this case
            hasher.combine(value)
        }
    }

    static func == (lhs: CardRoute, rhs: CardRoute) -> Bool {
        switch (lhs, rhs) {
        case (.details(let lSelectedCard, _), .details(let rSelectedCard, _)): return lSelectedCard == rSelectedCard
        case (.printings(let l), .printings(let r)): return l.id == r.id
        default: return false
        }
    }
}

