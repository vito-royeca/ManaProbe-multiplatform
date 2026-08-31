//
//  DiceTestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/30/26.
//

import SwiftUI

struct DiceTestView: View {
    @State
    var diceModels = [DiceViewModel]()
    

    var body: some View {
        VStack(alignment: .center) {
            LifeTrackerDiceMenuView {
                onDiceClear()
            } onRoll: { dice in
                onDiceRoll(dice: dice)
            }

            Spacer()
            HStack {
                ForEach(diceModels.enumerated(), id: \.offset) { _, model in
                    DiceView(
                        model: model,
                        isTappable: true,
                        color: .cyan)
                    .tag(model.id)
                    .onAppear {
                        model.roll()
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

extension DiceTestView {
    func onDiceClear() {
        diceModels.removeAll()
    }

    func onDiceRoll(dice: LifeTrackerDice) {
        for _ in 0...Int.random(in: 1...2) {
            let diceModel = DiceViewModel(dice: dice)
            diceModels.append(diceModel)
        }
    }
}

#Preview {
    DiceTestView()
}
