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
                                    swipeActions(for: card)
                                }
                        }
                        .buttonStyle(.plain)
                        .id(card.id)
                        
                        if let collectionViewModel = viewModel as? CollectionViewModel {
                            let items = collectionViewModel.collection?.cards.filter { $0.cardID == card.id }
                                .first?.items ?? []
                            ForEach(items.enumerated(), id: \.offset) { index,item in
                                XCollectionListItemView(item: item)
                                .swipeActions(allowsFullSwipe: false) {
                                    swipeActions(for: card, and: item)
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
                CreateCollectionView(card: card)
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
    
    @ViewBuilder
    func swipeActions(for card: CardBasicInfo, and item: FBCardItem) -> some View {
        Button(role: .destructive,
               action: {
            
        }, label: {
            Image(systemName: "trash")
        })
        
        Button(action: {
            
        }, label: {
            Image(systemName: "pencil")
        })
        .tint(.accentColor)
    }
    
    func handleCollections(card: CardBasicInfo) {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            viewModel.selectedCard = card.fragments.innerCardInfo
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

struct XCollectionListItemView: View {
    
    @State
    var item: FBCardItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.condition.description)
                Spacer()
                Text(item.isFoil ? "Foil" : "Normal")
                    .foregroundColor(item.isFoil ? Color.green : Color.blue)
                    .multilineTextAlignment(.trailing)
                
            }
            if !item.notes.isEmpty {
                Text(item.notes)
                    .font(.footnote)
            }
            
            if let dateUpdated = item.dateUpdated {
                HStack {
                    Spacer()
                    Text(dateUpdated.formatted(.dateTime))
                        .multilineTextAlignment(.trailing)
                        .font(.footnote)
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

