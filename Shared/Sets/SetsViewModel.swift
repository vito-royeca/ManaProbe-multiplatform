//
//  SetsViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 3/21/22.
//

import SwiftUI

import ManaKit

enum SetsSorter: String, CaseIterable {
    case name,
         type,
         year
    
    var description: String {
        get {
            switch self {
            case .name: "Name"
            case .type: "Type"
            case .year: "Year"
            }
        }
    }
    
    static let defaultValue: SetsSorter = .year
}

struct Tree<Value: Hashable>: Hashable, Identifiable {
    var id: String
    let value: Value
    var children: [Tree]? = nil
}

// MARK: - SetsViewModel

@MainActor
@Observable
class SetsViewModel {
    
    // MARK: - Variables
    
    var sets = [String: [Tree<SetBasicInfo>]]()
    var filteredSets = [Tree<SetBasicInfo>]()
    var sections = [String]()
    var sectionIndexTitles = [String]()
    var setTypes = [SetBasicInfo.SetType]()
    
    var isBusy = false
    var isFailed = false
    
    @ObservationIgnored
    @AppStorage("SetsSorter")
    var sorter = SetsSorter.defaultValue
    
    // MARK: - Initializers

    init() {
        
    }

    init(sectionedSets: SectionedSets) {
        process(sectionedSets: sectionedSets)
    }
    
    // MARK: - Methods
    
    func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy, sets.isEmpty else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            
            clearData()
            
            switch sorter {
            case .name:
                if let sectionedSets = try await ManaKitUtilities.shared.sets(fetchRemote: fetchRemote, type: .byName) {
                    process(sectionedSets: sectionedSets)
                }
            case .type:
                if let sectionedSets = try await ManaKitUtilities.shared.sets(fetchRemote: fetchRemote, type: .byType) {
                    process(sectionedSets: sectionedSets)
                }
            case .year:
                if let sectionedSets = try await ManaKitUtilities.shared.sets(fetchRemote: fetchRemote, type: .byYear) {
                    process(sectionedSets: sectionedSets)
                }
            }
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    private func process(sectionedSets: SectionedSets) {
        switch sorter {
        case .name:
            sections = sectionedSets.sections
            sectionIndexTitles = sections
        case .type:
            sections = sectionedSets.sections
            sectionIndexTitles = []
        case .year:
            sections = sectionedSets.sections
        }
        
        for section in sections {
            var array = [Tree<SetBasicInfo>]()
            for set in sectionedSets.sectionedSets.filter({ $0.section == section }).first?.sets ?? [] {
                array.append(setToTree(set: set.fragments.setInfo))
            }
            sets[section] = array
        }
        
        var setTypesContainer = Set<SetBasicInfo.SetType>()
        for (_,v) in sets {
            for set in v {
                setTypesContainer.insert(set.value.setType)
            }
        }
        
        setTypes = Array(setTypesContainer).sorted(by: { $0.name < $1.name })
        
        formatData()
    }

    private func setToTree(set: SetInfo) -> Tree<SetBasicInfo> {
        var tree = Tree(id: set.id, value: set.fragments.setBasicInfo)
        
        if !set.children.isEmpty {
            var children = [Tree<SetBasicInfo>]()
            
            for child in set.children {
                if let c = childToTree(set: child) {
                    children.append(c)
                }
            }
            tree.children = children
        }
        
        return tree
    }
    
    private func childToTree(set: Any) -> Tree<SetBasicInfo>? {
        var tree: Tree<SetBasicInfo>?
        
        if let set = set as? SetInfo.Child {
            tree = Tree(id: set.id, value: set.fragments.setBasicInfo)
            if !set.children.isEmpty {
                var children = [Tree<SetBasicInfo>]()
                for child in set.children {
                    if let c = childToTree(set: child) {
                        children.append(c)
                    }
                }
                tree?.children = children
            }
        } else if let set = set as? SetInfo.Child.Child {
            tree = Tree(id: set.id, value: set.fragments.setBasicInfo)
            if !set.children.isEmpty {
                var children = [Tree<SetBasicInfo>]()
                for child in set.children {
                    if let c = childToTree(set: child) {
                        children.append(c)
                    }
                }
                tree?.children = children
            }
        } else if let set = set as? SetInfo.Child.Child.Child {
            tree = Tree(id: set.id, value: set.fragments.setBasicInfo)
        }
        
        return tree
    }
    
    func formatData() -> Void {
        var setsArray = [Tree<SetBasicInfo>]()
        for (_,v) in sets {
            setsArray.append(contentsOf: v)
        }
        
        clearData()
        
        switch sorter {
        case .name:
            let keys = Set(setsArray.map({
                if let first = $0.value.name.first {
                    first.isASCII && first.isLetter ? String(first).uppercased() : "#"
                } else {
                    "#"
                }
            }))
            for key in keys {
                let array = setsArray.filter({
                    if key == "#" {
                        if let first = $0.value.name.first {
                            return !(first.isASCII && first.isLetter) ? true : false
                        } else {
                            return false
                        }
                    } else {
                        return $0.value.name.uppercased().hasPrefix(key)
                    }
                })
                sets[key] = array.sorted(by: { $0.value.name < $1.value.name })
            }
            sections = keys.sorted()
            sectionIndexTitles = sections
        case .type:
            let keys = Set(setsArray.map({ $0.value.setType.name }))
            for key in keys {
                let array = setsArray.filter({ $0.value.setType.name == key })
                sets[key] = array.sorted(by: { $0.value.setType.name < $1.value.setType.name })
            }
            sections = keys.sorted()
        case .year:
            let keys = Set(setsArray.map({ $0.value.yearSection }))
            for key in keys {
                let array = setsArray.filter({ $0.value.yearSection == key })
                sets[key] = array.sorted(by: { $0.value.releaseDate > $1.value.releaseDate })
            }
            sections = keys.sorted().reversed()
        }
    }
    
    func reloadData() async {
        clearData()
        await fetchData(fetchRemote: true)
    }

    func filterData(query: String) {
        let queryLowercased = query.lowercased()
        filteredSets = [Tree<SetBasicInfo>]()
        
        for (_,v) in sets {
            var array = Array(v)
            // include the children
            for item in array {
                for child0 in item.children ?? [] {
                    array.append(child0)
                    for child1 in child0.children ?? [] {
                        array.append(child1)
                        for child2 in child1.children ?? [] {
                            array.append(child2)
                            for child3 in child2.children ?? [] {
                                array.append(child3)
                            }
                        }
                    }
                }
            }
            
            if queryLowercased.isEmpty {
                filteredSets.append(contentsOf: array.sorted(by: { $0.value.name < $1.value.name }))
            } else {
                filteredSets.append(contentsOf: array.filter({
                    if queryLowercased.count == 1 {
                        $0.value.name.lowercased().hasPrefix(queryLowercased)
                    } else {
                        $0.value.name.lowercased().contains(queryLowercased) ||
                        $0.value.id.lowercased().contains(queryLowercased)
                    }
                }).sorted(by: { $0.value.name < $1.value.name }))
            }
        }
    }
    
    private func clearData() {
        sets.removeAll()
        sections.removeAll()
        sectionIndexTitles.removeAll()
    }
}

