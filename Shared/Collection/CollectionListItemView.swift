//
//  CollectionListItemView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 5/9/26.
//

import SwiftUI
import ManaKit
import NukeUI

struct CollectionListItemView: View {
    var card: InnerCardInfo
    var fbCard: FBCard

    var body: some View {
        
            HStack(alignment: .top) {
                thumbnailView
                VStack(alignment: .leading) {
                    informationView
                    Spacer()
                    HStack {
                        pricingView
                        Spacer()
                        quantityView
                    }
                    Text(fbCard.notes)
                        .font(.caption)
                        .foregroundColor(Color.gray)
                        .lineLimit(1)
                        .padding(.top, 10)
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
    
    var quantityView: some View {
        VStack(alignment: .leading) {
            Text("Qty: \(fbCard.quantity)x")
                .font(.footnote)
                .multilineTextAlignment(.trailing)
            Text("Foil: \(fbCard.isFoil ? "Yes" : "No")")
                .font(.footnote)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    let cardID = "isd_en_51"
    let fbCard = FBCard(cardID: cardID,
                        quantity: 1,
                        isFoil: false,
                        condition: CardCondition.lightlyPlayed,
                        notes: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras non nisl at nunc lobortis accumsan a eget est. Integer eleifend.")
    AsyncPreviewView { data in
        List {
            if let data = data {
                CollectionListItemView(card: data.fragments.innerCardInfo,
                                       fbCard: fbCard)
            } else {
                EmptyView()
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: cardID)
    }
}
