//
//  LifeTrackerPlayerModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI
import ManaKit

enum LifeTrackerPlayerStat {
    case life, poison, energy, commander
    
    var name: String {
        switch self {
        case .life: "Life"
        case .poison: "Poison"
        case .energy: "Energy"
        case .commander: "Commander Damage"
        }
    }
    
    var manaSymbol: String {
        switch self {
        case .poison: "H"
        case .energy: "E"
        case .commander: "Commander"
        default: ""
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
    var color: Color = .clear
    var dices = [DiceViewModel]()
    var isEnabled = true
    var showPoisonCounter = false
    var showEnergyCounter = false
    var showCommanderDamageCounter = false
    
    private var _life: Int = 0
    var life: Int {
        get {
            _life
        }
        set {
            _life = newValue
            if _life <= minLife {
                isDead = true
            }
        }
    }
    
    private var _poison: Int = 0
    var poison: Int {
        get {
            _poison
        }
        set {
            _poison = newValue
            if _poison >= maxPoison {
                isDead = true
            }
        }
    }
    
    private var _commanderDamage: [LifeTrackerPlayerModel: Int] = [:]
    var commanderDamage: [LifeTrackerPlayerModel: Int] {
        get {
            _commanderDamage
        }
        set {
            _commanderDamage = newValue
            for (_,v) in _commanderDamage {
                if v >= maxCommanderDamage {
                    isDead = true
                }
            }
        }
    }
    
//    private var _commanderDamage: Int = 0
//    var commanderDamage: Int {
//        get {
//            _commanderDamage
//        }
//        set {
//            _commanderDamage = newValue
//            if _commanderDamage >= maxCommanderDamage {
//                isDead = true
//            }
//        }
//    }
    
    init(name:String = "",
         life: Int = 0,
         color: Color = .cyan) {
        self.name = name
        self.life = life
        self.color = color
    }
    
    func get(stat: LifeTrackerPlayerStat) -> Int {
        switch stat {
        case .life: life
        case .poison: poison
        case .energy: energy
        default: 0
        }
    }

    func set(stat: LifeTrackerPlayerStat, with value: Int) {
        switch stat {
        case .life:
            life = value
        case .poison:
            poison = value
        case .energy:
            energy = value
        default:
            ()
        }
    }
}

// MARK: - Equatable

extension LifeTrackerPlayerModel: Equatable {
    static func == (lhs: LifeTrackerPlayerModel, rhs: LifeTrackerPlayerModel) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: - Hashable

extension LifeTrackerPlayerModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
