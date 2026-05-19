//
//  SetsView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 3/21/22.
//  Copyright © 2022 Jovito Royeca. All rights reserved.
//

import SwiftUI
import ManaKit

struct SetsView: View {
    // MARK: - Variables
    
    @State
    private var viewModel = SetsViewModel()
    @State
    private var showingSort = false
    @State
    private var query = ""

    // MARK: Initializers
    init() {
        
    }

    init(sectionedSets: SectionedSets) {
        let model = SetsViewModel(sectionedSets: sectionedSets)
        _viewModel = State(wrappedValue: model)
    }
    
    // MARK: - UI
    
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
        .onChange(of: query) {
            filterData()
        }
        .onSubmit(of: .search) {
            filterData()
        }
        .task {
            fetchData()
        }
    }
    
    // MARK: - Private variables
    
    private var contentView: some View {
        List {
            if query.isEmpty {
                ForEach(viewModel.sections, id: \.self) { section in
                    if let sets = viewModel.sets[section] {
                        Section(header: Text(section)) {
                            OutlineGroup(sets,
                                         id: \.id,
                                         children: \.children) { set in
                                NavigationLink(value: set.value) {
                                    SetsRowView(set: set.value)
                                        .tint(.primary)
                                }
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
            } else {
                ForEach(viewModel.filteredSets, id: \.self) { set in
                    NavigationLink(value: set.value) {
                        SetsRowView(set: set.value)
                            .tint(.primary)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(Tabs.sets.name)
        .navigationBarTitleDisplayMode(.inline)
        .modifier(SectionIndex(sections: viewModel.sections,
                               sectionIndexTitles: viewModel.sectionIndexTitles))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                SetsSorterMenuView(viewModel: viewModel)
            }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
            }
            AccountToolbar(placement: .topBarTrailing)
        }
        .searchable(text: $query,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search for Magic sets...")
        .refreshable {
            reloadData()
        }
    }
}

// MARK: - Methods

extension SetsView {
    func fetchData() -> Void {
        Task {
            await viewModel.fetchData()
        }
    }

    func filterData() {
        viewModel.filterData(query: query)
    }
    
    func reloadData() -> Void {
        query = ""
        Task {
            await viewModel.reloadData()
        }
    }
}

// MARK: - Previews

//#Preview(traits: .landscapeRight) {
#Preview {
    AsyncPreviewView { data in
        Group {
            if let data = data {
                SetsView(sectionedSets: data)
            } else {
                Text("Can't parse")
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.sets(fetchRemote: false, type: .byYear)
    }
}
