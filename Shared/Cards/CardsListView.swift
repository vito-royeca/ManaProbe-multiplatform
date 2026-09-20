//
//  CardsListView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/19/23.
//

import SwiftUI
import ManaKit

struct CardsListView<Header: View>: View {
    // MARK: - Variables

    @Environment(CardsViewModel.self)
    private var viewModel
    
    @Environment(AuthModel.self)
    private var authModel
    
    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel

    private var header: Header

    @State
    private var isCollectionPresented = false
    @State
    private var isEditPresented = false
    @State
    private var isDeletePresented = false

    // MARK: - Initializers

    init(@ViewBuilder headerBuilder: () -> Header) {
        header = headerBuilder()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            contentView
                .onAppear() {
                    if let selectedCard = viewModel.selectedCard {
                        proxy.scrollTo(selectedCard.id, anchor: .top)
                    }
                }
        }
    }
    
    var contentView: some View {
        List {
            header
                .listRowSeparator(.hidden)

            ForEach(viewModel.cardSections, id: \.self) { section in
                Section(header: Text(section)) {
                    ForEach(viewModel.cards[section] ?? [], id: \.self) { card in
                        let innerCardInfo = card.fragments.innerCardInfo
                        let route = CardRoute.details(selectedCard: innerCardInfo, navigator: viewModel)
                        NavigationLink(value: route) {
                            CardListItemView(card: innerCardInfo)
                                .swipeActions(allowsFullSwipe: false) {
                                    swipeActions(card: card)
                                }
                        }
                        .buttonStyle(.plain)
                        .id(card.id)
                        
                        if let collectionViewModel = viewModel as? CollectionViewModel {
                           let items = collectionViewModel.items
                            ForEach(items.enumerated(), id: \.offset) { index,item in
                                CardListCollectionItemView(item: item)
                                    .swipeActions(allowsFullSwipe: false) {
                                        swipeActions(card: card, item: item)
                                    }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .sheet(isPresented: $isCollectionPresented) {
            if let card = viewModel.selectedCard {
                CreateCollectionView(card: card) {
                    reloadData()
                }
            } else {
                EmptyView()
            }
        }
        .modifier(SectionIndex(sections: viewModel.cardSections,
                               sectionIndexTitles: viewModel.cardSectionIndexTitles))
        .refreshable {
            reloadData()
        }
    }
}

extension CardsListView {
    func reloadData() -> Void {
        Task {
            await viewModel.reloadData()
        }
    }
}

extension CardsListView {
    @ViewBuilder
    func swipeActions(card: CardBasicInfo) -> some View {
        Button {
            handleFavorite(card: card)
        } label: {
            if favoritesViewModel.isFavorite(cardID: card.id) {
                Image(systemName: "heart.fill")
            } else {
                Image(systemName: "heart")
            }
        }
        .tint(.accentColor)
        
        Button {
            viewModel.selectedCard = card.fragments.innerCardInfo
            isCollectionPresented.toggle()
        } label: {
            Image(systemName: "folder.badge.plus")
        }
        .tint(.accentColor)
    }
    
    @ViewBuilder
    func swipeActions(card: CardBasicInfo, item: FBCollectionItem) -> some View {
        Button {
            isEditPresented.toggle()
        } label: {
            Image(systemName: "pencil")
        }
        .tint(.accentColor)

        Button {
            isDeletePresented.toggle()
        } label: {
            Image(systemName: "trash")
        }
        .tint(Color.red)
        .confirmationDialog("Delete Confirmation",
                            isPresented: $isDeletePresented,
                            titleVisibility: .visible) {
            Button("Your item in the collection will be deleted. Are you sure?") {
                handleDelete(card: card, item: item)
            }
            .tint(Color.red)
        }
                                
    }
    
    func handleFavorite(card: CardBasicInfo) {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            Task {
                do {
                    try await favoritesViewModel.createOrDelete(card: card)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func handleDelete(card: CardBasicInfo, item: FBCollectionItem) {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            if let collectionViewModel = viewModel as? CollectionViewModel,
               let itemID = item.id {
                Task {
                    do {
                        let _ = try await collectionViewModel.delete(cardID: card.id, itemID: itemID)
                        await collectionViewModel.fetchData()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

//#Preview {
//    let model = CardsViewModel()
//    
//    return CardsListView(selectedCard: .constant(nil))
//        .environmentObject(model)
//}

