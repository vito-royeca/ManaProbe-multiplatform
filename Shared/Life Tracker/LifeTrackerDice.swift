//
//  LifeTrackerDice.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/30/26.
//

import SwiftUI

enum LifeTrackerDice: String, CaseIterable, Identifiable {
    case d4, d6, d8, d10, d12, d20
    
    var id: Self { self }
    
    var description: String {
        get {
            switch self {
            case .d4: "D4"
            case .d6: "D6"
            case .d8: "D8"
            case .d10: "D10"
            case .d12: "D12"
            case .d20: "D20"
            }
        }
    }
    
    var icon: Image {
        get {
            switch self {
            case .d4: Image("d4")
            case .d6: Image("d6")
            case .d8: Image("d8")
            case .d10: Image("d10")
            case .d12: Image("d12")
            case .d20: Image("d20")
            }
        }
    }
    
    var iconSolid: Image {
        get {
            switch self {
            case .d4: Image("d4 solid")
            case .d6: Image("d6 solid")
            case .d8: Image("d8 solid")
            case .d10: Image("d10 solid")
            case .d12: Image("d12 solid")
            case .d20: Image("d20 solid")
            }
        }
    }
    
    func roll() -> Int {
        switch self {
        case .d4: return Int.random(in: 1...4)
        case .d6: return Int.random(in: 1...6)
        case .d8: return Int.random(in: 1...8)
        case .d10: return Int.random(in: 1...10)
        case .d12: return Int.random(in: 1...12)
        case .d20: return Int.random(in: 1...20)
        }
    }
}
