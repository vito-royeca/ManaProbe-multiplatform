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
    private var setPurchasePrice = false
    @State
    private var purchaseCurrencyCode = ""
    @State
    private var purchasePrice = ""
    
    @State
    private var setPlaceAcquired = false
    @State
    private var placeAcquired = ""
    
    @State
    private var notes = ""
    @State
    private var isNotesExpanded = true
    
    @State
    private var currencyCodeSymbols = [String: String]()
    
    var body: some View {
        contentView
            .onAppear {
                setupData()
            }
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
            Section {
                Picker("Condition", selection: $item.condition) {
                    ForEach(CardCondition.allCases, id: \.self) { collection in
                        Text(collection.description)
                            .tag(collection)
                    }
                }
                .pickerStyle(.automatic)
                
                Toggle("Is Foil?", isOn: $item.isFoil)
                
                DisclosureGroup(isExpanded: $isNotesExpanded,
                                content: {
                                    TextEditor(text: $notes)
                                        .frame(height: 100)
                                },
                                label: {
                                    Text("Notes")
                                        .safeAreaInset(edge: .leading) { Image(systemName: "text.document") }
                                })
            } header: {
                Text("Card Details")
            }
            
            Section {
                Toggle(isOn: $setDateAcquired, label: { Text("Set Date Acquired")})
                    .safeAreaInset(edge: .leading) { Image(systemName: "calendar") }
                if setDateAcquired {
                    DatePicker("Date Acquired",
                               selection: $dateAcquired,
                               displayedComponents: .date)
                    .datePickerStyle(.compact)
                }
                
                Toggle(isOn: $setPlaceAcquired, label: { Text("Set Place Acquired")})
                    .safeAreaInset(edge: .leading) { Image(systemName: "map") }
                if setPlaceAcquired {
                    TextField("Place Acquired", text: $placeAcquired)
                }
                
                Toggle(isOn: $setPurchasePrice, label: { Text("Set Purchase Price")})
                if setPurchasePrice {
                    Picker("Currency", selection: $purchaseCurrencyCode) {
                        ForEach(currencyCodeSymbols.keys.sorted().enumerated(), id: \.offset) { index,code in
                            Text(currencyCodeSymbols[code] ?? "")
                                .tag(code)
                        }
                    }
                    .pickerStyle(.automatic)
                    TextField("Purchase Price", text: $purchasePrice)
                        .keyboardType(.decimalPad)
                }
            } header: {
                Text("Acquisition Info")
            }
        }
    }
    
    private func setupData() {
        for code in Locale.commonISOCurrencyCodes {
            currencyCodeSymbols[code] = getSymbol(forCurrencyCode: code)
        }
        
        setDateAcquired = item.dateAcquired != nil
        
        if let price = item.purchasePrice {
            setPurchasePrice = true
            purchasePrice = "\(price)"
        }
        if let code = item.purchaseCurrencyCode {
            purchaseCurrencyCode = code
        }
        
        if let place = item.placeAcquired {
            setPlaceAcquired = true
            placeAcquired = place
        }
        
        if let string = item.notes {
            notes = string
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
    var item = FBCollectionItem(cardID: "isd_en_23",
                                isFoil: false,
                                condition: .lightlyPlayed)
    List {
        CollectionListItemView(item: $item)
    }
}
