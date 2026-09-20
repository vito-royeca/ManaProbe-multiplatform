//
//  CollectionsRowView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/8/26.
//

import SwiftUI

struct CollectionsRowView: View {
    @State
    var collection: FBCollection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(collection.name)
            if let description = collection.description {
                Text(description)
                    .font(.subheadline)
                    .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    let collection = FBCollection(uid: "1",
                                  name: "Test Collection",
                                  description: "This is the description.")
    CollectionsRowView(collection: collection)
}
