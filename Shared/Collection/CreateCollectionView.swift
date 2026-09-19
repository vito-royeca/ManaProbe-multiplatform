//
//  CreateCollectionView.swift
//  Manaprobe
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
    private var description: String = ""
    @State
    private var items = [FBCardItem]()

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
                        .onAppear {
                            if items.isEmpty {
                                addNewItem()
                            }
                        }
                }
            }
            .task {
                fetchData()
            }
        }
    }
    
    var contentView: some View {
        Form {
            CardListItemView(card: card)

            Section (content: {
                Picker("Collection", selection: $type) {
                    Text("Create New")
                        .tag(CreateCollectionType.new)
                    Text("Select")
                        .tag(CreateCollectionType.existing)
                }
                .pickerStyle(.segmented)
                
                switch type {
                case .new:
                    TextField("New Collection \(newNameNumber)", text: $newName)
                    DisclosureGroup(content: {
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }, label: {
                        Text("Description")
                    })
                case .existing:
                    Picker("Collection", selection: $collectionsViewModel.selectedCollection) {
                        ForEach(collectionsViewModel.collections, id: \.id) { collection in
                            Text(collection.name)
                                .tag(collection)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }, footer: {
                switch type {
                case .new:
                    Text("Create a new Collection and add \(items.count > 1 ? "these cards" : "this card") to it.")
                case .existing:
                    Text("Select an existing Collection and add \(items.count > 1 ? "these cards" : "this card") to it.")
                }
                
            })
            
            ForEach(items.enumerated(), id: \.offset) { index,item in
                Section {
                    CollectionItemView(item: $items[index])
                    Button(role: .destructive,
                           action: {
                        items.remove(at: index)
                    },
                           label: {
                        Text("Remove")
                    })
                    .buttonStyle(.borderedProminent)
                        
                }
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
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                addNewItem()
            } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarSpacer(.fixed)
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
    func addNewItem() {
        let item = FBCardItem(isFoil: false,
                              condition: .lightlyPlayed,
                              notes: "",
                              dateAdded: Date(),
                              dateUpdated: Date())
        items.append(item)
    }

    func fetchData() {
        Task {
            await collectionsViewModel.fetchData()
        }
    }

    func save() {
        Task {
            do {
                let card = FBCard(cardID: card.id,
                                  items: items)
                var result = false
                
                if type == .new {
                    
                    result = try await collectionViewModel.create(name: newName,
                                                                  description: description,
                                                                  card: card)
                    newNameNumber += 1
                } else {
                    guard let collection = collectionsViewModel.selectedCollection else {
                        return
                    }
                    
                    result = try await collectionViewModel.update(collection: collection,
                                                                  with: card)
                }
                
                if result {
                    dismiss()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func canSave() -> Bool {
        var result = true
        
        switch type {
        case .new:
            result = !newName.isEmpty && !items.isEmpty
        case .existing:
            result = collectionsViewModel.selectedCollection != nil
        }
        
        return result
    }
}

#Preview {
    AsyncPreviewView { data in
        List {
            CreateCollectionView(card: data.fragments.innerCardInfo)
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "inr_en_14b")
    }
}

struct CollectionItemView: View {
    @Binding
    var item: FBCardItem
    
    var body: some View {
        Toggle("Foil", isOn: $item.isFoil)

        Picker("Condition", selection: $item.condition) {
            ForEach(CardCondition.allCases, id: \.self) { collection in
                Text(collection.description)
                    .tag(collection)
            }
        }
        .pickerStyle(.automatic)
        
        DisclosureGroup(content: {
            TextEditor(text: $item.notes)
                .frame(height: 50)
        }, label: {
            Text("Notes")
        })
    }
}
