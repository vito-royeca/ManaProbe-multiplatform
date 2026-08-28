//
//  LifeTrackerGameModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

@Observable
class LifeTrackerGameModel {
    let startingLifeArray = [20, 30, 40]
    let minStartingLife = 20
    let minPlayers = 1
    let maxPlayers = 6

    var players = [LifeTrackerPlayerModel()]
    
    var _playerCount = 0
    var playerCount: Int {
        get {
            _playerCount
        }
        set {
            _playerCount = newValue
            if _playerCount < minPlayers {
                _playerCount = minPlayers
            }
            if _playerCount > maxPlayers {
                _playerCount = maxPlayers
            }
        }
    }
    var _startingLife = 0
    var startingLife: Int {
        get {
            _startingLife
        }
        set {
            _startingLife = newValue
            if _startingLife < minStartingLife {
                _startingLife = minStartingLife
            }
        }
    }
    
    var isGameOver = false
    var isGameStarted = false
    var isGamePaused = false
    
    init(playerCount: Int, startingLife: Int) throws {
        self.playerCount = playerCount
        self.startingLife = startingLife
        
        initPlayers()
    }
    
    func initPlayers() {
        players.removeAll()
        
        for i in 0...playerCount-1 {
            let player = LifeTrackerPlayerModel()
            player.name = "Player \(i+1)"
            player.life = startingLife
            players.append(player)
        }
    }
    
    func start() {
        isGameStarted = true
        isGameOver = false
        isGamePaused = false
    }
    
    func stop() {
        isGameStarted = false
        isGameOver = true
        isGamePaused = false
    }
    
    func pause() {
        isGamePaused.toggle()
    }
}
