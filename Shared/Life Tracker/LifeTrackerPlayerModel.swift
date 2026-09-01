//
//  LifeTrackerPlayerModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

enum LifeTrackerPlayerStat {
    case life, poison, energy
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
    
    private var _commanderDamage: Int = 0
    var commanderDamage: Int {
        get {
            _commanderDamage
        }
        set {
            _commanderDamage = newValue
            if _commanderDamage >= maxCommanderDamage {
                isDead = true
            }
        }
    }
    
    init(name:String = "",
         life: Int = 0,
         color: Color = .cyan) {
        self.name = name
        self.life = life
        self.color = color
    }
    
    func get(stat: LifeTrackerPlayerStat) -> Int {
        switch stat {
        case .life:
            life
        case .poison:
            poison
        case .energy:
            energy
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
