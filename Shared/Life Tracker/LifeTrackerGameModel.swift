//
//  LifeTrackerGameModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

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
    var isGamePaused = false
    
    init(playerCount: Int, startingLife: Int) {
//        guard playerCount > 0 else {
//            throw LifeTrackerError.invalidPlayerCount
//        }
        
        self.playerCount = playerCount
        self.startingLife = startingLife
        if self.startingLife <= 0 {
            self.startingLife = 1
        }
        
        initPlayers()
    }
    
    func initPlayers() {
        players = [LifeTrackerPlayerModel()]
        
        for i in 0..<self.playerCount-1 {
            let player = LifeTrackerPlayerModel()
            player.life = self.startingLife
            player.name = "Player \(i+1)"
            
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
