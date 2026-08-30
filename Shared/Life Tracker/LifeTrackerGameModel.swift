//
//  LifeTrackerGameModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import Foundation
import SwiftUI

@Observable
class LifeTrackerGameModel {
    // MARK: - Constants
    
    static let startingLives = [20, 30, 40]
    static let minStartingLife = 20
    static let minPlayers = 1
    static let maxPlayers = 6
    static let defaultColorPalette = "Electric Rainbow Burst"
    
    
    // MARK: - Settings
    
    @AppStorage("LifeTrackerPlayerName1")
    @ObservationIgnored
    var playerName1 = "Player 1"
    @AppStorage("LifeTrackerPlayerName2")
    @ObservationIgnored
    var playerName2 = "Player 2"
    @AppStorage("LifeTrackerPlayerName3")
    @ObservationIgnored
    var playerName3 = "Player 3"
    @AppStorage("LifeTrackerPlayerName4")
    @ObservationIgnored
    var playerName4 = "Player 4"
    @AppStorage("LifeTrackerPlayerName5")
    @ObservationIgnored
    var playerName5 = "Player 5"
    @AppStorage("LifeTrackerPlayerName6")
    @ObservationIgnored
    var playerName6 = "Player 6"
    
    @AppStorage("LifeTrackerPlayerCount")
    @ObservationIgnored
    var playerCount = LifeTrackerGameModel.minPlayers
    
    @AppStorage("LifeTrackerStartingLife")
    @ObservationIgnored
    var startingLife = LifeTrackerGameModel.minStartingLife
    
    @AppStorage("LifeTrackerColorPalette")
    @ObservationIgnored
    var colorPalette = LifeTrackerGameModel.defaultColorPalette
    
    var isSettingsChanged = false

    // MARK: - Players
    
    var players = [LifeTrackerPlayerModel()]
    
    // MARK: - Game state
    
    var isGameOver = false
    var isGameStarted = false
    var isGamePaused = true
    
    // MARK: - Timer
    
    var timerString: String {
        get {
            let hours = elapsedTime / 3600
            let minutes = elapsedTime / 60
            let seconds = elapsedTime % 60
            if hours > 0 {
                _timerString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                _timerString = String(format: "%02d:%02d", minutes, seconds)
            }
            return _timerString
        }
        set {
            _timerString = newValue
        }
    }
    
    private var timer = Timer()
    private var elapsedTime: Int = 0
    private var _timerString = "00:00:00"
    
    // MARK: - Initializers

    init() {
        initPlayers()
    }
    
    func initPlayers() {
        // checks
        if playerCount < LifeTrackerGameModel.minPlayers {
            playerCount = LifeTrackerGameModel.minPlayers
        }
        if playerCount > LifeTrackerGameModel.maxPlayers {
            playerCount = LifeTrackerGameModel.maxPlayers
        }
        if startingLife < LifeTrackerGameModel.minStartingLife {
            startingLife = LifeTrackerGameModel.minStartingLife
        }
        
        players.removeAll()
        
        let colors = colorsFromPalette()
        for index in 0...playerCount-1 {
            let player = LifeTrackerPlayerModel()
            
            switch index {
            case 0: player.name = playerName1
            case 1: player.name = playerName2
            case 2: player.name = playerName3
            case 3: player.name = playerName4
            case 4: player.name = playerName5
            case 5: player.name = playerName6
            default: ()
            }
            player.life = startingLife
            player.color = colors[index]
            players.append(player)
        }
    }

    // MARK: - Methods
    
    func playPause() {
        isGameStarted
            ? isGamePaused
                ? resume()
                : pause()
            : start()
    }
    
    func stop() {
        isGameOver = true
        isGameStarted = false
        isGamePaused = true

        elapsedTime = 0
        stopTimer()
    }

    func savePlayerNames() {
        for (index, player) in players.enumerated() {
            switch index {
            case 0: playerName1 = player.name
            case 1: playerName2 = player.name
            case 2: playerName3 = player.name
            case 3: playerName4 = player.name
            case 4: playerName5 = player.name
            case 5: playerName6 = player.name
            default: ()
            }
        }
    }

    // MARK: - Private methods

    private func start() {
        isGameOver = false
        isGameStarted = true
        isGamePaused = false
        
        savePlayerNames()
        initPlayers()
        startTimer()
    }
    
    private func pause() {
        isGamePaused = true
        stopTimer()
    }
    
    private func resume() {
        isGamePaused = false
        timerString = "0:00"
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
}

// MARK: - Utilities

extension LifeTrackerGameModel {
    func colorsFromPalette() -> [Color] {
        let palettes = loadColorPalettes()
        var colors = [Color]()
        
        for name in palettes[colorPalette] ?? [] {
            colors.append(Color(hex: name))
        }
        
        return colors
    }
    
    func loadColorPalettes() -> [String: [String]] {
        do {
            if let url = Bundle.main.url(forResource: "6colors", withExtension: "plist") {
                let data = try! Data(contentsOf: url)
                let decoder = PropertyListDecoder()
                let dict = try decoder.decode([String: [String]].self, from: data)
                return dict
            }
        } catch {
            print(error)
        }
    
        return [:]
    }
}
