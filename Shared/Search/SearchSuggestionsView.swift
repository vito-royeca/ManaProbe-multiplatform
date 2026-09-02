//
//  SearchSuggestionsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/1/26.
//

import SwiftUI

struct SearchSuggestionsView: View {
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        List {
            Text("Artists")
            Text("Banned and Restricted")
            Text("Power Nine")
            Text("Reserved List")
        }
    }
}

#Preview {
    SearchSuggestionsView()
}
