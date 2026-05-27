//
//  MoreView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/8/26.
//

import SwiftUI

struct MoreView: View {
    @Environment(AuthModel.self)
    private var authModel

    var body: some View {
        contentView
            .onAppear {
                if authModel.user == nil {
                    authModel.showAccountView.toggle()
                }
            }
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
