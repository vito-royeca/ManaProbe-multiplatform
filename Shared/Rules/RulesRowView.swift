//
//  RulesRowView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/21/26.
//

import SwiftUI

struct RulesRowView: View {
    @State
    var title: String
    @State
    var contents: String
    
    var body: some View {
        LabeledContent {
            AttributedText(
                NSAttributedString(symbol: contents,
                                   pointSize: 16)
            )
        } label: {
            Text(title)
        }
        .labeledContentStyle(.vertical)
    }
}

#Preview {
    RulesRowView(title: "LLanowar Elves", contents: "{T}: Add {G}.")
}
