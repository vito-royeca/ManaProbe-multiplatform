//
//  CardOtherInfoView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/8/23.
//

import SwiftUI
import ManaKit

struct CardOtherInfoView: View {
    let card: CardCompleteInfo
    
    @State
    private var isFrameEffectsExpanded  = true
    
    var body: some View {
        Group {
            LabeledContent {
                Text("#\(card.collectorNumber ?? String.emdash)")
            } label: {
                Text("Collector Number")
            }

            if let language = card.language {
                LabeledContent {
                    Text(language.name)
                } label: {
                    Text("Language")
                }
            }
            
            if let layout = card.layout {
                LabeledContent {
                    Text(layout.name)
                } label: {
                    Text("Layout")
                }
            }

            if let releaseDate = card.releasedAt {
                LabeledContent {
                    Text(releaseDate)
                } label: {
                    Text("Release Date")
                }
            }
            
            if let watermark = card.watermark {
                LabeledContent {
                    Text(watermark.name)
                } label: {
                    Text("Watermark")
                }
            }
            
            if let frame = card.frame {
                LabeledContent {
                    Text(frame.name)
                } label: {
                    Text("Frame")
                }
            }

            if !card.frameEffects.isEmpty {
                DisclosureGroup("Frame Effects", isExpanded: $isFrameEffectsExpanded) {
                    ForEach(card.frameEffects, id: \.self) { frameEffect in
                        LabeledContent {
                            Text(frameEffect.description ?? "")
                        } label: {
                            Text(frameEffect.name)
                        }
                    }
                }
            }
            
            LabeledContent {
                Text("\(card.isDigital ?? false ? "True" : "False")")
            } label: {
                Text("Digital")
            }
            LabeledContent {
                Text("\(card.isReserved ?? false ? "True" : "False")")
            } label: {
                Text("Reserved")
            }
        }
    }
}

