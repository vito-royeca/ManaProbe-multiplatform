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
    static let startingLives = [20, 30, 40]
    static let minStartingLife = 20
    static let minPlayers = 1
    static let maxPlayers = 6
    static let defaultColorPalette = "Electric Rainbow Burst"

    var players = [LifeTrackerPlayerModel()]
    
    @AppStorage("LifeTrackerPlayerCount")
    @ObservationIgnored
    var playerCount = LifeTrackerGameModel.minPlayers
    
    @AppStorage("LifeTrackerStartingLife")
    @ObservationIgnored
    var startingLife = LifeTrackerGameModel.minStartingLife
    
    @AppStorage("LifeTrackerColorPalette")
    @ObservationIgnored
    var colorPalette = LifeTrackerGameModel.defaultColorPalette

    var isSettingsChanging = false
    var isGameOver = false
    var isGameStarted = false
    var isGamePaused = true
    var timerStart: Date? = nil
    var timerEnd: Date? = nil
    
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
        for i in 0...playerCount-1 {
            let player = LifeTrackerPlayerModel()
            player.name = "Player \(i+1)"
            player.life = startingLife
            player.color = colors[i]
            players.append(player)
        }
    }
    
    func start() {
        isGameStarted = true
        isGameOver = false
        isGamePaused = false
        timerStart = Date()
    }
    
    func stop() {
        isGameStarted = false
        isGameOver = true
        isGamePaused = true
        timerStart = nil
        timerEnd = nil
    }
    
    func pause() {
        isGamePaused = true
        timerEnd = Date()
    }
    
    func resume() {
        if let timerEnd {
            let interval = Date().timeIntervalSince(timerEnd)
            timerStart = Date(timeIntervalSinceNow: -interval)
        }
        timerEnd = nil
        isGamePaused = false
    }
    
    func pausedTime() -> String {
        if let timerEnd {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: timerEnd)
        } else {
            return "0:00"
        }
    }
    
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
