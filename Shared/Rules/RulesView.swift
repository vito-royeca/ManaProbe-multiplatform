//
//  RulesView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/20/26.
//

import SwiftUI
import ManaKit

struct RulesView: View {
    // MARK: - Variables
    
    @State
    private var viewModel: RulesViewModel

    // MARK: - Initializers

    init(rule: RuleBasicInfo? = nil) {
        let model = RulesViewModel(rule: rule)
        _viewModel = State(wrappedValue: model)
    }
    
    init(glossaryIndex: GlossaryIndex? = nil) {
        let model = RulesViewModel(glossaryIndex: glossaryIndex)
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
        .onChange(of: viewModel.query) {
            filterData()
        }
        .onSubmit(of: .search) {
            fetchData()
        }
        .task {
            fetchData()
        }
    }
    
    // MARK: - Private variables
    
    private var contentView: some View {
        Group {
            if viewModel.searchResults.isEmpty {
                if let _ = viewModel.rule {
                    rulesView
                } else {
                    glossaryView
                }
            } else {
                searchResultsView
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            AccountToolbar(placement: .topBarTrailing)
        }
        .searchable(text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search the Comprehensive Rules")
        .refreshable {
            reloadData()
        }
    }
    
    private var rulesView: some View {
        List {
            if viewModel.rules.isEmpty {
                RulesRowView(term: viewModel.rule?.term ?? "",
                             definition: viewModel.rule?.definition ?? "")
            } else {
                ForEach(viewModel.rules, id: \.self) { child in
                    let children = child.children ?? [RuleInfo.Child]()
                    
                    if children.count == 1 {
                        RulesRowView(term: child.children?[0].term ?? "",
                                     definition: child.children?[0].definition ?? "")
                    } else {
                        ForEach(children, id: \.self) { innerChild in
                            if (innerChild.children ?? []).isEmpty {
                                RulesRowView(term: innerChild.term ?? "",
                                             definition: innerChild.definition ?? "")
                            } else {
                                NavigationLink(value: innerChild) {
                                    Text(innerChild.titleString)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var glossaryView: some View {
        List {
            ForEach(viewModel.rules, id: \.self) { rule in
                if rule.term == "Glossary" {
                    ExpandableOutlineGroup(node: viewModel.createGlossaryTree(),
                                           childKeyPath: \.children,
                                           isExpanded: false) { tree in
                        Group {
                            if tree.id == "0" {
                                Text(tree.value)
                            } else {
                                NavigationLink(value: GlossaryIndex(rawValue: tree.value)) {
                                    Text(tree.value)
                                }
                            }
                        }
                    }
                } else {
                    if let _ = rule.termSection {
                        RulesRowView(term: rule.term ?? "",
                                     definition: rule.definition ?? "")
                    } else {
                        NavigationLink(value: rule) {
                            Text(rule.titleString)
                        }
                    }
                }
            }
        }
    }

    private var searchResultsView: some View {
        List {
            ForEach(viewModel.searchResults, id: \.self) { result in
                RulesRowView(term: result.term ?? "",
                             definition: result.definition ?? "")
            }
        }
    }
}

// MARK: - Methods

extension RulesView {
    func fetchData() -> Void {
        Task {
            await viewModel.fetchData()
        }
    }

    func filterData() {
        if viewModel.query.isEmpty {
            viewModel.searchResults.removeAll()
        }
    }
    
    func reloadData() -> Void {
        viewModel.query = ""
        fetchData()
    }
}


#Preview {
    NavigationStack {
        RulesView(rule: nil)
            .environment(AuthModel())
    }
}
