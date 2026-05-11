//
//  FavoritesView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/26/26.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesViewModel.self)
    private var viewModel
    
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        CardsView(delegate: viewModel)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle(MyTabs.favorites.name)
    }
}

//extension FavoritesView {
//    func fetchData() {
//        Task {
//            await viewModel.fetchData()
//        }
//    }
//}

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    FavoritesView()
        .environment(authModel)
        .environment(favoritesModel)
}
