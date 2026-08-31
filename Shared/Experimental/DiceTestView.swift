//
//  DiceTestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/30/26.
//

import SwiftUI

@Observable
class DiceTestViewModel: Identifiable {
    let id = UUID().uuidString
    var diceModels = [DiceViewModel]()
}

struct DiceTestView: View {
    @State
    var viewModel = DiceTestViewModel()

    var body: some View {
        VStack(alignment: .center) {
            LifeTrackerDiceMenuView {
                onDiceClear()
            } onRoll: { dice in
                onDiceRoll(dice: dice)
            }

            Spacer()
            HStack {
                ForEach(viewModel.diceModels, id: \.id) { diceModel in
                    VStack {
                        DiceView(
                            model: diceModel,
                            isTappable: true,
                            color: .cyan)
                            .onAppear {
                                diceModel.roll()
                            }
                    }
                }
            }
        }
        .padding()
    }
}

extension DiceTestView {
    func onDiceClear() {
        viewModel.diceModels.removeAll()
    }

    func onDiceRoll(dice: LifeTrackerDice) {
        viewModel.diceModels.append(DiceViewModel(dice: dice))
    }
}

#Preview {
    DiceTestView()
}
