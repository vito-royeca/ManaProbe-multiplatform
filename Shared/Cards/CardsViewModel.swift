//
//  CardsViewModel.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/29/26.
//

import SwiftUI

import Apollo
import ManaKit

// MARK: - SetViewSort

enum CardsSorter: String, CaseIterable {
    case collectorNumber,
         name,
         rarity,
         type
    
    var description: String {
        get {
            switch self {
            case .collectorNumber: "Collector Number"
            case .name: "Name"
            case .rarity: "Rarity"
            case .type: "Type"
            }
        }
    }
    
    var parameterValue: String {
        get {
            switch self {
            case .collectorNumber: "collector_number"
            case .name: "name"
            case .rarity: "rarity"
            case .type: "type"
            }
        }
    }
    
    static let defaultValue: CardsSorter = .name
}

enum CardsOrderer: String, CaseIterable {
    case asc,
         desc
    
    var description: String {
        get {
            switch self {
            case .asc: "Ascending"
            case .desc: "Descending"
            }
        }
    }
    
    var parameterValue: String {
        get {
            switch self {
            case .asc: "asc"
            case .desc: "desc"
            }
        }
    }
    
    static let defaultValue: CardsOrderer = .asc
}

enum CardsDisplay: String, CaseIterable {
    case list,
         grid,
         charts
    
    var symbol: String {
        get {
            switch self {
            case .list:
                "list.bullet"
            case .grid:
                "square.grid.2x2"
            case .charts:
                "chart.pie"
            }
        }
    }
    
    static let defaultValue: CardsDisplay = .list
}

// MARK: - CardsViewModelDelegate

protocol CardsViewModelDelegate {
    func fetchCards(sortBy: CardsSorter, orderBy: CardsOrderer) async throws -> [CardBasicInfo]
//    func reload(sortBy: CardsSorter, orderBy: CardsOrderer) async throws -> [CardBasicInfo]
}

class DefaultCardsViewModelDelegate: CardsViewModelDelegate {
    func fetchCards(sortBy: CardsSorter, orderBy: CardsOrderer) async throws -> [CardBasicInfo] {
//        let set = try await ManaKitUtilities.shared.set(setID: "ecl",
//                                                        languageID: "en")
//        let cards = set?.cards.map(\.fragments.cardBasicInfo) ?? []
//        return cards
        []
    }
    
//    func reload(sortBy: CardsSorter, orderBy: CardsOrderer) async throws -> [CardBasicInfo] {
//        return try await fetchCards(sortBy: sortBy, orderBy: orderBy)
//    }
}

// MARK: - CardsViewModel

@MainActor
@Observable
class CardsViewModel {
    
    // MARK: - Variables

    var cards = [String: [CardBasicInfo]]()
    var cardSections = [String]()
    var cardSectionIndexTitles = [String]()
    
    var isBusy = false
    var isFailed = false
    
    @AppStorage("CardsSorter")
    @ObservationIgnored
    var sorter = CardsSorter.defaultValue
    @AppStorage("CardsOrderer")
    @ObservationIgnored
    var orderer = CardsOrderer.defaultValue
    
    @ObservationIgnored
    var currentCard: CardBasicInfo?
    @ObservationIgnored
    var cardIndex = 0
    @ObservationIgnored
    var delegate: CardsViewModelDelegate?
    
    // MARK: - Initializers
    
