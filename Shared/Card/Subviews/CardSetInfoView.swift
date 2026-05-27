//
//  CardSetInfoView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 2/26/24.
//

import SwiftUI
import ManaKit

struct CardSetInfoView: View {
    let card: CardCompleteInfo
    
    var body: some View {
        LabeledContent {
            Text(card.set?.name ?? String.emdash)
        } label: {
            Text("Set")
        }
        
        LabeledContent {
            Text(card.set?.keyruneUnicode.keyrune2Unicode() ?? "e684")
                .font(Font.custom("Keyrune", size: 20))
                .foregroundColor(Color(hex: card.keyruneColor ?? "000"))
        } label: {
            Text("Set Symbol")
        }
        
        LabeledContent {
            Text(card.rarity?.name ?? String.emdash)
        } label: {
            Text("Rarity")
        }
    }
}
