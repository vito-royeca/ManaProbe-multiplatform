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
    var gameModel: LifeTrackerGameModel

    init() {
        do {
            let model = try LifeTrackerGameModel(playerCount: 3,
                                                 startingLife: 40)
            _gameModel = State(wrappedValue: model)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

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
//                .border(Color.black, width: 2)
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
            Picker("Players",
                   selection: $gameModel.playerCount) {
                ForEach((1...self.gameModel.maxPlayers),
                        id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.menu)
            .onChange(of: gameModel.playerCount) {
                gameModel.initPlayers()
            }
            .disabled(gameModel.isGameStarted)
        }, label: {
            Text("Players")
        })
    }
    
    var startingLifeView: some View {
        return LabeledContent(content: {
            Picker("Starting Life",
                   selection: $gameModel.startingLife) {
                ForEach(gameModel.startingLifeArray,
                        id: \.self) { life in
                    Text("\(life)")
                }
            }
            .pickerStyle(.menu)
            .onChange(of: gameModel.startingLife) {
                gameModel.initPlayers()
            }
            .disabled(gameModel.isGameStarted)
        }, label: {
            Text("Starting Life")
        })
    }
    
    var playersView: some View {
        Group {
            switch gameModel.playerCount {
            case 1:
                onePlayerView
            case 2:
                twoPlayersView
            case 3:
                threePlayersView
            case 4:
                fourPlayersView
            case 5:
                fivePlayersView
            case 6:
                sixPlayersView
            default:
                Text("Not Implemented")
            }
        }
    }
    
    var onePlayerView: some View {
        ForEach(gameModel.players.enumerated(), id: \.offset) { index, player in
            LifeTrackerPlayerView(viewModel: player,
                                  rotation: .none)
        }
    }
    
    var twoPlayersView: some View {
        VStack(spacing: 1) {
            ForEach(gameModel.players.enumerated(), id: \.offset) { index, player in
                switch index {
                case 0:
                    LifeTrackerPlayerView(viewModel: player,
                                          rotation: .upsideDown)
//                        .border(Color.black, width: 1)
                case 1:
                    LifeTrackerPlayerView(viewModel: player,
                                          rotation: .none)
                default:
                    EmptyView()
                }
                
            }
        }
    }
    
    var threePlayersView: some View {
        Group {
            if gameModel.players.count != 3 {
                EmptyView()
            } else {
                let view1 = LifeTrackerPlayerView(viewModel: gameModel.players[0],
                                                  rotation: .left)
                    
                let view2 = LifeTrackerPlayerView(viewModel: gameModel.players[1],
                                                  rotation: .right)
                    
                let view3 = LifeTrackerPlayerView(viewModel: gameModel.players[2],
                                                  rotation: .none)
                    
                VStack(spacing: 1) {
                    HStack(spacing: 1) {
                        view1
                        view2
                    }
                    view3
                }
            }
        }
    }
    
    var fourPlayersView: some View {
        VStack(spacing: 0) {
            ForEach(gameModel.players.enumerated(), id: \.offset) { index, player in
                LifeTrackerPlayerView(viewModel: player,
                                      rotation: .none)
            }
        }
    }
    
    var fivePlayersView: some View {
        VStack(spacing: 0) {
            ForEach(gameModel.players.enumerated(), id: \.offset) { index, player in
                LifeTrackerPlayerView(viewModel: player,
                                      rotation: .none)
            }
        }
    }
    
    var sixPlayersView: some View {
        VStack(spacing: 0) {
            ForEach(gameModel.players.enumerated(), id: \.offset) { index, player in
                LifeTrackerPlayerView(viewModel: player,
                                      rotation: .none)
            }
        }
    }
}

#Preview {
    LifeTrackerMainView()
}
