//
//  CardPrintingsView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 2/20/24.
//

import SwiftUI
import ManaKit

struct CardPrintingsView: View {
    let card: InnerCardInfo
    let cards: [InnerCardInfo]
    
    @State
    private var isExpanded  = true

    var body: some View {
        contentView
    }
    
    var contentView: some View {
        return DisclosureGroup("Printings", isExpanded: $isExpanded) {
            ForEach(cards, id: \.self) { card in
                let cardArray = CardArray(selectedCard: card,
                                          cards: [:])
                let route = CardRoute.detail(cardArray: cardArray)
                NavigationLink(value: route) {
                    CardListItemView(card: card)
                        .tint(.primary)
                }
            }

            if cards.count >= 10 {
                let route = CardRoute.printings(card: card)
                NavigationLink(value: route, label: {
                    HStack {
                        Text("See All")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                })
            }
        }
    }
}
