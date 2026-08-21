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
    
    var definitionWithLinks: String {
        let hyperLinkText = "see rule"
        var result = definition ?? ""
        
        
        return result
    }
}

extension RuleInfo.Child {
    var titleString: String {
        "\(term ?? "")\(definition != nil ? ". \(definition!)" : "")"
    }
}

// MARK: - RulesViewModel

@MainActor
@Observable
class RulesViewModel {
    // MARK: - Variables
    var rules = [RuleInfo]()
    @ObservationIgnored
    var rule: RuleBasicInfo? = nil
    
    var isBusy = false
    var isFailed = false

    @ObservationIgnored
    var title: String {
        get {
            if let rule {
                return "\(rule.term ?? "") \(rule.definition != nil ? ". \(rule.definition!)" : "")"
            } else {
                return "Comprehensive Rules"
            }
        }
    }

    // MARK: - Initializers
    
    init(rule: RuleBasicInfo? = nil) {
        self.rule = rule
    }
    
    // MARK: - Methods
    
    func fetchData(fetchRemote: Bool = false) async -> Void {
        guard !isBusy, rules.isEmpty else {
            return
        }
        
        do {
            isFailed = false
            isBusy = true
            rules = [RuleInfo]()
            
            for rule in try await ManaKitUtilities.shared.rules(fetchRemote: fetchRemote, id: rule?.id ?? nil)?.rules ?? [] {
                rules.append(rule.fragments.ruleInfo)
            }
            
            isBusy = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
//    private func ruleToTree(rule: RuleInfo) -> Tree<RuleBasicInfo> {
//        var tree = Tree(id: "\(rule.id)", value: rule.fragments.ruleBasicInfo)
//        var children = [Tree<RuleBasicInfo>]()
//        
//        for child in rule.children ?? [] {
//            children.append(Tree(id: "\(child.id)", value: child.fragments.ruleBasicInfo))
//        }
//        
//        tree.children = children
//        return tree
//    }
}

