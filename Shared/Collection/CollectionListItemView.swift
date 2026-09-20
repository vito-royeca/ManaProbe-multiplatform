//
//  CollectionListItemView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/9/26.
//

import SwiftUI
import ManaKit
import NukeUI

struct CollectionListItemView: View {
    @Binding
    var item: FBCollectionItem
    
    @State
    private var setDateAcquired = false
    @State
    private var dateAcquired = Foundation.Date()
    
    @State
    private var setPlaceAcquired = false
    @State
    private var placeAcquired = ""
    
    @State
    private var setPurchasePrice = false
    @State
    private var purchaseCurrencyCode = ""
    @State
    private var purchasePrice = ""
    
    @State
    private var notes = ""
    
    var body: some View {
        contentView
            .onChange(of: setDateAcquired) {
                item.dateAcquired = setDateAcquired
                    ? dateAcquired
                    : nil
            }
            .onChange(of: dateAcquired) {
                item.dateAcquired = dateAcquired
            }
        
            .onChange(of: setPlaceAcquired) {
                item.placeAcquired = setPlaceAcquired
                    ? placeAcquired
                    : nil
            }
            .onChange(of: placeAcquired) {
                item.placeAcquired = placeAcquired
            }
        
            .onChange(of: setPurchasePrice) {
                item.purchaseCurrencyCode = setPurchasePrice
                    ? purchaseCurrencyCode
                    : nil
                item.purchasePrice = setPurchasePrice
                    ? Double(purchasePrice)
                    : nil
            }
            .onChange(of: purchaseCurrencyCode) {
                item.purchaseCurrencyCode = purchaseCurrencyCode
            }
            .onChange(of: purchasePrice) {
                item.purchasePrice = Double(purchasePrice)
            }
            .onChange(of: notes) {
                item.notes = notes.isEmpty
                    ? nil
                    : notes
            }
    }
    
    var contentView: some View {
        Group {
            Toggle("Is Foil?", isOn: $item.isFoil)
            
            Picker("Condition", selection: $item.condition) {
                ForEach(CardCondition.allCases, id: \.self) { collection in
                    Text(collection.description)
                        .tag(collection)
                }
            }
            .pickerStyle(.automatic)
            
            Toggle(isOn: $setDateAcquired, label: { Text("Set Date Acquired")})
            if setDateAcquired {
                DatePicker("Date Acquired",
                           selection: $dateAcquired,
                           displayedComponents: .date)
                .datePickerStyle(.compact)
            }
            
            Toggle(isOn: $setPlaceAcquired, label: { Text("Set Place Acquired")})
            if setPlaceAcquired {
                TextField("Place Acquired", text: $placeAcquired)
            }
            
            Toggle(isOn: $setPurchasePrice, label: { Text("Set Purchase Price")})
            if setPurchasePrice {
                Picker("Currency", selection: $purchaseCurrencyCode) {
                    ForEach(Locale.commonISOCurrencyCodes.enumerated(), id: \.offset) { index,currency in
                        Text(getSymbol(forCurrencyCode: currency))
                            .tag(currency)
                    }
                }
                .pickerStyle(.automatic)
                TextField("Purchase Price", text: $purchasePrice)
                    .keyboardType(.decimalPad)
            }
            
            DisclosureGroup(content: {
                TextEditor(text: $notes)
                    .frame(height: 50)
            }, label: {
                Text("Notes")
            })
        }
    }
}

extension CollectionListItemView {
    func getSymbol(forCurrencyCode code: String) -> String {
        let locale = NSLocale(localeIdentifier: code)
        let symbol = locale.displayName(forKey: .currencySymbol, value: code)
        let string = locale.localizedString(forCurrencyCode: code)
        
        var result = symbol ?? code
        
        if let string {
            result = "\(result) - \(string)"
        }
        
        return result
    }
}

#Preview {
    @State @Previewable
    var item = FBCollectionItem(isFoil: false,
                                condition: .lightlyPlayed)
    List {
        CollectionListItemView(item: $item)
    }
}
