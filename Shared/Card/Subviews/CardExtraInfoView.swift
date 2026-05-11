//
//  CardExtraInfoView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 11/8/23.
//

import SwiftUI
import ManaKit

struct CardExtraInfoView: View {
    let card: CardCompleteInfo
    
    @Environment(\.colorScheme)
    private var colorScheme
    @State
    private var isColorsExpanded  = true
    @State
    private var isRulingsExpanded  = true
    @State
    private var isLegalitiesExpanded  = false
    
    var body: some View {
        if !card.colors.isEmpty ||
            !card.colorIdentities.isEmpty ||
            !card.colorIndicators.isEmpty {
            DisclosureGroup("Colors", isExpanded: $isColorsExpanded) {
                if !card.colors.isEmpty {
                    ColorRowView(title: "Colors",
                                 colors: card.colors.map { $0.fragments.colorInfo })
                }
                if !card.colorIdentities.isEmpty {
                    ColorRowView(title: "Color Identities",
                                 colors: card.colorIdentities.map { $0.fragments.colorInfo })
                }
                if !card.colorIndicators.isEmpty {
                    ColorRowView(title: "Color Indicators",
                                 colors: card.colorIndicators.map { $0.fragments.colorInfo })
                }
            }
        }
        
        if let rulings = card.rulings,
            !rulings.isEmpty {
            DisclosureGroup("Rulings", isExpanded: $isRulingsExpanded) {
                ForEach(rulings, id: \.id) { ruling in
                    LabeledContent {
                        AttributedText(
                            addColor(to: NSAttributedString(symbol: ruling.text,
                                                            pointSize: 16),
                                     colorScheme: colorScheme)
                        )
                    } label: {
                        Text(ruling.datePublished)
                    }
                    .labeledContentStyle(.vertical)
                }
            }
        }

        DisclosureGroup("Legalities", isExpanded: $isLegalitiesExpanded) {
            ForEach(card.formatLegalities, id: \.self) { formatLegality in
                LabeledContent {
                    Text(formatLegality.legality.name)
                } label: {
                    Text(formatLegality.format.name)
                }
            }
        }
    }
}

// MARK: - ColorRowView

struct ColorRowView: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var colors: [ColorInfo]?
    private var colorSymbols: String?
    
    init(title: String, colors: [ColorInfo]?) {
        self.title = title
        self.colors = colors
        
        if let colors = colors {
            colorSymbols = colors.map{ "{CI_\($0.symbol)}" }.joined(separator: "")
        } else {
            colorSymbols = String.emdash
        }
    }
    
    var body: some View {
        LabeledContent {
            if let colorSymbols = colorSymbols {
                AttributedText(
                    addColor(to: NSAttributedString(symbol: colorSymbols,
                                                    pointSize: 16),
                             colorScheme: colorScheme)
                )
                .multilineTextAlignment(.trailing)
            }
        } label: {
            Text(title)
        }
    }
}

