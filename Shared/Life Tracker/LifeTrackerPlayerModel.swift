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
            _life = newValue
            if _life <= minLife {
                isDead = true
            }
            
        }
    }
    
    private var _poison: Int = 0
    var poison: Int {
        get {
            return _poison
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
            return _commanderDamage
        }
        set {
            _commanderDamage = newValue
            if _commanderDamage >= maxCommanderDamage {
                isDead = true
            }
        }
    }
    
    init(name:String = "",
         life: Int = 0) {
        self.name = name
        self.life = life
    }
}
