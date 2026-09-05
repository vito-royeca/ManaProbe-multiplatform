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
    var players = [LifeTrackerPlayerModel]()
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
                    initPlayers()
                }
        }
    }
    
    var contentView: some View {
        Form {
            startingLifeView
            
            Section(header: Text("Players")) {
                playerCountView
                playerListView
            }
            
            Section(header: Text("Color")) {
                colorPalette(for: colorPalette)
                    .frame(height: 100)
                colorPaletteView
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
                initPlayers()
                gameModel.isSettingsChanged = true
            }
        }, label: {
            Image(systemName: "person.3")
        })
    }
    
    var playerListView: some View {
        ForEach(players.enumerated(), id: \.offset) { index, player in
            TextField("Name",
                      text: $players[index].name)
                .onChange(of: player.name) { _,_ in
                    gameModel.isSettingsChanged = true
                }
        }
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
                gameModel.isSettingsChanged = true
            }
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
                   gameModel.isSettingsChanged = true
               }
    }
    
    @ToolbarContentBuilder
    var actionToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                gameModel.isSettingsChanged = false
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                save()
                gameModel.isSettingsChanged = false
                dismiss()
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }
}

extension LifeTrackerSettingsView {
    func initPlayers() {
        let colors = colorsFrom(palette: colorPalette)
        
        players.removeAll()
        for index in 0...playerCount-1 {
            let player = LifeTrackerPlayerModel()
            let origPlayer = index <= gameModel.playerCount-1
                ? gameModel.players[index]
                : nil
            player.name = origPlayer?.name ?? "New Player"
            player.life = startingLife
            player.color = /*origPlayer?.color ?? */colors[index]
            players.append(player)
        }
    }
    
    func save() {
        gameModel.playerCount = playerCount
        gameModel.startingLife = startingLife
        gameModel.colorPalette = colorPalette
        for (index, player) in players.enumerated() {
            switch index {
            case  0: gameModel.playerName1 = player.name
            case  1: gameModel.playerName2 = player.name
            case  2: gameModel.playerName3 = player.name
            case  3: gameModel.playerName4 = player.name
            case  4: gameModel.playerName5 = player.name
            case  5: gameModel.playerName6 = player.name
            default: ()
            }
        }
        gameModel.initPlayers()
    }
    
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
}

#Preview {
    @Previewable @State
    var model = LifeTrackerGameModel()
    
    LifeTrackerSettingsView(gameModel: $model)
}
