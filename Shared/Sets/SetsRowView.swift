//
//  SetsRowView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/12/26.
//

import SwiftUI
import ManaKit
import NukeUI

struct SetsRowView: View {
    @State
    var set: SetBasicInfo

    var body: some View {
        rowView
    }
    
    private var rowView: some View {
        HStack(alignment: .center, spacing: 10) {
            imageView

            VStack(alignment: .leading) {
                if (set.isOnlineOnly) {
                    onlineOnlyView
                }
                Text(set.name)
                    .font(.subheadline)
                infoView
            }
        }
    }
    
    private var onlineOnlyView: some View {
        HStack(alignment: .top) {
            Spacer()
            Image(systemName: "checkmark.icloud")
            Text("Online only")
                .font(.footnote)
        }
    }

    private var imageView: some View {
        Group {
            if let lastPath = set.smallLogoURL?.split(separator: "/").last,
               let uiImage = ManaKitUtilities.shared.image(fileName: String(lastPath)) {
                Image(uiImage: uiImage)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            } else {
                let url = URL(string: set.smallLogoURL ?? "")
                LazyImage(url: url) { phase in
                    if let _ = phase.error {
                        Image(systemName: "photo.badge.exclamationmark")
                    } else if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .frame(width: 100, height: 50)
    }
    
    private var infoView: some View {
        HStack {
            let cardCount = set.cardCount ?? 0
            Text(set.keyruneUnicode.keyrune2Unicode())
                .font(Font.custom("Keyrune", size: 20))
            Text((set.id).uppercased())
                .font(.subheadline)
                .foregroundColor(Color.gray)
            Spacer()
            Text("\(cardCount) card\(cardCount > 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundColor(Color.gray)
        }
    }
}

