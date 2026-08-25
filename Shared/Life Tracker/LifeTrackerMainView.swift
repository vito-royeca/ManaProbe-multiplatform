//
//  LifeTrackerMainView.swift
//  Tests iOS
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

struct LifeTrackerMainView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @State
    var gameModel = LifeTrackerGameModel(playerCount: 4, startingLife: 40)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                playButton
                Spacer()
                Text("00:00")
                    .font(.largeTitle)
                Spacer()
                closeButton
            }
            .padding(10)
            
            HStack {
                playerCountView
                startingLifeView
            }
            
            playersView
                .border(Color.black, width: 2)
        }
    }
    
    var playButton: some View {
        Button {
            gameModel.isGamePaused ?
                gameModel.pause()
                :
                gameModel.start()
        } label: {
            let name = gameModel.isGameStarted ?
                "play.fill"
                :
                gameModel.isGamePaused ?
                    "pause.fill"
                    :
                    "play.fill"
            Image(systemName: name)
                .font(.largeTitle)
        }
    }

    var closeButton: some View {
        Button {
            gameModel.isGameStarted ?
              gameModel.stop()
              :
              dismiss()
        } label: {
            Image(systemName: gameModel.isGameStarted ? "stop.fill" : "xmark")
                .font(.largeTitle)
        }
    }
    
    var playerCountView: some View {
        LabeledContent(content: {
            Picker("Players", selection: $gameModel.playerCount) {
                ForEach((1...self.gameModel.maxPlayers), id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.menu)
            .disabled(gameModel.isGameStarted)
        }, label: {
            Text("Players")
        })
    }
    
    var startingLifeView: some View {
        let array:[Int] = [20, 30, 40]
        
        return LabeledContent(content: {
            Picker("Starting Life", selection: $gameModel.startingLife) {
                ForEach(array, id: \.self) { life in
                    Text("\(life)")
                }
            }
            .pickerStyle(.menu)
            .disabled(gameModel.isGameStarted)
        }, label: {
            Text("Starting Life")
        })
    }
    
    var playersView: some View {
        VStack(spacing: 0) {
            ForEach(gameModel.players, id: \.id) { player in
                LifeTrackerPlayerView(startingLife: gameModel.startingLife)
                    .border(Color.black, width: 1)
            }
        }
    }
}



enum LifeTrackerError: Error {
    case invalidPlayerCount
}

#Preview {
    LifeTrackerMainView()
}
