//
//  CardsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/19/23.
//

import SwiftUI
import ManaKit

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

    init(viewModel: CardsViewModel,
         @ViewBuilder header: @escaping () -> Header = { EmptyView() }) {
        self.viewModel = viewModel
        self.header = header
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
    let viewModel = CardsViewModel()
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    NavigationStack {
        CardsView(viewModel: viewModel)
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
