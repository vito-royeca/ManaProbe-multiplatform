//
//  CardListCollectionItemView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 9/19/26.
//

import SwiftUI

struct CardListCollectionItemView: View {
    @State
    var item: FBCollectionItem
    var index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(index))")
                    .font(.callout)
                Text(item.condition.description)
                Spacer()
                Text(item.isFoil ? "Foil" : "Normal")
                    .foregroundColor(item.isFoil ? Color.green : Color.blue)
                    .multilineTextAlignment(.trailing)
                
            }

            if let notes = item.notes,
               !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundStyle(Color.gray)
                    .safeAreaInset(edge: .leading) {
                        Image(systemName: "text.document")
                            .foregroundStyle(Color.gray)
                    }
            }
            
            if item.dateAcquired != nil ||
                item.placeAcquired != nil ||
                item.purchasePrice != nil ||
                item.purchaseCurrencyCode != nil {
                VStack(alignment: .leading) {
                    Text("Acquisition Info")
                        .font(.footnote)

                    if let dateAcquired = item.dateAcquired {
                        Text(dateAcquired, style: .date)
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                            .safeAreaInset(edge: .leading) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color.gray)
                            }
                    }
                    
                    if let placeAcquired = item.placeAcquired,
                       !placeAcquired.isEmpty {
                        Text(placeAcquired)
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                            .safeAreaInset(edge: .leading) {
                                Image(systemName: "map")
                                    .foregroundStyle(Color.gray)
                            }
                    }
                    
                    if let price = item.purchasePrice,
                       let code = item.purchaseCurrencyCode {
                        Text(price, format: .currency(code: code))
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    @State @Previewable
    var item = FBCollectionItem(cardID: "isd_en_23",
                                isFoil: false,
                                condition: .lightlyPlayed)
    
    CardListCollectionItemView(item: item, index: 1)
}
