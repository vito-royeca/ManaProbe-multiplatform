//
//  DiceTestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/30/26.
//

import SwiftUI

struct DiceTestView: View {
    @State
    var diceModel:DiceViewModel? = nil

    var body: some View {
        VStack(alignment: .center) {
            LifeTrackerDiceMenuView {
                onDiceClear()
            } onRoll: { dice in
                onDiceRoll(dice: dice)
            }

            Spacer()
            HStack {
                if let diceModel {
                    DiceView(
                        model: diceModel,
                        isTappable: true,
                        color: .cyan)
                    .onAppear {
                        diceModel.roll()
                    }
                } else {
                    EmptyView()
                }
            }
            .tag(diceModel?.id ?? "\(Date())")
        }
        .padding()
    }
}

extension DiceTestView {
    func onDiceClear() {
        diceModel = nil
    }

    func onDiceRoll(dice: LifeTrackerDice) {
        diceModel = DiceViewModel(dice: dice)
    }
}

#Preview {
    DiceTestView()
}
