//
//  CardAllPrintingsView.swift
//  ManaGuide
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
        Group {
            if viewModel.isBusy {
                BusyView()
            } else if viewModel.isFailed {
                ErrorView {
                    fetchData()
                } cancelAction: {
                    viewModel.isBusy = false
                }
            } else {
                contentView
            }
        }
        .task {
            fetchData()
        }
    }
    
    private var contentView: some View {
        CardsView(delegate: viewModel)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle("All Printings")
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension CardAllPrintingsView {
    func fetchData() {
        Task {
            await viewModel.fetchData()
        }
    }
}

// MARK: - Previews

#Preview {
    AsyncPreviewView { data in
        NavigationView {
            if let data = data {
                CardAllPrintingsView(card: data.fragments.innerCardInfo)
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(id: "lea_en_98")
    }
}
