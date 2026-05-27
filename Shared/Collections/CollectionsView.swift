//
//  CollectionsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/3/26.
//

import SwiftUI

struct CollectionsView: View {
    @State
    private var viewModel = CollectionsViewModel()
    
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
    
    var contentView: some View {
        List {
            ForEach(viewModel.collections) { collection in
                NavigationLink(value: collection) {
                    CollectionsRowView(collection: collection)
                }
            }
        }
        .listStyle(.plain)
//        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(Text(MyTabs.collections.name))
    }
}

// MARK: - Methods

extension CollectionsView {
    func fetchData() -> Void {
        Task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    CollectionsView()
}
