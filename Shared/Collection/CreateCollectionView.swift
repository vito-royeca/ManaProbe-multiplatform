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
    var saveCallback: (() -> Void)? = nil

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
    private var isDescriptionExpanded = true
    
    @State
    private var item = FBCollectionItem(cardID: "",
                                        isFoil: false,
                                        condition: .lightlyPlayed)

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
                    Text("Select")
                        .tag(CreateCollectionType.existing)
                }
                .pickerStyle(.segmented)
                
                switch type {
                case .new:
                    TextField("New Collection \(newNameNumber)", text: $newName)
                    DisclosureGroup(isExpanded: $isDescriptionExpanded,
                                    content: {
                                        TextEditor(text: $description)
                                            .frame(height: 100)
                                    },
                                    label: {
                                        Text("Description")
                                            .safeAreaInset(edge: .leading) { Image(systemName: "text.document") }
                                    })
                case .existing:
                    Picker("Collection", selection: $collectionsViewModel.selectedCollection) {
                        ForEach(collectionsViewModel.collections, id: \.id) { collection in
                            Text(collection.name)
                                .tag(collection)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            } header: {
                Text("Collection")
            } footer: {
                switch type {
                case .new:
                    Text("Create a new Collection and add this card.")
                case .existing:
                    Text("Select an existing Collection and add this card.")
                }
            }
            
            CollectionListItemView(item: $item)
        }
        .navigationTitle("Add to Collection")
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

    func save() {
        Task {
            do {
                item.cardID = card.id
                if type == .new {
                    try await collectionViewModel.create(name: newName,
                                                         description: description.isEmpty
                                                             ? nil
                                                             : description,
                                                         newItems: [item])
                    newNameNumber += 1
                } else {
                    guard let collection = collectionsViewModel.selectedCollection else {
                        return
                    }
                    
                    try await collectionViewModel.update(collection: collection,
                                                         newItems: [item])
                }

                saveCallback?()
                dismiss()
            } catch {
                print(error)
            }
        }
    }
    
    func canSave() -> Bool {
        var result = true
        
        switch type {
        case .new:
            result = !newName.isEmpty
        case .existing:
            result = collectionsViewModel.selectedCollection != nil
        }
        
        return result
    }
}

//#Preview {
//    AsyncPreviewView { data in
//        List {
//            CreateCollectionView(card: data.fragments.innerCardInfo)
//        }
//    } fetchData: {
//        try await ManaKitUtilities.shared.card(fetchRemote: false,
//                                               id: "inr_en_14b")
//    }
//}
