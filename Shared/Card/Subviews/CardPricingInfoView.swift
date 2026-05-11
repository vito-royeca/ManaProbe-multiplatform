//
//  CardPricingInfoView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 11/8/23.
//

import SwiftUI
import ManaKit

struct CardPricingInfoView: View {
    let prices: [InnerCardInfo.Price]
    
    @State private var isExpanded  = false
    
    var body: some View {
        Section {
            CardPricingRowView(title: "Market Price",
                               normal: prices.filter({ !($0.isFoil ?? false) }).map{ $0.market ?? 0}.first ?? 0,
                               foil: prices.filter({ ($0.isFoil ?? false) }).map{ $0.market ?? 0}.first ?? 0)
            DisclosureGroup("All TCGPlayer Prices", isExpanded: $isExpanded) {
                
                CardPricingRowView(title: "Direct Low",
                                   normal: prices.filter({ !($0.isFoil ?? false) }).map{ $0.directLow ?? 0}.first ?? 0,
                                   foil: prices.filter({ ($0.isFoil ?? false) }).map{ $0.directLow ?? 0}.first ?? 0)
                CardPricingRowView(title: "Low",
                                   normal: prices.filter({ !($0.isFoil ?? false) }).map{ $0.low ?? 0}.first ?? 0,
                                   foil: prices.filter({ ($0.isFoil ?? false) }).map{ $0.low ?? 0}.first ?? 0)
                CardPricingRowView(title: "Median",
                                   normal: prices.filter({ !($0.isFoil ?? false) }).map{ $0.median ?? 0}.first ?? 0,
                                   foil: prices.filter({ ($0.isFoil ?? false) }).map{ $0.median ?? 0}.first ?? 0)
                CardPricingRowView(title: "High",
                                   normal: prices.filter({ !($0.isFoil ?? false) }).map{ $0.high ?? 0}.first ?? 0,
                                   foil: prices.filter({ ($0.isFoil ?? false) }).map{ $0.high ?? 0}.first ?? 0)
            }
        }
    }
}

struct CardPricingRowView: View {
    var title: String
    var normal: Double
    var foil: Double
    
    var body: some View {
        LabeledContent {
            HStack(alignment: .top) {
                Text("Normal \(normal > 0 ? String(format: "$%.2f", normal) : String.emdash)")
                    .foregroundColor(Color.blue)
                Text("Foil \(foil > 0 ? String(format: "$%.2f", foil) : String.emdash)")
                    .foregroundColor(Color.green)
            }
        } label: {
            Text(title)
        }
    }
}

#Preview {
    CardPricingInfoView(prices: [])
}
