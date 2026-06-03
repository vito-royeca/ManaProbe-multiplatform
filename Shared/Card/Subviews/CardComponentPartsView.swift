//
//  CardComponentPartsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 2/20/24.
//

import SwiftUI
import ManaKit

struct CardComponentPartsView: View {
    let componentParts: [CardCompleteInfo.ComponentPart]
    
    @State
    private var isExpanded  = true

    var body: some View {
        contentView
    }
    
    var contentView: some View {
        DisclosureGroup("Parts", isExpanded: $isExpanded) {
            ForEach(Array(componentParts), id: \.self) { part in
                let route = CardRoute.details(selectedCard: part.card.fragments.innerCardInfo, navigator: nil)
                NavigationLink(value: route) {
                    VStack(alignment: .leading) {
                        Text(part.component.name)
                            .tint(.primary)
                        CardListItemView(card: part.card.fragments.innerCardInfo)
                            .tint(.primary)
                    }
                }
            }
        }
    }
}
