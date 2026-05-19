//
//  CreateCollectionView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 5/3/26.
//

import SwiftUI
import ManaKit

enum CreateCollectionType {
    case new, existing
}

struct CreateCollectionView: View {
    var card: InnerCardInfo

    @Environment(\.dismiss)
    private var dismiss
    
    @AppStorage("CreateCollection")
    private var newNameNumber = 1
    
    @State
    private var type = CreateCollectionType.new
    @State
    private var collectionsViewModel = CollectionsViewModel()
    @State
    private var collectionViewModel = CollectionViewModel(collection: nil)
    
    @State
    private var newName: String = ""
    
    @State
    private var quantity = 1
    @State
    private var isFoil = false
    @State
    private var condition = CardCondition.lightlyPlayed
    @State
    private var notes = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if collectionsViewModel.isBusy {
                    BusyView()
                } else if collectionsViewModel.isFailed {
                    ErrorView {
                        fetchData()
                    } cancelAction: {
                        collectionsViewModel.isBusy = false
                    }
                } else {
                    contentView
                }
            }
            .onChange(of: collectionsViewModel.selectedCollection) {
                handleCollectionChange()
            }
            .onChange(of: type) {
                handleTypeChange()
            }
            .task {
                fetchData()
            }
        }
    }
    
    var contentView: some View {
        Form {
            CardListItemView(card: card)

            Section {
                Picker("Collection", selection: $type) {
                    Text("Create New")
                        .tag(CreateCollectionType.new)
                    Text("Add To")
                        .tag(CreateCollectionType.existing)
                }
                .pickerStyle(.segmented)
                
                switch type {
                case .new:
                    TextField("New Collection \(newNameNumber)", text: $newName)
                case .existing:
                    Picker("Collection", selection: $collectionsViewModel.selectedCollection) {
                        ForEach(collectionsViewModel.collections, id: \.id) { collection in
                            Text(collection.name)
                                .tag(collection)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            } footer: {
                if type == .new {
                    Text("Name is required.")
                }
            }
            
            Section {
                Stepper {
                    Text("Quantity: \(quantity)")
                } onIncrement: {
                    quantity += 1
                } onDecrement: {
                    quantity -= 1
                    
                    if quantity <= 0 {
                        quantity = 0
                    }
                }

                Toggle("Foil", isOn: $isFoil)

                Picker("Condition", selection: $condition) {
                    ForEach(CardCondition.allCases, id: \.self) { collection in
                        Text(collection.description)
                            .tag(collection)
                    }
                }
                .pickerStyle(.automatic)
            } footer: {
                if type == .existing {
                    Text("Note: setting the Quantity to Zero will remove this card from the collection.")
                }
            }
            
            Section {
                TextEditor(text: $notes)
                    .frame(height: 100)
            } header: {
                Text("Notes")
            }
        }
        .navigationTitle("Collection")
        .toolbar {
            actionToolbar
        }
    }
    
    @ToolbarContentBuilder
    var actionToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                save()
            } label: {
                Image(systemName: "checkmark")
            }
            .disabled(!canSave())
        }
    }
}

extension CreateCollectionView {
    func fetchData() {
        Task {
            await collectionsViewModel.fetchData()
        }
    }

    func handleTypeChange() {
        if type == .new {
            quantity = 1
            isFoil = false
            condition = CardCondition.lightlyPlayed
            notes = ""
        } else {
            guard let selectedCollection = collectionsViewModel.selectedCollection,
                  let card = selectedCollection.cards.filter({ $0.cardID == card.id }).first else {
                quantity = 1
                isFoil = false
                condition = CardCondition.lightlyPlayed
                notes = ""
                return
            }
            
            quantity = card.quantity
            isFoil = card.isFoil
            condition = card.condition
            notes = card.notes
        }
    }
    
    func handleCollectionChange() {
        guard type == .existing,
            let selectedCollection = collectionsViewModel.selectedCollection,
              let card = selectedCollection.cards.filter({ $0.cardID == card.id }).first else {
            quantity = 1
            isFoil = false
            condition = CardCondition.lightlyPlayed
            notes = ""
            return
        }
        
        quantity = card.quantity
        isFoil = card.isFoil
        condition = card.condition
        notes = card.notes
    }

    func save() {
        Task {
            let card = FBCard(cardID: card.id,
                              quantity: quantity,
                              isFoil: isFoil,
                              condition: condition,
                              notes: notes)
            var result = false

            if type == .new {
                result = try await collectionViewModel.create(name: newName, card: card)
                newNameNumber += 1
            } else {
                guard let selectedCollection = collectionsViewModel.selectedCollection else {
                    return
                }
                
                result = try await collectionViewModel.update(collectionUpdate: selectedCollection,
                                                              name: selectedCollection.name,
                                                              card: card)
            }
            
            if result {
                dismiss()
            }
        }
    }
    
    func canSave() -> Bool {
        var result = true
        
        switch type {
        case .new:
            if newName.isEmpty {
                result  = false
            }
            if quantity == 0 {
                result  = false
            }
        case .existing:
            if collectionsViewModel.selectedCollection == nil {
                result = false
            }
        }
        
        return result
    }
}

#Preview {
    AsyncPreviewView { data in
        List {
            if let data = data {
                CreateCollectionView(card: data.fragments.innerCardInfo)
            } else {
                EmptyView()
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "inr_en_14b")
    }
}
