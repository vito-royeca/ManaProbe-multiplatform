//
//  FavoritesView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/26/26.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(AuthModel.self)
    private var authModel

    @Environment(FavoritesViewModel.self)
    private var viewModel
    
    var body: some View {
        contentView
            .onAppear {
                if authModel.user == nil {
                    authModel.showAccountView.toggle()
                }
            }
    }
    
    private var contentView: some View {
        CardsView(viewModel: viewModel)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle(MyTabs.favorites.name)
    }
}

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    FavoritesView()
        .environment(authModel)
        .environment(favoritesModel)
}
