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
    private var isCreateCollectionPresented = false
    @State
    private var isEditCollectionPresented = false
    @State
    private var isDeleteCollectionPresented = false

    // MARK: - Initializers

    init(@ViewBuilder headerBuilder: () -> Header) {
        header = headerBuilder()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            contentView
                .onAppear() {
                    if let selectedCard = viewModel.selectedCard {
                        withAnimation {
                            proxy.scrollTo(selectedCard.id, anchor: .top)
                        }
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
                        cardListItem(for: card)
                        collectionListItem(for: card)
                    }
                    .confirmationDialog("Delete Confirmation",
                                        isPresented: $isDeleteCollectionPresented,
                                        titleVisibility: .visible) {
                                            Button(role: .destructive,
                                                   action: {
                                                withAnimation {
                                                    handleDelete()
                                                }
                                            }, label: {
                                                Text("OK")
                                            })
                                            Button("Cancel", role: .cancel) { }
                                        }
                                        message: {
                                            Text("This item in the collection will be deleted. Are you sure?")
                                        }
                }
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .sheet(isPresented: $isCreateCollectionPresented) {
            createCollectionSheet()
        }
        .sheet(isPresented: $isEditCollectionPresented) {
            editCollectionSheet()
        }
        .modifier(SectionIndex(sections: viewModel.cardSections,
                               sectionIndexTitles: viewModel.cardSectionIndexTitles))
        .refreshable {
            reloadData()
        }
    }
}

private extension CardsListView {
    func reloadData() -> Void {
        Task {
            await viewModel.reloadData()
        }
    }
}

private extension CardsListView {
    @ViewBuilder
    func cardListItem(for card: CardBasicInfo) -> some View {
        let innerCardInfo = card.fragments.innerCardInfo
        let route = CardRoute.details(selectedCard: innerCardInfo,
                                      navigator: viewModel)
        NavigationLink(value: route) {
            CardListItemView(card: innerCardInfo)
                .swipeActions(allowsFullSwipe: false) {
                    swipeActions(card: card)
                }
        }
        .buttonStyle(.plain)
        .id(card.id)
    }
    
    @ViewBuilder
    func collectionListItem(for card: CardBasicInfo) -> some View {
        if let collectionViewModel = viewModel as? CollectionViewModel {
            let items = collectionViewModel.items
            ForEach((items[card.id] ?? []).enumerated(), id: \.offset) { index,item in
                CardListCollectionItemView(item: item, index: index+1)
                    .swipeActions(allowsFullSwipe: true) {
                        swipeActions(card: card, item: item)
                    }
            }
        }
    }
}

private extension CardsListView {
    @ViewBuilder
    func createCollectionSheet() -> some View {
        if let card = viewModel.selectedCard {
            CreateCollectionView(card: card) {
                reloadData()
            }
        }
    }
    
    @ViewBuilder
    func editCollectionSheet() -> some View {
        if let card = (viewModel as? CollectionViewModel)?.selectedCardForEdit,
            let item = (viewModel as? CollectionViewModel)?.selectedItemForEdit {
            EditCollectionItemView(card: card.fragments.innerCardInfo,
                                   item: item,
                                   viewModel: (viewModel as? CollectionViewModel)!) {
                (viewModel as? CollectionViewModel)?.selectedCardForEdit = nil
                (viewModel as? CollectionViewModel)?.selectedItemForEdit = nil
                reloadData()
            }
        }
    }
}

private extension CardsListView {
    @ViewBuilder
    func swipeActions(card: CardBasicInfo) -> some View {
        Button {
            (viewModel as? CollectionViewModel)?.selectedCardForEdit = card
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
            isCreateCollectionPresented.toggle()
        } label: {
            Image(systemName: "folder.badge.plus")
        }
        .tint(.accentColor)
    }
    
    @ViewBuilder
    func swipeActions(card: CardBasicInfo, item: FBCollectionItem) -> some View {
        Button {
            (viewModel as? CollectionViewModel)?.selectedCardForEdit = card
            (viewModel as? CollectionViewModel)?.selectedItemForEdit = item
            isEditCollectionPresented.toggle()
        } label: {
            Image(systemName: "pencil")
        }
        .tint(.accentColor)

        Button(role: .destructive,
               action: {
                   (viewModel as? CollectionViewModel)?.selectedCardForEdit = card
                   (viewModel as? CollectionViewModel)?.selectedItemForEdit = item
                   isDeleteCollectionPresented.toggle()
               },
               label: {
                   Image(systemName: "trash")
               })
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
    
    func handleDelete() {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            if let item = (viewModel as? CollectionViewModel)?.selectedItemForEdit {
                Task {
                    do {
                        try await (viewModel as? CollectionViewModel)?.delete(item: item)
                        await viewModel.reloadData()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview {
    let model = CardsViewModel()
    
    return CardsListView {
        Text("Header")
    }
        .environment(model)
}

