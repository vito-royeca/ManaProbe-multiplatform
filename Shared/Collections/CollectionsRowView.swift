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
        contentView
    }
    
    var contentView: some View {
        VStack(alignment: .leading) {
            Text(collection.name)
            
            if let description = collection.description,
               !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .safeAreaInset(edge: .leading) {
                        Image(systemName: "text.document")
                    }
            }

            HStack {
                if let dateUpdated = collection.dateUpdated {
                    Text(dateUpdated.elapsedTime())
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .safeAreaInset(edge: .leading) {
                            Image(systemName: "document.badge.clock")
                        }
                }
                
                Spacer()
                Text(collection.countDescription)
                    .font(.footnote)
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
