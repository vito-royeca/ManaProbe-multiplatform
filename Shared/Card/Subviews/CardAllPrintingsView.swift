//
//  CardAllPrintingsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/16/26.
//

import SwiftUI
import ManaKit

struct CardAllPrintingsView: View {
    // MARK: - Variables
    
    @State
    private var viewModel: CardAllPrintingsViewModel

    // MARK: - Initializers
    
    init(card: InnerCardInfo) {
        let model = CardAllPrintingsViewModel(card: card)
        _viewModel = State(wrappedValue: model)
    }

    // MARK: - UI

    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        CardsView(delegate: viewModel)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle("All Printings")
            .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Previews

#Preview {
    AsyncPreviewView { data in
        NavigationView {
            CardAllPrintingsView(card: data.fragments.innerCardInfo)
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "lea_en_98")
    }
}
