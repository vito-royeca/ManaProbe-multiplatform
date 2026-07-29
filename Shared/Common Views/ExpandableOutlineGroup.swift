//
//  ExpandableOutlineGroup.swift
//  Manaprobe
//
//  Created by Vito Royeca on 7/29/26.
//

import SwiftUI

struct ExpandableOutlineGroup<Node, Content>: View where Node: Hashable, Node: Identifiable, Content: View {
    let node: Node
    let childKeyPath: KeyPath<Node, [Node]?>
    @State var isExpanded: Bool = true
    let content: (Node) -> Content
    
    var body: some View {
        if node[keyPath: childKeyPath] != nil {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    if isExpanded {
                        ForEach(node[keyPath: childKeyPath]!) { childNode in
                            ExpandableOutlineGroup(node: childNode,
                                                   childKeyPath: childKeyPath,
                                                   isExpanded: isExpanded,
                                                   content: content)
                        }
                    }
                },
                label: { content(node) })
        } else {
            content(node)
        }
    }
}
