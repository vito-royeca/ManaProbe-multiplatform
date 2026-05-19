//
//  CardListItemView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 3/25/22.
//

import SwiftUI
import ManaKit
import NukeUI

struct CardListItemView: View {
    var card: InnerCardInfo

    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel

    var body: some View {
        HStack(alignment: .top) {
            thumbnailView
            VStack(alignment: .leading) {
                informationView
                Spacer()
                HStack {
                    pricingView
                    Spacer()
                    favoriteView
                }
            }
        }
    }
    
    var thumbnailView: some View {
        LazyImage(url: URL(string: card.artCropURL ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBackCropped)
            }
        }
        .frame(width: 120, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var informationView: some View {
        VStack(alignment: .leading) {
            Text(card.displayName ?? "")
            Spacer()
            HStack {
                Text(card.set?.keyruneUnicode.keyrune2Unicode() ?? "e684")
                    .font(Font.custom("Keyrune", size: 20))
                    .foregroundColor(Color(hex: card.keyruneColor ?? "000"))
                Text("\u{2022} #\(card.collectorNumber ?? "") \u{2022} \(card.rarity?.name ?? "") \u{2022} \(card.language?.displayID ?? "")")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                Spacer()
            }
        }
    }
    
    var pricingView: some View {
        VStack(alignment: .leading) {
            if let price = card.prices?.filter({ !($0.isFoil ?? false)}).first,
               let marketPrice = price.market,
               marketPrice > 0 {
                Text("Normal: \(String(format: "$%.2f", marketPrice))")
                    .font(.footnote)
            } else {
                Text("Normal: \u{2014}")
                    .font(.footnote)
            }
            if let price = card.prices?.filter({ ($0.isFoil ?? false)}).first,
               let marketPrice = price.market,
               marketPrice > 0 {
                Text("Foil: \(String(format: "$%.2f", marketPrice))")
                    .font(.footnote)
            } else {
                Text("Foil: \u{2014}")
                    .font(.footnote)
            }
        }
    }
    
    var favoriteView: some View {
        Image(systemName: favoritesViewModel.isFavorite(cardID: card.id) ? "heart.fill" : "heart")
            .foregroundColor(.accentColor)
    }
}

#Preview {
    AsyncPreviewView { data in
        List {
            if let data = data {
                CardListItemView(card: data.fragments.innerCardInfo)
            } else {
                EmptyView()
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "inr_en_14b")
    }
}
