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
//        .onChange(of: query) {
//            filterData()
//        }
//        .onSubmit(of: .search) {
//            filterData()
//        }
        .task {
            fetchData()
        }
    }
    
    // MARK: - Private variables
    
    private var contentView: some View {
        List {
            if let rule = viewModel.rule {
                if viewModel.rules.isEmpty {
                    LabeledContent {
                        Text(rule.definition ?? "")
                    } label: {
                        Text(rule.term ?? "")
                    }
                    .labeledContentStyle(.vertical)
                } else {
                    ForEach(viewModel.rules, id: \.self) { child in
                        let children = child.children ?? [RuleInfo.Child]()

                        if children.count == 1 {
                            LabeledContent {
                                Text(child.children?[0].definition ?? "")
                            } label: {
                                Text(child.children?[0].term ?? "")
                            }
                            .labeledContentStyle(.vertical)
                        } else {
                            ForEach(children, id: \.self) { innerChild in
                                if (innerChild.children ?? []).isEmpty {
                                    LabeledContent {
                                        AttributedText(
                                            NSAttributedString(symbol: innerChild.definition ?? "",
                                                               pointSize: 16)
                                        )
                                    } label: {
                                        Text(innerChild.term ?? "")
                                    }
                                    .labeledContentStyle(.vertical)
                                } else {
                                    NavigationLink(value: innerChild) {
                                        Text(innerChild.titleString)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                ForEach(viewModel.rules, id: \.self) { rule in
                    NavigationLink(value: rule) {
                        Text(rule.titleString)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            AccountToolbar(placement: .topBarTrailing)
        }
//        .searchable(text: $query,
//                    placement: .navigationBarDrawer(displayMode: .automatic),
//                    prompt: "Search for Magic sets")
//        .refreshable {
//            reloadData()
//        }
    }
}

// MARK: - Methods

extension RulesView {
    func fetchData() -> Void {
        Task {
            await viewModel.fetchData()
        }
    }

//    func filterData() {
//        viewModel.filterData(query: query)
//    }
//    
//    func reloadData() -> Void {
//        query = ""
//        Task {
//            await viewModel.reloadData()
//        }
//    }
}


#Preview {
    NavigationStack {
        RulesView()
            .environment(AuthModel())
    }
}
