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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
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
            }
            
            VStack(alignment: .leading) {
                Text("Acquisition Info")
                    .font(.footnote)
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color.gray)
                        if let dateAcquired = item.dateAcquired {
                            Text(dateAcquired, style: .date)
                                .font(.footnote)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    HStack {
                        Image(systemName: "map")
                            .foregroundStyle(Color.gray)
                        Text(item.placeAcquired ?? "")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
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
    var item = FBCollectionItem(isFoil: false,
                                condition: .lightlyPlayed)
    
    CardListCollectionItemView(item: item)
}
