//
//  RulesViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/20/26.
//

import SwiftUI

import ManaKit

extension RuleInfo {
    var titleString: String {
        "\(term ?? "")\(definition != nil ? ". \(definition!)" : "")"
    }
    
//    var definitionWithLinks: String {
//        let hyperLinkText = "see rule"
//        var result = definition ?? ""
//        
//        
//        return result
//    }
}

extension RuleBasicInfo {
    var titleString: String {
        "\(term ?? "")\(definition != nil ? ". \(definition!)" : "")"
    }
}

extension RuleInfo.Child {
    var titleString: String {
        "\(term ?? "")\(definition != nil ? ". \(definition!)" : "")"
    }
}

enum GlossaryIndex: String, CaseIterable {
    case A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z
}

// MARK: - RulesViewModel

@MainActor
@Observable
class RulesViewModel {
    // MARK: - Variables
    
    var rules = [RuleInfo]()
    var searchResults = [RuleInfo]()
    var query = ""
    @ObservationIgnored
    var rule: RuleBasicInfo? = nil
    @ObservationIgnored
    var glossaryIndex: GlossaryIndex? = nil
    
    var isBusy = false
    var isFailed = false

    @ObservationIgnored
    var title: String {
        get {
            if searchResults.isEmpty {
                if let rule {
                    return rule.titleString
                } else if let glossaryIndex {
                    return "Glossary - \(glossaryIndex.rawValue)"
                } else {
                    return "Comprehensive Rules"
                }
            } else {
                return "\(searchResults.count) rules found"
            }
        }
    }

    // MARK: - Initializers
    
    init(rule: RuleBasicInfo? = nil) {
        self.rule = rule
    }
    
    init(glossaryIndex: GlossaryIndex? = nil) {
        self.glossaryIndex = glossaryIndex
    }
    
    // MARK: - Methods
    
    func fetchData(fetchRemote: Bool = false) async -> Void {
        // TODO: handle query and rules.isEmpty
        guard !isBusy else {
            return
        }
        
        if (query.isEmpty && !rules.isEmpty) ||
           (!query.isEmpty && !searchResults.isEmpty) {
           return
        }
        
        do {
            isFailed = false
            isBusy = true

            if query.isEmpty {
                rules.removeAll()
                
                if let glossaryIndex {
                    for rule in try await ManaKitUtilities.shared.glossarySearch(fetchRemote: fetchRemote, letter: glossaryIndex.rawValue)?.rules ?? [] {
                        rules.append(rule.fragments.ruleInfo)
                    }
                } else {
                    for rule in try await ManaKitUtilities.shared.rules(fetchRemote: fetchRemote, id: rule?.id ?? nil)?.rules ?? [] {
                        rules.append(rule.fragments.ruleInfo)
                    }
                }
            } else {
                searchResults.removeAll()
                
                for rule in try await ManaKitUtilities.shared.rulesSearch(fetchRemote: fetchRemote, query: query)?.rules ?? [] {
                    searchResults.append(rule.fragments.ruleInfo)
                }
            }
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func createGlossaryTree() -> Tree<String> {
        var tree = Tree(id: "0", value: "Glossary")
        var children: [Tree<String>] = []
        
        for letter in GlossaryIndex.allCases {
            children.append(Tree(id: letter.rawValue, value: letter.rawValue))
        }
        
        tree.children = children
        return tree
    }
}

