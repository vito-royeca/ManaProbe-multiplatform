//
//  LifeTrackerView.swift
//  Tests iOS
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

struct LifeTrackerMainView: View {
    @State
    var gameModel = LifeTrackerGameModel(playerCount: 3, startingLife: 20)
    
    var body: some View {
        
            VStack {
                playerCountView
//                    .listRowSeparator(.hidden)
                startingLifeView
//                    .listRowSeparator(.hidden)
//                Section {
                    playersView
//                        .listRowSeparator(.hidden)
//                }
            }
//            .listStyle(.plain)
        
        
    }
    
    var playerCountView: some View {
        LabeledContent(content: {
            Picker("Players", selection: $gameModel.playerCount) {
                ForEach((1...self.gameModel.maxPlayers), id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.menu)
            .disabled(gameModel.isGameOver)
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
        }, label: {
            Text("Starting Life")
        })
    }
    
    var playersView: some View {
        GeometryReader { proxy in
            VStack {
                ForEach(gameModel.players, id: \.id) { player in
                    LifeTrackerPlayerView(startingLife: gameModel.startingLife)
                        .frame(height: proxy.size.height / CGFloat(gameModel.playerCount))
                        .border(Color.black, width: 1)
                }
            }
        }
    }
}

struct LifeTrackerPlayerView: View {
    @State
    var viewModel: LifeTrackerPlayerModel
    
    init(startingLife: Int) {
        let model = LifeTrackerPlayerModel()
        model.life = startingLife
        _viewModel = State(wrappedValue: model)
    }

    var body: some View {
//        ZStack {
            HStack {
                Button {
                    viewModel.life -= 1
                } label: {
                    Text("-")
                        .font(.title)
//                        .multilineTextAlignment(.center)
                    //                        .frame(width: .infinity)
                }
                .disabled(viewModel.isDead)
                .buttonStyle(.bordered)
                
                VStack(alignment: .center) {
                    TextField("Edit Name",
                              text: $viewModel.name)
                        .font(.system(size: 20))
                    Text("\(viewModel.life)")
                        .font(.system(size: 80))
                        .foregroundStyle(viewModel.isDead ? Color.red : Color.primary)
                }
                
                Button {
                    viewModel.life += 1
                } label: {
                    Text("+")
                        .font(.title)
                    
                }
                .disabled(viewModel.isDead)
                .buttonStyle(.bordered)
            }
            
            
//        }
    }
}

enum LifeTrackerError: Error {
    case invalidPlayerCount
}

@Observable
class LifeTrackerGameModel {
    let maxPlayers = 6

    var players = [LifeTrackerPlayerModel()]
    
    private var _playerCount: Int = 0
    var playerCount: Int {
        get {
            return _playerCount
        }
        set {
            _playerCount = newValue
            initPlayers()
        }
    }
    
    private var _startingLife: Int = 0
    var startingLife: Int {
        get {
            return _startingLife
        }
        set {
            _startingLife = newValue
            initPlayers()
        }
    }
    
    var isGameOver = false
    var isGameStarted = false
    
    init(playerCount: Int, startingLife: Int) {
//        guard playerCount > 0 else {
//            throw LifeTrackerError.invalidPlayerCount
//        }
        
        self.playerCount = playerCount
        self.startingLife = startingLife
        if self.startingLife <= 0 {
            self.startingLife = 1
        }
    }
    
    func initPlayers() {
        players = [LifeTrackerPlayerModel()]
        
        for _ in 0..<self.playerCount-1 {
            let player = LifeTrackerPlayerModel()
            player.life = self.startingLife
            
            players.append(player)
        }
    }
}


@Observable
class LifeTrackerPlayerModel: Identifiable {
    let id = UUID().uuidString
    let minLife = 0
    let maxPoison = 10
    let maxCommanderDamage = 21

    var isDead = false
    var energy = 0
    var name = ""
    
    private var _life: Int = 0
    var life: Int {
        get {
            return _life
        }
        set {
            if newValue <= minLife {
                _life = minLife
                isDead = true
            } else {
                _life = newValue
            }
        }
    }
    
    private var _poison: Int = 0
    var poison: Int {
        get {
            return _poison
        }
        set {
            if newValue <= 0 {
                _poison = 0
            } else {
                _poison = newValue
                if _poison >= maxPoison {
                    isDead = true
                }
            }
        }
    }
    
    private var _commanderDamage: Int = 0
    var commanderDamage: Int {
        get {
            return _commanderDamage
        }
        set {
            if _commanderDamage >= maxPoison {
                isDead = true
            }
        }
    }
}

#Preview {
    LifeTrackerMainView()
}
