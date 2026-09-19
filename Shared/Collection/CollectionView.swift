//
//  CollectionView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/7/26.
//

import SwiftUI

struct CollectionView: View {
    @Environment(AuthModel.self)
    private var authModel

    @State
    private var viewModel: CollectionViewModel
    
    // MARK: - Initializers

    init(collection: FBCollection) {
        let model = CollectionViewModel(collection: collection)
        _viewModel = State(wrappedValue: model)
    }
    
    var body: some View {
        contentView
            .onAppear {
                if authModel.user == nil {
                    authModel.showAccountView.toggle()
                } else {
                    fetchData()
                }
            }
    }
  
    private var contentView: some View {
        CardsView(viewModel: viewModel)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle(viewModel.collection?.name ?? "")
    }
}

extension CollectionView {
    func fetchData() {
        Task {
            await viewModel.fetchData()
        }
    }
}

//#Preview {
//    CollectionView()
//}
