//
//  Tree.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/20/26.
//

import Foundation

struct Tree<Value: Hashable>: Hashable, Identifiable {
    var id: String
    let value: Value
    var children: [Tree]? = nil
}
