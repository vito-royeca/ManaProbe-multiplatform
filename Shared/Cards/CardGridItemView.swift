//
//  CardGridItemView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/29/26.
//

import SwiftUI
import ManaKit
import NukeUI

struct CardGridItemView: View {
    var card: InnerCardInfo
    
    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel

    var body: some View {
        VStack {
            imageView
            pricingView
        }
    }
    
    var imageView: some View {
        LazyImage(url: URL(string: card.normalURL ?? "")) { phase in
            if let _ = phase.error {
                PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBack)
            } else if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .animation(.easeInOut(duration: 0.3), value: phase.image != nil)
            } else {
                PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBack)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var pricingView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if let price = card.prices?.filter({ !($0.isFoil ?? false)}).first,
                   let marketPrice = price.market,
                   marketPrice > 0 {
                    Text("Normal: \(String(format: "$%.2f", marketPrice))")
                        .font(.subheadline)
                } else {
                    Text("Normal: \u{2014}")
                        .font(.subheadline)
                }
                if let price = card.prices?.filter({ ($0.isFoil ?? false)}).first,
                   let marketPrice = price.market,
                   marketPrice > 0 {
                    Text("Foil: \(String(format: "$%.2f", marketPrice))")
                        .font(.subheadline)
                } else {
                    Text("Foil: \u{2014}")
                        .font(.subheadline)
                }
            }
            Spacer()
            favoriteView
        }
    }
    
    var favoriteView: some View {
        Image(systemName: favoritesViewModel.isFavorite(cardID: card.id) ? "heart.fill" : "heart")
            .foregroundColor(.accentColor)
    }
}

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    AsyncPreviewView { data in
        Grid {
            GridRow {
                ScrollView {
                    CardGridItemView(card: data.fragments.innerCardInfo)
                    Text(data.fragments.innerCardInfo.displayName ?? "")
                }
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "isd_en_51")
    }
    .environment(authModel)
    .environment(favoritesModel)
}
