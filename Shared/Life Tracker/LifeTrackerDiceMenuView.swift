//
//  LifeTrackerDiceMenuView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/29/26.
//

import SwiftUI



struct LifeTrackerDiceMenuView: View {
    @State
    private var selectedDice: LifeTrackerDice = .d20

    var onClear: () -> Void
    var onRoll: (LifeTrackerDice) -> Void
    
    var body: some View {
        Menu {
            Picker("Dice: \(selectedDice.description)", selection: $selectedDice) {
                ForEach(LifeTrackerDice.allCases, id: \.self) { dice in
                    dice.iconSolid
                        .tag(dice)
                }
            }
            .pickerStyle(.palette)

            Button("Clear", systemImage: "clear") {
                onClear()
            }
            
            Button("Roll") {
                onClear()
                onRoll(selectedDice)
            }
        } label: {
            Image(systemName: "dice.fill")
                .font(.largeTitle)
        }
    }
}

#Preview {
    LifeTrackerDiceMenuView {
        
    } onRoll: { dice in
        
    }
}
