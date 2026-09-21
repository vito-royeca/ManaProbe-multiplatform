//
//  CollectionHeaderView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/7/26.
//

import SwiftUI

struct CollectionHeaderView: View {
    @Binding
    var viewModel: CollectionViewModel
    
    @State
    private var isEditingPresented = false
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        displayView
            .navigationTitle(viewModel.collection?.name ?? "")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isEditingPresented) {
                EditCollectionView(viewModel: $viewModel)
            }
    }
    
    private var displayView: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack {
                    Text("\(viewModel.collection?.count ?? 0)")
                        .font(.title)
                    Text(viewModel.collection?.count ?? 0 > 1 ? "cards" : "card")
                        .font(.headline)
                }
                Spacer()
                Button("Edit") {
                    isEditingPresented.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            if let description = viewModel.collection?.description,
               !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .safeAreaInset(edge: .leading) {
                        Image(systemName: "text.document")
                    }
            }
            
            HStack {
                if let dateAdded = viewModel.collection?.dateAdded {
                    Text(dateAdded, style: .date)
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .safeAreaInset(edge: .leading) {
                            Image(systemName: "document.badge.plus")
                        }
                }
                Spacer()
                if let dateUpdated = viewModel.collection?.dateUpdated {
                    Text(dateUpdated.elapsedTime())
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .safeAreaInset(edge: .leading) {
                            Image(systemName: "document.badge.clock")
                        }
                }
            }
        }
    }
}

#Preview {
    @State
    @Previewable
    var viewModel = CollectionViewModel(collection: FBCollection(uid: "1", name: "My Magnificent Collection"))
    
    CollectionHeaderView(viewModel: $viewModel)
}
