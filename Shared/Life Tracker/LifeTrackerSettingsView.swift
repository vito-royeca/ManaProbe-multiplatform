//
//  LifeTrackerSettingsView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/28/26.
//

import SwiftUI

struct LifeTrackerSettingsView: View {
    @Environment(\.dismiss)
    private var dismiss

    @Binding
    var gameModel: LifeTrackerGameModel

    @State
    var playerCount = LifeTrackerGameModel.minPlayers
    @State
    var startingLife = LifeTrackerGameModel.minStartingLife
    @State
    var colorPalette = LifeTrackerGameModel.defaultColorPalette
    
    var body: some View {
        NavigationStack {
            contentView
                .onAppear {
                    playerCount = gameModel.playerCount
                    startingLife = gameModel.startingLife
                    colorPalette = gameModel.colorPalette
                }
        }
    }
    
    var contentView: some View {
        Form {
            playerCountView
            startingLifeView
            Section(header: Text("Color")) {
                colorPaletteView
                colorPalette(for: colorPalette)
                    .frame(height: 100)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            actionToolbar
        }
    }
    
    var playerCountView: some View {
        LabeledContent(content: {
            Picker("Players",
                   selection: $playerCount) {
                ForEach((1...LifeTrackerGameModel.maxPlayers),
                        id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.menu)
            .onChange(of: playerCount) {
                gameModel.isSettingsChanging = true
            }
            .disabled(gameModel.isGameStarted)
        }, label: {
            Image(systemName: "person.3")
        })
    }
    
    var startingLifeView: some View {
        return LabeledContent(content: {
            Picker("Starting Life",
                   selection: $startingLife) {
                ForEach(LifeTrackerGameModel.startingLives,
                        id: \.self) { life in
                    Text("\(life)")
                }
            }
            .pickerStyle(.menu)
            .onChange(of: startingLife) {
                gameModel.isSettingsChanging = true
            }
            .disabled(gameModel.isGameStarted)
        }, label: {
            Image(systemName: "staroflife")
        })
    }
    
    var colorPaletteView: some View {
        let palettes = gameModel.loadColorPalettes()
        let keys = palettes.keys.sorted()

        return Picker("Colors",
                      selection: $colorPalette) {
                   ForEach(keys,
                           id: \.self) { name in
                       Text(name)
                   }
               }
               .pickerStyle(.wheel)
               .onChange(of: colorPalette) {
                   gameModel.isSettingsChanging = true
               }
               .disabled(gameModel.isGameStarted)
    }
    
    @ToolbarContentBuilder
    var actionToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                gameModel.isSettingsChanging = false
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                save()
                gameModel.isSettingsChanging = false
                dismiss()
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }
}

extension LifeTrackerSettingsView {
    func colorsFrom(palette: String) -> [Color] {
        let palettes = gameModel.loadColorPalettes()
        var colors = [Color]()
        
        for name in palettes[palette] ?? [] {
            colors.append(Color(hex: name))
        }
        
        return colors
    }
    
    func colorPalette(for name: String) -> some View {
        let colors = colorsFrom(palette: name)
        
        return GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    Rectangle()
                        .fill(color)
                        .frame(width: proxy.size.width / CGFloat(colors.count),
                               height: proxy.size.height)
                }
            }
        }
    }
    
    func save() {
        gameModel.playerCount = playerCount
        gameModel.startingLife = startingLife
        gameModel.colorPalette = colorPalette
        gameModel.initPlayers()
    }
}

#Preview {
    @Previewable @State
    var model = LifeTrackerGameModel()
    
    LifeTrackerSettingsView(gameModel: $model)
}
