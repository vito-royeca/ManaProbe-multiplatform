//
//  CardsListView.swift
//  ManaGuide (iOS)
//
//  Created by Vito Royeca on 11/19/23.
//

import SwiftUI
import ManaKit

//extension InnerCardInfo: @retroactive Identifiable {
//    public var id: String { __data["id"] }
//}

struct CardListViewID: Identifiable {
    var id: String
}

struct CardsListView<Header: View>: View {
    // MARK: - Variables

    @Environment(CardsViewModel.self)
    private var viewModel: CardsViewModel
    
    @Environment(AuthModel.self)
    private var authModel
    
    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel

    private var header: Header

    @State
    private var selectedCard: CardListViewID? = nil
    
    // MARK: - Initializers

    init(@ViewBuilder headerBuilder: () -> Header) {
        header = headerBuilder()
    }
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        List {
            header
                .listRowSeparator(.hidden)

            ForEach(viewModel.cardSections, id: \.self) { section in
                if let cards = viewModel.cards[section] {
                    Section(header: Text(section)) {
                        ForEach(cards, id: \.self) { card in
                            let innerCardInfo = card.fragments.innerCardInfo
                            let cardArray = CardArray(selectedCard: innerCardInfo,
                                                      cards: viewModel.cards)
                            let route = CardRoute.detail(cardArray: cardArray)
                            NavigationLink(value: route) {
                                CardListItemView(card: innerCardInfo)
                                    .toolbar(.hidden, for: .tabBar)
                                    .swipeActions(allowsFullSwipe: false) {
                                        swipeActions(for: card)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .sheet(item: $selectedCard) { id in
            if let card = viewModel.cards.values.flatMap(\.self).first(where: { $0.id == id.id }) {
                CreateCollectionView(card: card.fragments.innerCardInfo)
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
    func swipeActions(for card: CardBasicInfo) -> some View {
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
            handleCollections(card: card)
        } label: {
            Image(systemName: "folder.badge.plus")
        }
        .tint(.accentColor)
    }
    
    func handleCollections(card: CardBasicInfo) {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            selectedCard = CardListViewID(id: card.id)
        }
    }

    func handleFavorite(card: CardBasicInfo) {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            Task {
                try await favoritesViewModel.createOrDelete(card: card)
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

