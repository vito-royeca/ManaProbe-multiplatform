//
//  MoreView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/8/26.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        List {
            NavigationLink(value: "Favorites") {
                HStack {
                    Image(systemName: "heart.fill")
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
        .listStyle(.plain)
        .navigationTitle("More")
        .toolbar {
            AccountToolbar(placement: .topBarTrailing)
        }
    }
}

#Preview {
    MoreView()
}
