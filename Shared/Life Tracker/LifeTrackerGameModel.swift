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
    
    var timer = Timer()
    var elapsedTime: Int = 0

    private var _timerString = "00:00:00"
    var timerString: String {
        get {
            let hours = elapsedTime / 3600
            let minutes = elapsedTime / 60
            let seconds = elapsedTime % 60
//            let hoursString = hours > 0 ? String(format: "%02d", hours) : "00"
            _timerString = String(format: "%02d:%02d:%02d", hours,minutes, seconds)
            return _timerString
        }
        set {
            _timerString = newValue
        }
    }

    
    // MARK: - Initializers

    init() {
        stop()
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
        for i in 0...playerCount-1 {
            let player = LifeTrackerPlayerModel()
            player.name = "Player \(i+1)"
            player.life = startingLife
            player.color = colors[i]
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
    
    func start() {
        isGameOver = false
        isGameStarted = true
        isGamePaused = false
        
        startTimer()
    }
    
    func stop() {
        isGameOver = true
        isGameStarted = false
        isGamePaused = true
        
        stopTimer()
        
        elapsedTime = 0
        timer.invalidate()
    }
    
    func pause() {
        isGamePaused = true
        stopTimer()
    }
    
    func resume() {
        isGamePaused = false
        timerString = "0:00"
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    func stopTimer() {
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
