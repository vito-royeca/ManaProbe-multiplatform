//
//  CardVariationsView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 2/20/24.
//

import SwiftUI
import ManaKit

struct CardVariationsView: View {
    let cards: [InnerCardInfo]
    
    @State
    private var isExpanded  = true

    var body: some View {
        contentView
    }
    
    var contentView: some View {
        DisclosureGroup("Variations", isExpanded: $isExpanded) {
            ForEach(cards, id: \.self) { card in
                let cardArray = CardArray(selectedCard: card,
                                          cards: [:])
                let route = CardRoute.detail(cardArray: cardArray)
                NavigationLink(value: route) {
                    CardListItemView(card: card)
                        .tint(.primary)
                }
            }
        }
    }
}
