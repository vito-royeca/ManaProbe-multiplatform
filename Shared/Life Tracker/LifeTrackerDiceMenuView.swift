//
//  LifeTrackerDiceMenuView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/29/26.
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
}

struct LifeTrackerDiceMenuView: View {
    @State
    private var isForAllPlayers: Bool = true
    @State
    private var selectedDice: LifeTrackerDice = .d20
    @State
    private var quantity: Int = 1

    var body: some View {
        Menu {
            Picker("Dice: \(selectedDice.description)", selection: $selectedDice) {
                ForEach(LifeTrackerDice.allCases, id: \.self) { dice in
                    dice.iconSolid
                        .tag(dice)
                }
            }
            .pickerStyle(.palette)

            Stepper(value: $quantity) {
                Text("Quantity: \(quantity)")
            }
            
            Toggle(isOn: $isForAllPlayers) {
                Text("All players")
                Text("Roll the dice\(quantity > 1 ? "s" : "") for all players")
            }
                .menuActionDismissBehavior(.disabled)
            
            Button("Roll") {
                rollDice()
            }
        } label: {
            Image(systemName: "dice.fill")
                .font(.largeTitle)
        }
    }
}

extension LifeTrackerDiceMenuView {
    func rollDice() {
        
    }
}

#Preview {
    LifeTrackerDiceMenuView()
}
