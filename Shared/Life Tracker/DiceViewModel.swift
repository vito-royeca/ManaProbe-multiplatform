//
//  DiceViewModel.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/30/26.
//

import SwiftUI

@Observable
class DiceViewModel: Identifiable, Equatable, Hashable {
    static func == (lhs: DiceViewModel, rhs: DiceViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID().uuidString
    
    var isAnimating = false
    var value = 0
    var dice: LifeTrackerDice
    var isWinner = false

    init(dice: LifeTrackerDice = .d20) {
        self.dice = dice
    }
    
    func roll() {
        let duration = Double.random(in: 0...1)

        withAnimation(Animation.easeInOut(duration: duration)) {
            isAnimating = true
        }
                
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.value = self.dice.roll()
            self.isAnimating = false
        }
    }
}
