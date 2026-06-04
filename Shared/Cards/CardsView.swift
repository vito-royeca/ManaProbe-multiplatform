//
//  CardsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/19/23.
//

import SwiftUI
import ManaKit

enum CardRoute: Hashable {
    case details(selectedCard: InnerCardInfo, navigator: (any CardsNavigatorDelegate)?)
    case printings(card: InnerCardInfo)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .details(let selectedCard, _):
            hasher.combine(0) // Unique seed for this case
            hasher.combine(selectedCard)
        case .printings(let value):
            hasher.combine(1) // Unique seed for this case
            hasher.combine(value)
        }
    }

    static func == (lhs: CardRoute, rhs: CardRoute) -> Bool {
        switch (lhs, rhs) {
        case (.details(let lSelectedCard, _), .details(let rSelectedCard, _)): return lSelectedCard == rSelectedCard
        case (.printings(let l), .printings(let r)): return l.id == r.id
        default: return false
        }
    }
}

struct CardsView<Header: View>: View where Header: View {
    // MARK: - Variables

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @State
    private var viewModel: CardsViewModel
    private let header: () -> Header?
    
    @AppStorage("CardsDisplay")
    var display = CardsDisplay.defaultValue
    
    // MARK: - Initializers

    init(delegate: CardsViewModelDelegate?,
         @ViewBuilder header: @escaping () -> Header = { EmptyView() }) {
        let model = CardsViewModel(delegate: delegate)
        _viewModel = State(wrappedValue: model)
        self.header = header
    }

    var body: some View {
//        Group {
//            if viewModel.isBusy {
//                BusyView()
//            } else if viewModel.isFailed {
//                ErrorView {
//                    fetchData()
//                } cancelAction: {
//                    viewModel.isFailed = false
//                }
//            } else {
                contentView
//            }
//        }
        .task {
            fetchData()
        }
    }
    
    private var contentView: some View {
        Group {
            switch display {
            case .list:
                CardsListView {
                    header()
                    displayPickerView
                }
                .environment(viewModel)
            case .grid:
                CardsGridView {
                    header()
                    displayPickerView
                }
                .environment(viewModel)
            case .charts:
                CardsChartsView {
                    header()
                    displayPickerView
                }
                .environment(viewModel)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                CardsSorterMenuView(viewModel: viewModel)
            }
        }
    }
    
    private var displayPickerView: some View {
        Picker("Display",
               selection: $display) {
            ForEach(CardsDisplay.allCases, id: \.self) { display in
                Image(systemName: display.symbol)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}

extension CardsView {
    func fetchData() {
        Task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    NavigationStack {
        CardsView(delegate: DefaultCardsViewModelDelegate())
            .navigationDestination(for: CardRoute.self) { route in
                switch route {
                case .details(let selectedCard, let navigator):
                    CardView(card: selectedCard, navigator: navigator)
                case .printings(let card):
                    CardAllPrintingsView(card: card)
                }
            }
    }
    .environment(authModel)
    .environment(favoritesModel)
}
