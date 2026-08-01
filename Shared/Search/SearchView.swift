//
//  SearchView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 7/30/26.
//

import SwiftUI
import ManaKit

struct SearchView: View {
    @State
    private var viewModel = SearchViewModel()

    var body: some View {
        contentView
            .onSubmit(of: .search) {
                fetchData()
            }
    }
    
    private var contentView: some View {
        CardsView(viewModel: viewModel)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle(Tabs.search.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query,
                        placement: .automatic,
                        prompt: "Search for cards")
            .tabViewSearchActivation(.searchTabSelection)
    }
}

// MARK: - Methods

extension SearchView {
    func fetchData() -> Void {
        Task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    let searchModel = SearchViewModel()
    
    AsyncPreviewView { data in
        NavigationStack {
            SearchView()
        }
    } fetchData: {
        try await ManaKitUtilities.shared.search(fetchRemote: false,
                                                 query: "angel")
    }
    .environment(authModel)
    .environment(favoritesModel)
}
