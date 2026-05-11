//
//  NewsView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 3/30/22.
//

import SwiftUI
import BetterSafariView
import FeedKit

struct NewsView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @State
    private var viewModel = NewsViewModel()
    @State
    private var currentFeed: FeedItem? = nil
    
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
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    horizontalView
                } else {
                    verticalView
                }
                #else
                verticalView
                #endif
            }
        }
        .task {
            //            fetchData()
        }
    }

    var horizontalView: some View {
        List {
            let keys = Array(viewModel.feeds.keys).sorted()
            ForEach(keys, id: \.self) { key in
                Section(header: Text(key)) {
                    ForEach(viewModel.feeds[key] ?? [], id: \.self) { feed in
                        let tap = TapGesture()
                            .onEnded { _ in
                                currentFeed = feed
                            }
                        
                        NewsFeedRowView(item: feed,
                                        style: .horizontal)
                            .gesture(tap)
                            .listRowSeparator(.hidden)
                    }

                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text(Tabs.news.name))
        .toolbar {
            AccountToolbar(placement: .topBarTrailing)
        }
        .safariView(item: $currentFeed) { currentFeed in
            return createSafariView(urlString: currentFeed.url)
        }
        .refreshable {
            fetchData()
        }
    }
    
    var verticalView: some View {
        ScrollView() {
            let columns = [GridItem](repeating: GridItem(.flexible()),
                                     count: 2)
            let keys = Array(viewModel.feeds.keys).sorted()
            
            LazyVGrid(columns: columns, pinnedViews: []) {
                ForEach(keys, id: \.self) { key in
                    if let feeds = viewModel.feeds[key] {
                        Section(header: Text(key)) {
                            ForEach(feeds, id: \.self) { feed in
                                let tap = TapGesture()
                                    .onEnded { _ in
                                        currentFeed = feed
                                    }
                                
                                NewsFeedRowView(item: feed,
                                                style: .vertical)
                                    .gesture(tap)
                                    .listRowSeparator(.hidden)
                                    .padding(.bottom)
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .padding()
            .navigationTitle(Text(Tabs.news.name))
            .toolbar {
                AccountToolbar(placement: .topBarTrailing)
            }
            .safariView(item: $currentFeed) { currentFeed in
                return createSafariView(urlString: currentFeed.url)
            }
            .refreshable {
                fetchData()
            }
        }
    }
    
    func createSafariView(urlString: String?) -> SafariView {
        let url = URL(string: urlString ?? "")
        let config = SafariView.Configuration(entersReaderIfAvailable: true,
                                              barCollapsingEnabled: true)
        return SafariView(url: url!,
                          configuration: config)
            .preferredBarAccentColor(.clear)
            .preferredControlAccentColor(.accentColor)
            .dismissButtonStyle(.close)
    }
}

// MARK: - Methods

extension NewsView {
    func fetchData() -> Void {
        Task {
            await viewModel.fetchData()
        }
    }
}
// MARK: - Previous

#Preview {
    return NavigationView {
        NewsView()
    }
}
