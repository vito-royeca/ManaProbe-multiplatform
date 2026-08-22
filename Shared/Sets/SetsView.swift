//
//  SetsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 3/21/22.
//

import SwiftUI
import ManaKit

struct SetsView: View {
    // MARK: - Variables
    
    @State
    private var viewModel = SetsViewModel()

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
        .onChange(of: viewModel.query) {
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
            if viewModel.query.isEmpty {
                ForEach(viewModel.sections, id: \.self) { section in
                    Section(header: Text(section)) {
                        ForEach(viewModel.sets[section] ?? [], id: \.self) { set in
                            ExpandableOutlineGroup(node: set,
                                                   childKeyPath: \.children,
                                                   isExpanded: true) { set in
                                NavigationLink(value: set.value) {
                                    SetsRowView(set: set.value)
                                        .tint(.primary)
                                }
                            }
                        }
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
        .navigationBarTitleDisplayMode(.large)
        .modifier(SectionIndex(sections: viewModel.sections,
                               sectionIndexTitles: viewModel.sectionIndexTitles))
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                SetsSorterMenuView(viewModel: viewModel)
            }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            AccountToolbar(placement: .topBarTrailing)
        }
        .searchable(text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search for Magic sets")
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
        viewModel.filterData(query: viewModel.query)
    }
    
    func reloadData() -> Void {
        viewModel.query = ""
        Task {
            await viewModel.reloadData()
        }
    }
}

// MARK: - Previews

//#Preview(traits: .landscapeRight) {
#Preview {
    AsyncPreviewView { data in
        SetsView(sectionedSets: data)
            .environment(AuthModel())
    } fetchData: {
        try await ManaKitUtilities.shared.sets(fetchRemote: false, type: .byYear)
    }
}