    init(delegate: CardsViewModelDelegate? = nil) {
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    func fetchData() async -> Void {
        guard !isBusy/*, set == nil*/ else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            
            clearData()
            let array = try await delegate?.fetchCards(sortBy: sorter, orderBy: orderer) ?? []
            cards[""] = array
            formatData()
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func formatData() -> Void {
        var cardsArray = [CardBasicInfo]()
        for (_,v) in cards {
            cardsArray.append(contentsOf: v)
        }
        clearData()

        switch sorter {
        case .collectorNumber:
            cards[""] = cardsArray.sorted(by: {
                let c0 = $0.collectorNumber ?? ""
                let c1 = $1.collectorNumber ?? ""
                let number0 = Int(c0)
                let number1 = Int(c1)
                
                if let number0,
                   let number1 {
                    return number0 < number1
                } else {
                    return c0 < c1
                }
            })
            cardSections = [""]
        case .name:
            let keys = Set(cardsArray.map({
                if let name = $0.name,
                    let first = name.first {
                    first.isASCII && first.isLetter ? String(first).uppercased() : "#"
                } else {
                    "#"
                }
            }))
            for key in keys {
                let array = cardsArray.filter({
                    if key == "#" {
                        if let name = $0.name,
                            let first = name.first {
                            return !(first.isASCII && first.isLetter) ? true : false
                        } else {
                            return false
                        }
                    } else {
                        guard let name = $0.name else {
                            return false
                        }
                        return name.uppercased().hasPrefix(key)
                    }
                })
                cards[key] = array.sorted(by: { $0.name ?? "" < $1.name ?? ""})
            }
            cardSections = keys.sorted()
            cardSectionIndexTitles = cardSections
        case .rarity:
            let keys = Set(cardsArray.map({ $0.rarity?.name ?? "" }))
            for key in keys {
                if !key.isEmpty {
                    let array = cardsArray.filter({ $0.rarity?.name ?? "" == key })
                    cards[key] = array.sorted(by: { $0.name ?? "" < $1.name ?? ""})
                } else {
                    print("key is empty")
                }
            }
            cardSections = keys.sorted()
        case .type:
            var keys = Set<String>()
            for card in cardsArray {
                for name in (card.supertypes ?? []).map({ $0.name }) {
                    keys.insert(name)
                }
            }
            
            for key in keys {
                var array = [CardBasicInfo]()
                for card in cardsArray {
                    let supertypes = (card.supertypes ?? []).filter({ $0.name == key })
                    if !supertypes.isEmpty {
                        array.append(card)
                    }
                }
                cards[key] = array.sorted(by: { $0.name ?? "" < $1.name ?? "" })
            }
            cardSections = keys.sorted()
        }
    }
    
    func reloadData() async {
        cards.removeAll()
        clearData()
        await fetchData()
    }

    private func clearData() {
        cards.removeAll()
        cardSections.removeAll()
        cardSectionIndexTitles.removeAll()
    }
}

// MARK: - Charts

struct ChartData: Identifiable, Equatable, Hashable {
    let name: String
    let count: Int

    var id: String { return name }
}

extension CardsViewModel {
    func colorsChartData() -> [ChartData] {
        var chartData = [ChartData]()
        var cardsArray = [CardBasicInfo]()
        for (_,v) in cards {
            cardsArray.append(contentsOf: v)
        }
        
        var colors = Set<String>()
        for card in cardsArray {
            if card.colors.isEmpty {
                colors.insert("Colorless")
            } else {
                for color in card.colors {
                    colors.insert(color.name)
                }
            }
        }
        
        for color in colors {
            var count = 0
            for card in cardsArray {
                if card.faces.isEmpty {
                    if card.colors.isEmpty {
                        if color == "Colorless" {
                            count += 1
                        }
                    } else {
                        for cardColor in card.colors {
                            if color == cardColor.name {
                                count += 1
                            }
                        }
                    }
                } else {
                    for face in card.faces {
                        if face.colors.isEmpty {
                            if color == "Colorless" {
                                count += 1
                            }
                        } else {
                            for cardColor in face.colors {
                                if color == cardColor.name {
                                    count += 1
                                }
                            }
                        }
                    }
                }
            }
            let data = ChartData(name: color, count: count)
            chartData.append(data)
        }
        
        let orderedChartData = chartData.sorted(by: { $0.name < $1.name })
        return orderedChartData
    }

    func raritiesChartData() -> [ChartData] {
        var chartData = [ChartData]()
        var cardsArray = [CardBasicInfo]()
        for (_,v) in cards {
            cardsArray.append(contentsOf: v)
        }
        
        var rarities = Set<InnerCardInfo.Rarity>()
        for card in cardsArray {
            if let rarity = card.rarity {
                rarities.insert(rarity)
            }
        }
        
        for rarity in rarities {
            var count = 0
            for card in cardsArray {
                if card.rarity == rarity {
                    count += 1
                }
            }
            let data = ChartData(name: rarity.name, count: count)
            chartData.append(data)
        }
        
        let orderedChartData = chartData.sorted(by: { $0.name < $1.name })
        return orderedChartData
    }
    
    func typesChartData() -> [ChartData] {
        var chartData = [ChartData]()
        var cardsArray = [CardBasicInfo]()
        for (_,v) in cards {
            cardsArray.append(contentsOf: v)
        }
        
        var types = Set<CardType>()
        for card in cardsArray {
            for name in (card.supertypes ?? []).map({ $0.name }) {
                for cardType in name.cardTypes() {
                    types.insert(cardType)
                }
            }
        }
        
        for type in types {
            var count = 0
            for card in cardsArray {
                for superType in card.supertypes ?? [] {
                    let cardTypes = superType.name.cardTypes()
                    let array = cardTypes.filter({ $0.description.lowercased() == type.description.lowercased() })
                    count += !array.isEmpty ? 1 : 0
                }
            }
            let data = ChartData(name: type.description, count: count)
            chartData.append(data)
        }
        
        let orderedChartData = chartData.sorted(by: { $0.name < $1.name })
        return orderedChartData
    }
    
    func color(rarity: String) -> Color {
        switch rarity {
        case "Bonus":
            Color(hex: "BF4427")
        case "Common":
            Color(hex: "1A1718")
        case "Mythic":
            Color(hex: "BF4427")
        case "Rare":
            Color(hex: "A58E4A")
        case "Special":
            Color(hex: "B22222")
        case "Uncommon":
            Color(hex: "707883")
        default:
            Color(hex: "000000")
        }
    }
    
    func color(name: String) -> Color {
        switch name {
        case "Black":
            Color.black
        case "Blue":
            Color(hex: "305CDE") // Royal Blue
        case "Green":
            Color(hex: "2E6F40") // Forest Green
        case "Red":
            Color(hex: "CD1C18") // Chili Red
        case "White":
            Color(hex: "E8E4C9") // Dirty White
        default:
            Color(hex: "704214") // Sepia Brown
        }
    }
}
