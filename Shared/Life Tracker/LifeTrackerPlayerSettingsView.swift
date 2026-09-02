//
//  LifeTrackerPlayerSettingsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/28/26.
//

import SwiftUI

struct LifeTrackerPlayerSettingsView: View {
    @Environment(\.dismiss)
    private var dismiss

    @State var newName: String = ""

    @Binding
    var viewModel: LifeTrackerPlayerModel
    
    var body: some View {
        NavigationStack {
            contentView
                .onAppear {
                    initPlayer()
                }
        }
    }
    
    var contentView: some View {
        Form {
            TextField("Name", text: $newName)
            Toggle("Show Poison Counter",
                   isOn: $viewModel.showPoisonCounter)
            Toggle("Show Energy Counter",
                   isOn: $viewModel.showEnergyCounter)
        }
        .navigationTitle("Player Settings")
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
                dismiss()
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }
}

extension LifeTrackerPlayerSettingsView {
    func initPlayer() {
        newName = viewModel.name
    }

    func save() {
        viewModel.name = newName
    }
}

#Preview {
    @Previewable @State
    var model = LifeTrackerPlayerModel(name: "Player 1",
                                       life: 20)
    
    LifeTrackerPlayerSettingsView(viewModel: $model)
}
