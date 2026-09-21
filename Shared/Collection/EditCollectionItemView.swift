//
//  EditCollectionItemView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 9/20/26.
//

import SwiftUI
import ManaKit

struct EditCollectionItemView: View {
    var card: InnerCardInfo
    @State
    var item: FBCollectionItem
    @State
    var viewModel: CollectionViewModel
    var editCallback: (() -> Void)? = nil
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var newName: String = ""
    @State
    private var description: String = ""

    var body: some View {
        NavigationStack {
            contentView
        }
    }
    
    var contentView: some View {
        Form {
            CardListItemView(card: card)
            CollectionListItemView(item: $item)
        }
        .navigationTitle("Edit Collection Item")
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
        }
    }
}

extension EditCollectionItemView {
    func save() {
        Task {
            do {
                try await viewModel.update(item: item)
                editCallback?()
                dismiss()
            } catch {
                print(error)
            }
        }
    }
}

//#Preview {
//    EditCollectionItemView()
//}
