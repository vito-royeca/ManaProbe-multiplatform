//
//  CardLanguagesView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 2/20/24.
//

import SwiftUI
import ManaKit

struct CardLanguagesView: View {
    let cards: [InnerCardInfo]
    
    @State
    private var isExpanded  = true

    var body: some View {
        contentView
    }
    
    var contentView: some View {
        DisclosureGroup("Other Languages", isExpanded: $isExpanded) {
            ForEach(cards, id: \.self) { card in
                VStack(alignment: .leading) {
                    let route = CardRoute.details(selectedCard: card, navigator: nil)
                    Text(card.language?.name ?? "")
                    NavigationLink(value: route) {
                        CardListItemView(card: card)
                            .tint(.primary)
                    }
                }
            }
        }
    }
}

