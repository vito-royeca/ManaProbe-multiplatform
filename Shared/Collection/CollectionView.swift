//
//  CollectionView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 5/7/26.
//

import SwiftUI

struct CollectionView: View {
    @State
    private var viewModel: CollectionViewModel
    
    // MARK: - Initializers

    init(collection: FBCollection) {
        let model = CollectionViewModel(collection: collection)
        _viewModel = State(wrappedValue: model)
    }
    
    var body: some View {
        Group {
            if viewModel.isBusy {
                BusyView()
            } else if viewModel.isFailed {
                ErrorView {
                    fetchData()
                } cancelAction: {
                    viewModel.isFailed = false
                }
            } else {
                contentView
            }
        }
        .task {
            fetchData()
        }
    }
  
    private var headerView: some View {
        VStack {
            if let collection = viewModel.collection {
                Text(collection.name)
                    .font(.title)
            }
        }
    }
    
    private var contentView: some View {
        List {
            headerView
                .listRowSeparator(.hidden)

//            ForEach(viewModel.cardSections, id: \.self) { section in
//                if let cards = viewModel.cards[section] {
//                    Section(header: Text(section)) {
//                        ForEach(cards, id: \.self) { card in
//                            let innerCardInfo = card.fragments.innerCardInfo
//                            let cardArray = CardArray(selectedCard: innerCardInfo,
//                                                      cards: viewModel.cards)
//                            let route = CardRoute.detail(cardArray: cardArray)
//                            NavigationLink(value: route) {
//                                CardListItemView(card: innerCardInfo)
//                                    .swipeActions(allowsFullSwipe: false) {
//                                        swipeActions(for: card)
//                                    }
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                } else {
//                    EmptyView()
//                }
//            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
//        .sheet(item: $selectedCard) { id in
//            if let card = viewModel.cards.values.flatMap(\.self).first(where: { $0.id == id.id }) {
//                CreateCollectionView(card: card.fragments.innerCardInfo)
//            } else {
//                EmptyView()
//            }
//        }
//        .modifier(SectionIndex(sections: viewModel.cardSections,
//                               sectionIndexTitles: viewModel.cardSectionIndexTitles))
//        .refreshable {
//            reloadData()
//        }
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
