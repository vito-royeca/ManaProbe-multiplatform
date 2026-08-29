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
    
//    @AppStorage("LifeTrackerPlayerCount")
//    @ObservationIgnored
//    var _playerCount = LifeTrackerGameModel.minPlayers
//    var playerCount: Int {
//        get {
//            _playerCount
//        }
//        set {
//            _playerCount = newValue
//            if _playerCount < LifeTrackerGameModel.minPlayers {
//                _playerCount = LifeTrackerGameModel.minPlayers
//            }
//            if _playerCount > LifeTrackerGameModel.maxPlayers {
//                _playerCount = LifeTrackerGameModel.maxPlayers
//            }
//            initPlayers()
//        }
//    }
//    
//    @AppStorage("LifeTrackerStartingLife")
//    @ObservationIgnored
//    var _startingLife = LifeTrackerGameModel.minStartingLife
//    var startingLife: Int {
//        get {
//            _startingLife
//        }
//        set {
//            _startingLife = newValue
//            if _startingLife < LifeTrackerGameModel.minStartingLife {
//                _startingLife = LifeTrackerGameModel.minStartingLife
//            }
//            initPlayers()
//        }
//    }
//    
//    @AppStorage("LifeTrackerColorPalette")
//    @ObservationIgnored
//    var _colorPalette = LifeTrackerGameModel.defaultColorPalette
//    var colorPalette: String {
//        get {
//            _colorPalette
//        }
//        set {
//            _colorPalette = newValue
//            initPlayers()
//        }
//    }

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
    var isGamePaused = false
    
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
    }
    
    func stop() {
        isGameStarted = false
        isGameOver = true
        isGamePaused = false
    }
    
    func pause() {
        isGamePaused.toggle()
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

