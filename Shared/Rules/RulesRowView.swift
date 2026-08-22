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
            VStack {
                AttributedText(
                    NSAttributedString(symbol: contents,
                                       pointSize: 16)
                )
                HStack {
                    Spacer()
                    Button {
                        UIPasteboard.general.string = "\(title)\n\n\(contents)"
                    } label: {
                        Image(systemName: "document.on.document")
                    }
                    .tint(.accentColor)

                    Button {
                        // TODO: handle sharing
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .tint(.accentColor)
                }
            }
        } label: {
            Text(title)
        }
        .labeledContentStyle(.vertical)
    }
}

#Preview {
    RulesRowView(title: "LLanowar Elves", contents: "{T}: Add {G}.")
}
