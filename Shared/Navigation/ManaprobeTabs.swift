//
//  ManaprobeTabs.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/12/26.
//

import SwiftUI

import ManaKit

struct ManaprobeTabs: View {
    /// Keep track of tab view customizations in app storage.
    #if !os(macOS) && !os(tvOS)
    @AppStorage("sidebarCustomizations")
    var tabViewCustomization: TabViewCustomization
    #endif

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @Namespace
    private var namespace
    
    @State
    private var selectedTab: Tabs = .news
    
    @State
    private var query = ""
    
    @State
    private var authModel = AuthModel()
    
    @State
    private var favoritesModel = FavoritesViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            // News
            Tab(Tabs.news.name,
                systemImage: Tabs.news.symbol,
                value: .news) {
                newsView
            }
            .customizationID(Tabs.news.customizationID)
            
            // Sets
            Tab(Tabs.sets.name,
                systemImage: Tabs.sets.symbol,
                value: .sets) {
                setsView
            }
            #if !os(macOS) && !os(tvOS)
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)
            #endif
            
            // Scanner
            Tab(Tabs.scanner.name,
                systemImage: Tabs.scanner.symbol,
                value: .scanner) {
                scannerView
            }
            .customizationID(Tabs.scanner.customizationID)
            
            // Search
            Tab(value: .search,
                role: .search) {
                searchView
            }
            .customizationID(Tabs.search.customizationID)
            #if !os(macOS) && !os(tvOS)
            .customizationBehavior(.disabled, for: .sidebar, .tabBar)
            #endif
            
            Tab(Tabs.more.name,
                systemImage: Tabs.more.symbol,
                value: .more) {
                moreView
            }
            .customizationID(Tabs.more.customizationID)

            // More
//                TabSection {
//                    // Favorites
//                    Tab(MyTabs.favorites.name,
//                        systemImage: MyTabs.favorites.symbol,
//                        value: Tabs.my(.favorites)) {
//                        favoritesView
//                    }
//                    .customizationID(MyTabs.favorites.customizationID)
//
//                    // Collections
//                    Tab(MyTabs.collections.name,
//                        systemImage: MyTabs.collections.symbol,
//                        value: Tabs.my(.collections)) {
//                        collectionsView
//                    }
//                    .customizationID(MyTabs.collections.customizationID)
//
//                    // Decks
//                    Tab(MyTabs.decks.name,
//                        systemImage: MyTabs.decks.symbol,
//                        value: Tabs.my(.decks)) {
//                        decksView
//                    }
//                    .customizationID(MyTabs.decks.customizationID)
//                } header: {
//                    Label("My", systemImage: "folder")
//                }
        }
        .tabViewStyle(.sidebarAdaptable)
        //        .tabBarMinimizeBehavior(.onScrollDown)
        
#if !os(macOS) && !os(tvOS)
        .tabViewCustomization($tabViewCustomization)
#endif
        
        .sheet(isPresented: $authModel.showAccountView) {
            accountView
        }
        .onChange(of: authModel.authService.authenticationState) { _, newValue in
            Task {
                await authModel.handleState(state: newValue)
                await favoritesModel.handleState(state: newValue)
            }
        }
        .environment(authModel)
        .environment(favoritesModel)
    }
    
    // MARK: - tabs
    
    var newsView: some View {
        NavigationStack {
            NewsView()
        }
    }
    
    var setsView: some View {
        NavigationStack {
            SetsView()
                .navigationDestination(for: SetBasicInfo.self) { set in
                    SetView(setID: set.id, languageID: languageID(for: set))
                }
                .navigationDestination(for: CardRoute.self) { route in
                    switch route {
                    case .detail(let cardArray):
                        CardView(cardArray: cardArray)
                    case .printings(let card):
                        CardAllPrintingsView(card: card)
                    }
                }
        }
    }
    
    var scannerView: some View {
        NavigationStack {
            Text(Tabs.scanner.name)
        }
    }
    
    var searchView: some View {
        NavigationStack {
            Text(Tabs.search.name)
        }
        .searchable(text: $query)
    }

    var moreView: some View {
        NavigationStack {
            MoreView()
                .navigationDestination(for: String.self) { string in
                    switch string {
                    case "Favorites":
                        favoritesView
                    case "Collections":
                        collectionsView
                    case "Decks":
                        Text("Decks")
                    default:
                        Text("Not Implemented")
                    }
                }
        }
    }

    var favoritesView: some View {
        FavoritesView()
            .navigationDestination(for: CardRoute.self) { route in
                switch route {
                case .detail(let cardArray):
                    CardView(cardArray: cardArray)
                case .printings(let card):
                    CardAllPrintingsView(card: card)
                }
            }
    }
    
    var collectionsView: some View {
        CollectionsView()
            .navigationDestination(for: CardRoute.self) { route in
                switch route {
                case .detail(let cardArray):
                    CardView(cardArray: cardArray)
                case .printings(let card):
                    CardAllPrintingsView(card: card)
                }
            }
            .navigationDestination(for: FBCollection.self) { collecton in
                CollectionView(collection: collecton)
            }
    }
    
    var decksView: some View {
        Text("Decks")
            .navigationTitle("Decks")
    }
    
    // MARK: - Sheets
    
    var accountView: some View {
        AccountView()
            .navigationDestination(for: String.self) { string in
                switch string {
                case "Favorites":
                    // TODO
                    NavigationStack {
                        favoritesView
                    }
                case "Collections":
                    NavigationStack {
                        collectionsView
                    }
                default:
                    Text("Not Implemented")
                }
            }
            .navigationDestination(for: CardRoute.self) { route in
                switch route {
                case .detail(let cardArray):
                    CardView(cardArray: cardArray)
                case .printings(let card):
                    CardAllPrintingsView(card: card)
                }
            }
    }
}

struct HeartView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: "Health") {
                    Text("Health")
                }
                NavigationLink(value: "Wealth") {
                    Text("Wealth")
                }
            }
            .navigationTitle("Heart")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        
                    } label : {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationDestination(for: String.self) { string in
                switch string {
                case "Health":
                    List {
                        Text("Health Details")
                    }
                    .navigationTitle("Health Details")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                
                            } label : {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                case "Wealth":
                    List {
                        Text("Wealth Details")
                    }
                    .navigationTitle("Wealth Details")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                
                            } label : {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                default:
                    Text("Not Implemented")
                }
            }
        }
    }
}

extension ManaprobeTabs {
    func languageID(for set: SetBasicInfo) -> String {
        let language = set.languages.first(where: {
            $0.id == "en"
        }) ?? set.languages.first
        let languageID = language?.id ?? "en"
    
        return languageID
    }
}

#Preview {
    ManaprobeTabs()
}
