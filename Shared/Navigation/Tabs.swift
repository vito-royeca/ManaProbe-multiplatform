//
//  Tabs.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/12/26.
//

enum Tabs: Equatable, Hashable, Identifiable {
    case news
    case sets
    case scanner
    case search
    case rules
    case my(MyTabs)
    case more
    
    var id: Int {
        switch self {
        case .news: 1000
        case .sets: 1001
        case .scanner: 1002
        case .search: 1003
        case .rules: 1005
        case .my: 1006
        case .more: 1007
        }
    }
    
    var name: String {
        switch self {
        case .news: String(localized: "News", comment: "Tab title")
        case .sets: String(localized: "Sets", comment: "Tab title")
        case .scanner: String(localized: "Scanner", comment: "Tab title")
        case .search: String(localized: "Search", comment: "Tab title")
        case .rules: String(localized: "Rules", comment: "Tab title")
        case .my: String(localized: "My", comment: "Tab title")
        case .more: String(localized: "More", comment: "Tab title")
        }
    }
    
    var customizationID: String {
        return "com.managuide.ManaGuide." + self.name
    }

    var symbol: String {
        switch self {
        case .news: "newspaper"
        case .sets: "books.vertical"
        case .scanner: "camera.viewfinder"
        case .search: "magnifyingglass"
        case .rules: "text.book.closed"
        case .my: "rectangle.stack"
        case .more: "ellipsis"
        }
    }
}

enum MyTabs: Equatable, Hashable, Identifiable, CaseIterable {
    case favorites
    case collections
    case decks
    
    var id: Int {
        switch self {
        case .favorites: 2000
        case .collections: 2001
        case .decks: 2002
        }
    }
    
    var name: String {
        switch self {
        case .favorites: String(localized: "Favorites", comment: "Tab title")
        case .collections: String(localized: "Collections", comment: "Tab title")
        case .decks: String(localized: "Decks", comment: "Tab title")
        }
    }
    
    var customizationID: String {
        return "com.managuide.ManaGuide." + self.name
    }

    var symbol: String {
        switch self {
        case .favorites: "heart"
        case .collections: "rectangle.stack"
        case .decks: "square.stack.3d.up"
        }
    }
}
