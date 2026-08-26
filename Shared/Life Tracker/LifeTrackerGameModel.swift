//
//  LifeTrackerGameModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

enum LifeTrackerError: Error {
    case invalidPlayerCount
}

@Observable
class LifeTrackerGameModel {
    let minPlayers = 1
    let maxPlayers = 6

    var players = [LifeTrackerPlayerModel()]
    var playerCount = 0
    var startingLife = 0
    
    var isGameOver = false
    var isGameStarted = false
    var isGamePaused = false
    
    init(playerCount: Int, startingLife: Int) throws {
        guard playerCount >= minPlayers &&
              playerCount <= maxPlayers else {
            throw LifeTrackerError.invalidPlayerCount
        }
        
        self.playerCount = playerCount
        self.startingLife = startingLife
        if self.startingLife <= 0 {
            self.startingLife = 1
        }
        
        initPlayers()
    }
    
    func initPlayers() {
        players.removeAll()
        
        for i in 0...self.playerCount-1 {
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
