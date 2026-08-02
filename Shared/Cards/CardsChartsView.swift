//
//  CardsChartsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/5/26.
//

import Charts
import SwiftUI

import ManaKit

struct CardsChartsView<Header: View>: View {
    // MARK: - Variables

    @Environment(CardsViewModel.self)
    private var viewModel: CardsViewModel
    
    private var header: Header
    
    @State
    private var cardColors: [String: Color] = [:]
    @State
    private var rarityColors: [String: Color] = [:]
    
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
            
            Section() {
                colorsChartView
            } header: {
                Text("Colors")
            } footer: {
                Text("Note: some cards may have multiple colors.")
            }
            
            Section {
                raritiesChartView
            } header: {
                Text("Rarities")
            }
            
            Section {
                typesChartView
            } header: {
                Text("Types")
            }footer: {
                Text("Note: some cards may have multiple types.")
            }
        }
        .listStyle(.inset)
        .navigationLinkIndicatorVisibility(.hidden)
        .refreshable {
            reloadData()
        }
    }
    
    var colorsChartView: some View {
        Chart(viewModel.colorsChartData()) { dataPoint in
            SectorMark(angle: .value("Count", dataPoint.count))
                .foregroundStyle(by: .value("Name", dataPoint.name))
                .foregroundStyle(viewModel.color(name: dataPoint.name))
                .annotation(position: .overlay) {
                    Text("\(dataPoint.count)")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
        }
        .chartLegend(alignment: .center, spacing: 18)
        .onChange(of: viewModel.colorsChartData(), initial: true) { _, newValue in
            cardColors = Dictionary(uniqueKeysWithValues: Set(newValue).map { ($0.name, viewModel.color(name: $0.name)) })
        }
        .chartForegroundStyleScale { (name: String) in
            cardColors[name] ?? .clear
        }
        .aspectRatio(2, contentMode: .fit)
    }

    var raritiesChartView: some View {
        Chart(viewModel.raritiesChartData()) { dataPoint in
            SectorMark(angle: .value("Count", dataPoint.count))
                .foregroundStyle(by: .value("Name", dataPoint.name))
                .foregroundStyle(viewModel.color(rarity: dataPoint.name))
                .annotation(position: .overlay) {
                    Text("\(dataPoint.count)")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
        }
        .chartLegend(alignment: .center, spacing: 18)
        .onChange(of: viewModel.raritiesChartData(), initial: true) { _, newValue in
            rarityColors = Dictionary(uniqueKeysWithValues: Set(newValue).map { ($0.name, viewModel.color(rarity: $0.name)) })
        }
        .chartForegroundStyleScale { (name: String) in
            rarityColors[name] ?? .clear
        }
        .aspectRatio(2, contentMode: .fit)
    }

    var typesChartView: some View {
        Chart(viewModel.typesChartData()) { dataPoint in
            BarMark(x: .value("Count", dataPoint.count),
                    y: .value("Name", dataPoint.name))
            .annotation(position: .trailing) {
                Text(String(dataPoint.count))
            }
            .foregroundStyle(.blue)
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks { _ in
                AxisValueLabel()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension CardsChartsView {
    func reloadData() -> Void {
        Task {
            await viewModel.reloadData()
        }
    }
}

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    let model = CardsViewModel()
    
    NavigationStack {
        CardsChartsView {
            Text("Charts")
        }
        .environment(model)
    }
    .task {
        await model.fetchData()
    }
    .environment(authModel)
    .environment(favoritesModel)
}
