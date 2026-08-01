//
//  CardsGridView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/19/23.
//

import SwiftUI
import ManaKit

struct CardsGridView<Header: View>: View {
    // MARK: - Variables

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @Environment(CardsViewModel.self)
    private var viewModel: CardsViewModel
    
    @Environment(AuthModel.self)
    private var authModel
    
    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel

    private var header: Header
    
    // MARK: - Initializers

    init(@ViewBuilder headerBuilder: () -> Header) {
        header = headerBuilder()
    }

    var body: some View {
        contentView
    }
    
    var contentView: some View {
        ScrollView() {
            let count = columnCount()
            let columns = [GridItem](repeating: GridItem(.flexible()),
                                     count: count)
            header
                .padding()

            LazyVGrid(columns: columns, alignment: .leading, pinnedViews: []) {
                ForEach(viewModel.cardSections, id: \.self) { section in
                    Section(header: Text(section)) {
                        ForEach(viewModel.cards[section] ?? [], id: \.self) { card in
                            let innerCardInfo = card.fragments.innerCardInfo
                            let route = CardRoute.details(selectedCard: innerCardInfo, navigator: viewModel)
                            NavigationLink(value: route) {
                                VStack {
                                    CardGridItemView(card: innerCardInfo)
                                    Divider()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .scrollClipDisabled(true)
        .navigationLinkIndicatorVisibility(.hidden)
        .modifier(SectionIndex(sections: viewModel.cardSections,
                               sectionIndexTitles: viewModel.cardSectionIndexTitles))
        .refreshable {
            reloadData()
        }
    }
}

extension CardsGridView {
    func reloadData() -> Void {
        Task {
            await viewModel.reloadData()
        }
    }
    
    func columnCount() -> Int {
        var count = 0

        #if os(iOS)
        if horizontalSizeClass == .compact {
            count = 2
        } else {
            count = 3
        }
        #else
        count = 2
        #endif
        
        return count
    }
}

//#Preview {
//    let model = CardsViewModel()
//    
//    return CardsImageView(selectedCard: .constant(nil),
//                          cardsPerRow: .constant(0.5))
//        .environmentObject(model)
//}
