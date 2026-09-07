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
//    @State
//    var players: [LifeTrackerPlayerModel] = []
    @State
    private var isSettingsPresented: Bool = false
    @State
    private var isStopPresented: Bool = false
    
    init() {
        let model = LifeTrackerGameModel()
        _gameModel = State(wrappedValue: model)
//        _players = State(wrappedValue: gameModel.players.map { $0 })
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                playPauseButton
                stopButton
                timerView
                Spacer()
                diceMenuView
                settingsButton
                closeButton
            }
            playersView
        }
        .background(Color.black)
        .sheet(isPresented: $isSettingsPresented) {
            LifeTrackerSettingsView(gameModel: $gameModel)
        }
        .onAppear {
            // prevent screen lock
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    var playPauseButton: some View {
        Button {
            gameModel.playPause()
        } label: {
            let name = gameModel.isGamePaused
                ? "play.fill"
                : "pause.fill"
            Image(systemName: name)
                .font(.largeTitle)
        }
    }
    
    var stopButton: some View {
        Button {
            isStopPresented.toggle()
        } label: {
            Image(systemName: "stop.fill")
                .font(.largeTitle)
        }
        .confirmationDialog("Game Stop Confirmation",
                            isPresented: $isStopPresented) {
            Button("Your current will game reset. Are you sure?",
                   role: .destructive) {
                gameModel.stop()
            }
        }
        .disabled(!gameModel.isGameStarted)
    }

    var settingsButton: some View {
        Button {
            isSettingsPresented.toggle()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.largeTitle)
        }
        .disabled(gameModel.isGameStarted)
    }

    var closeButton: some View {
        Button {
            gameModel.savePlayerNames()
            // enable screen lock
            UIApplication.shared.isIdleTimerDisabled = false
            dismiss()
        } label: {
            Image(systemName: gameModel.isGameStarted ? "stop.fill" : "xmark")
                .font(.largeTitle)
        }
        .disabled(gameModel.isGameStarted)
    }

    var timerView: some View {
        Text(gameModel.timerString)
            .font(.largeTitle)
            .foregroundStyle(Color.white)
            .monospacedDigit()
    }

    var diceMenuView: some View {
        LifeTrackerDiceMenuView {
            onDiceClear()
        } onRoll: { dice in
            onDiceRoll(dice: dice)
        }
    }

    var playersView: some View {
        Group {
            if gameModel.isSettingsChanged {
                EmptyView()
            } else {
                switch gameModel.playerCount {
                case 1: onePlayerView
                case 2: twoPlayersView
                case 3: threePlayersView
                case 4: fourPlayersView
                case 5: fivePlayersView
                case 6: sixPlayersView
                default: Text("Not Implemented")
                }
            }
        }
    }
    
    var onePlayerView: some View {
        LifeTrackerPlayerView(viewModel: $gameModel.players[0],
                              otherPlayers: [],
                              rotation: .none)
    }
    
    var twoPlayersView: some View {
        Group {
            if gameModel.players.count != 2 {
                EmptyView()
            } else {
                let view1 = LifeTrackerPlayerView(viewModel: $gameModel.players[0],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[0]),
                                                  rotation: .upsideDown)
                let view2 = LifeTrackerPlayerView(viewModel: $gameModel.players[1],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[1]),
                                                  rotation: .none)
                    
                VStack(spacing: 2) {
                    view1
                    view2
                }
            }
        }
    }
    
    var threePlayersView: some View {
        Group {
            if gameModel.players.count != 3 {
                EmptyView()
            } else {
                let view1 = LifeTrackerPlayerView(viewModel: $gameModel.players[0],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[0]),
                                                  rotation: .left)
                let view2 = LifeTrackerPlayerView(viewModel: $gameModel.players[1],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[1]),
                                                  rotation: .right)
                let view3 = LifeTrackerPlayerView(viewModel: $gameModel.players[2],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[2]),
                                                  rotation: .none)
                    
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        view1
                        view2
                    }
                    view3
                }
            }
        }
    }
    
    var fourPlayersView: some View {
        Group {
            if gameModel.players.count != 4 {
                EmptyView()
            } else {
                let view1 = LifeTrackerPlayerView(viewModel: $gameModel.players[0],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[0]),
                                                  rotation: .left)
                let view2 = LifeTrackerPlayerView(viewModel: $gameModel.players[1],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[1]),
                                                  rotation: .left)
                let view3 = LifeTrackerPlayerView(viewModel: $gameModel.players[2],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[2]),
                                                  rotation: .right)
                let view4 = LifeTrackerPlayerView(viewModel: $gameModel.players[3],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[3]),
                                                  rotation: .right)

                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        view1
                        view4
                    }
                    HStack(spacing: 2) {
                        view2
                        view3
                    }
                }
            }
        }
    }
    
    var fivePlayersView: some View {
        Group {
            if gameModel.players.count != 5 {
                EmptyView()
            } else {
                let view1 = LifeTrackerPlayerView(viewModel: $gameModel.players[0],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[0]),
                                                  rotation: .left)
                let view2 = LifeTrackerPlayerView(viewModel: $gameModel.players[1],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[1]),
                                                  rotation: .left)
                let view3 = LifeTrackerPlayerView(viewModel: $gameModel.players[2],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[2]),
                                                  rotation: .right)
                let view4 = LifeTrackerPlayerView(viewModel: $gameModel.players[3],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[3]),
                                                  rotation: .right)
                let view5 = LifeTrackerPlayerView(viewModel: $gameModel.players[4],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[4]),
                                                  rotation: .right)

                HStack(spacing: 2) {
                    VStack(spacing: 2) {
                        view1
                        view2
                    }
                    VStack(spacing: 2) {
                        view5
                        view4
                        view3
                    }
                }
            }
        }
    }
    
    var sixPlayersView: some View {
        Group {
            if gameModel.players.count != 6 {
                EmptyView()
            } else {
                let view1 = LifeTrackerPlayerView(viewModel: $gameModel.players[0],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[0]),
                                                  rotation: .left)
                let view2 = LifeTrackerPlayerView(viewModel: $gameModel.players[1],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[1]),
                                                  rotation: .left)
                let view3 = LifeTrackerPlayerView(viewModel: $gameModel.players[2],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[2]),
                                                  rotation: .left)
                let view4 = LifeTrackerPlayerView(viewModel: $gameModel.players[3],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[3]),
                                                  rotation: .right)
                let view5 = LifeTrackerPlayerView(viewModel: $gameModel.players[4],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[4]),
                                                  rotation: .right)
                let view6 = LifeTrackerPlayerView(viewModel: $gameModel.players[5],
                                                  otherPlayers: gameModel.playersExcept(player: gameModel.players[5]),
                                                  rotation: .right)

                HStack(spacing: 2) {
                    VStack(spacing: 2) {
                        view1
                        view2
                        view3
                    }
                    VStack(spacing: 2) {
                        view6
                        view5
                        view4
                    }
                }
            }
        }
    }
}

extension LifeTrackerMainView {
    func onDiceClear() {
        for player in gameModel.players {
            player.dices.removeAll()
            player.isEnabled = true
        }
    }

    func onDiceRoll(dice: LifeTrackerDice) {
        for player in gameModel.players {
            let dice = DiceViewModel(dice: dice)
            player.dices.append(dice)
            player.isEnabled = false
        }
    }
}

#Preview {
    LifeTrackerMainView()
}
