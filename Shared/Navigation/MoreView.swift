//
//  MoreView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/8/26.
//

import SwiftUI
import ManaKit

struct MoreView: View {
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        List {
            Section(header: Text("My")) {
                NavigationLink(value: "Favorites") {
                    HStack {
                        Image(systemName: "heart")
                        Text("Favorites")
                    }
                }
                NavigationLink(value: "Collections") {
                    HStack {
                        Image(systemName: "rectangle.stack")
                        Text("Collections")
                    }
                }
                NavigationLink(value: "Decks") {
                    HStack {
                        Image(systemName: "square.stack.3d.up")
                        Text("Decks")
                    }
                }
            }

            Section(header: Text("Tools")) {
                NavigationLink(value: "Rules") {
                    HStack {
                        Image(systemName: "text.book.closed")
                        Text("Comprehensive Rules")
                    }
                }
                NavigationLink(value: "Life Tracker") {
                    HStack {
                        Image(systemName: "heart.text.clipboard")
                        Text("Life Tracker")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("More")
        .toolbar {
            AccountToolbar(placement: .topBarTrailing)
        }
        .navigationDestination(for: String.self) { string in
            switch string {
            case "Favorites":
                favoritesView
            case "Collections":
                collectionsView
            case "Rules":
                rulesView
            default:
                Text("Not Implemented")
            }
        }
        .navigationDestination(for: GlossaryIndex.self) { index in
            RulesView(glossaryIndex: index)
        }
        .navigationDestination(for: RuleInfo.self) { rule in
            RulesView(rule: rule.fragments.ruleBasicInfo)
        }
        .navigationDestination(for: RuleInfo.Child.self) { rule in
            RulesView(rule: rule.fragments.ruleBasicInfo)
        }
    }
    
    var favoritesView: some View {
        FavoritesView()
            .navigationDestination(for: CardRoute.self) { route in
                switch route {
                case .details(let selectedCard, let navigator):
                    CardView(card: selectedCard, navigator: navigator)
                case .printings(let card):
                    CardAllPrintingsView(card: card)
                }
            }
    }
    
    var collectionsView: some View {
        CollectionsView()
            .navigationDestination(for: CardRoute.self) { route in
                switch route {
                case .details(let selectedCard, let navigator):
                    CardView(card: selectedCard, navigator: navigator)
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

    var rulesView: some View {
        RulesView(rule: nil)
    }
}

#Preview {
    NavigationStack {
        MoreView()
            .environment(AuthModel())
            .environment(FavoritesViewModel())
    }
}
