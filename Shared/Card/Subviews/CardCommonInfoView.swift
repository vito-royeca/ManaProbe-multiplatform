//
//  CardCommonInfoView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/8/23.
//

import SwiftUI
import ManaKit

struct CardCommonInfoView: View {
    let card: CardBasicInfo?
    let face: InnerCardInfo?
    let artists: [CardCompleteInfo.Artist]?
    let cmc: Int?
    
    @Environment(\.colorScheme)
    private var colorScheme
    @State
    private var isArtistsExpanded = true
    private let cmcFormatter = NumberFormatter()
    
    init(card: CardBasicInfo?, face: InnerCardInfo?, artists: [CardCompleteInfo.Artist]?, cmc: Int?) {
        self.card = card
        self.face = face
        self.artists = artists
        self.cmc = cmc
        
        cmcFormatter.minimumFractionDigits = 0
        cmcFormatter.maximumFractionDigits = 2
        cmcFormatter.numberStyle = .decimal
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card?.displayName ?? face?.displayName ?? "")
                .font(Font.custom(ManaKitUtilities.Fonts.magic2015.name, size: 30))
            CardPricingInfoView(prices: card?.prices ?? face?.prices ?? [])
            Divider()
            
            LabeledContent {
                AttributedText(
                    NSAttributedString(symbol: card?.displayManaCost ?? face?.displayManaCost ?? "",
                                       pointSize: 16)
                )
                .multilineTextAlignment(.trailing)
            } label: {
                Text("Mana Cost")
            }
            
            if let cmc = cmc {
                LabeledContent {
                    Text(cmcFormatter.string(from: NSNumber(value: cmc)) ?? " ")
                } label: {
                    Text("Converted Mana Cost")
                }
            }

            if let type = card?.displayTypeLine ?? face?.displayTypeLine {
                LabeledContent {
                    Text(type)
                } label: {
                    Text("Type")
                }
            }
            
            if let printedText = card?.printedText ?? face?.printedText,
               !printedText.isEmpty {
                LabeledContent {
                    AttributedText(
                        addColor(to: NSAttributedString(symbol: printedText,
                                                        pointSize: 16),
                                 colorScheme: colorScheme)
                    )
                } label: {
                    Text("Printed Text")
                }
                .labeledContentStyle(.vertical)
            }
            
            if let oracleText = card?.oracleText ?? face?.oracleText,
               !oracleText.isEmpty {
                LabeledContent {
                    AttributedText(
                        addColor(to: NSAttributedString(symbol: oracleText,
                                                        pointSize: 16),
                                 colorScheme: colorScheme)
                    )
                } label: {
                    Text("Oracle Text")
                }
                .labeledContentStyle(.vertical)
            }
            
            if let flavorText = card?.flavorText ?? face?.flavorText,
               !flavorText.isEmpty {
                LabeledContent {
                    Text(flavorText)
                        .italic()
                } label: {
                    Text("Flavor Text")
                }
                .labeledContentStyle(.vertical)
            }
            
            if let displayPowerToughness = card?.displayPowerToughness ?? face?.displayPowerToughness {
                LabeledContent {
                    Text(displayPowerToughness)
                } label: {
                    Text("Power/Toughness")
                }
            }
            
            if let loyalty = card?.loyalty ?? face?.loyalty,
               !loyalty.isEmpty {
                LabeledContent {
                    Text(loyalty)
                } label: {
                    Text("Loyalty")
                }
            }

            if let artists = artists {
                if artists.count > 1 {
                    DisclosureGroup("Artists",
                                    isExpanded: $isArtistsExpanded) {
                        ForEach(artists, id: \.self) { artist in
                            Text(artist.name)
                        }
                    }
                } else {
                    LabeledContent {
                        Text(artists.first?.name ?? String.emdash)
                    } label: {
                        Text("Artist")
                    }
                }
            }
        }
    }
}
