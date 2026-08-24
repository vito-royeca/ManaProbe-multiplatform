//
//  LifeTrackerPlayerModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

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
