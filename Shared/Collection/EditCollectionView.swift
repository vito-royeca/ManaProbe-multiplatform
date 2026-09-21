//
//  EditCollectionView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 9/21/26.
//

import SwiftUI

struct EditCollectionView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding
    var viewModel: CollectionViewModel
    
    @State
    private var name = ""
    @State
    private var description = ""
    @State
    private var isDescriptionExpanded = true
    
    var body: some View {
        NavigationStack {
            contentView
                .onAppear {
                    name = viewModel.collection?.name ?? ""
                    description = viewModel.collection?.description ?? ""
                }
        }
    }
    
    var contentView: some View {
        Form {
            TextField("Name", text: $name)
            DisclosureGroup(isExpanded: $isDescriptionExpanded,
                            content: {
                                TextEditor(text: $description)
                                    .frame(height: 100)
                            },
                            label: {
                                Text("Description")
                                    .safeAreaInset(edge: .leading) { Image(systemName: "text.document") }
                            })
        }
        .navigationTitle("Edit Collection")
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

extension EditCollectionView {
    func save() {
        Task {
            do {
                viewModel.collection?.name = name
                viewModel.collection?.description = description
                try await viewModel.save()
                dismiss()
            } catch {
                print(error)
            }
        }
    }
    
    func canSave() -> Bool {
        var result = true
        
        result = !name.isEmpty
        
        return result
    }
}


