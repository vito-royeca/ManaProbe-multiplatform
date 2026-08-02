//
//  SetView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 3/21/22.
//

import SwiftUI
import ManaKit

struct SetView: View {
    // MARK: - Variables

//    @Environment(\.horizontalSizeClass)
//    private var horizontalSizeClass
    
    @State
    private var viewModel: SetViewModel
    @State
    private var showingSort = false

    // MARK: - Initializers

    init(setID: String, languageID: String) {
        let model = SetViewModel(setID: setID,
                                 languageID: languageID)
        _viewModel = State(wrappedValue: model)
    }
    
    init(set: SetQuery.Data.Set) {
        let model = SetViewModel(set: set)
        _viewModel = State(wrappedValue: model)
    }

    // MARK: - UI

    var body: some View {
        contentView
            .task {
                await viewModel.fetchData()
            }
    }
    
    private var contentView: some View {
        CardsView(viewModel: viewModel) {
            SetHeaderView(viewModel: viewModel)
                .listRowSeparator(.hidden)
                .padding(5)
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(viewModel.set?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    AsyncPreviewView { data in
        NavigationStack {
            SetView(set: data)
        }
    } fetchData: {
        try await ManaKitUtilities.shared.set(fetchRemote: false,
                                              setID: "ecl",
                                              languageID: "en")
    }
    .environment(authModel)
    .environment(favoritesModel)
}

