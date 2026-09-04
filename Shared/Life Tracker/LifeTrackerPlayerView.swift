//
//  LifeTrackerPlayerView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

enum LifeTrackerPlayerViewRotation: Double {
    case none = 0
    case left = 90
    case right = -90
    case upsideDown = 180
}

struct LifeTrackerPlayerView: View {
    // MARK: - Variables

    @State
    var viewModel: LifeTrackerPlayerModel
    @State
    var rotation: LifeTrackerPlayerViewRotation
    @State
    private var isSettingsPresented = false

    // MARK: - Initializers
    
    init(viewModel: LifeTrackerPlayerModel,
         rotation: LifeTrackerPlayerViewRotation) {
        self.viewModel = viewModel
        self.rotation = rotation
    }
    
    // MARK: - UI Variables
    
    var body: some View {
        switch rotation {
        case .none, .upsideDown:
            normalView
                .rotationEffect(.degrees(rotation.rawValue))
                .sheet(isPresented: $isSettingsPresented) {
                    LifeTrackerPlayerSettingsView(viewModel: $viewModel)
                }
        case .left, .right:
            GeometryReader { proxy in
                let diff = proxy.size.height - proxy.size.width
                sideView
                    .rotationEffect(.degrees(rotation.rawValue))
                    .offset(x: rotation == .left
                                ? -diff/2
                                : diff/2,
                            y: rotation == .left
                                ? -diff/2
                                : diff/2)
                    .sheet(isPresented: $isSettingsPresented) {
                        LifeTrackerPlayerSettingsView(viewModel: $viewModel)
                    }
            }
        }
    }
    
    var normalView: some View {
        GeometryReader { proxy in
            ZStack {
                let size = computeSize(by: proxy)
                
                mainView
                    .frame(width: size.width,
                           height: size.height)

                HStack {
                    let dWidth = size.width * 0.6
                    let dHeight = size.height * 0.6
                    ForEach(viewModel.dices, id: \.id) { dice in
                        DiceView(model: dice,
                                 isTappable: true,
                                 color: viewModel.color,
                                 colorConvert: true)
                        .frame(width: dWidth,
                               height: dHeight)
                        .onAppear {
                            dice.roll()
                        }
                    }
                }
                .opacity(viewModel.isEnabled ? 0 : 1)
            }
            .background(
                RoundedRectangle(cornerRadius: 20,
                                 style: .continuous)
                    .fill(viewModel.color)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20,
                                 style: .continuous)
                    .stroke(.black, lineWidth: 1)
            }
        }
        
    }
    
    var sideView: some View {
        GeometryReader { proxy in
            ZStack {
                let size = computeSize(by: proxy)
                
                mainView
                    .frame(width: size.height,
                           height: size.width)

                HStack {
                    let dWidth = (size.height * 0.6) - LifeTrackerCounterView.labelHeight
                    let dHeight = (size.height * 0.6) - LifeTrackerCounterView.labelHeight
                    ForEach(viewModel.dices, id: \.id) { dice in
                        DiceView(model: dice,
                                 isTappable: true,
                                 color: viewModel.color,
                                 colorConvert: true)
                        .frame(width: dWidth,
                               height: dHeight)
                        .onAppear {
                            dice.roll()
                        }
                    }
                }
                .opacity(viewModel.isEnabled ? 0 : 1)
            }
            .background(
                RoundedRectangle(cornerRadius: 20,
                                 style: .continuous)
                    .fill(viewModel.color)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20,
                                 style: .continuous)
                    .stroke(.black, lineWidth: 1)
            }
        }
    }
    
    var mainView: some View {
        GeometryReader { proxy in
            let size = computeSize(by: proxy)

            VStack(spacing: 0) {
                LifeTrackerCounterView(player: $viewModel,
                                       stat: .life,
                                       isSettingsPresented: $isSettingsPresented)
                if (viewModel.showPoisonCounter ||
                   viewModel.showEnergyCounter) &&
                   viewModel.isEnabled {
                    let divisor =  viewModel.showPoisonCounter &&
                        viewModel.showEnergyCounter
                        ? CGFloat(2)
                        : CGFloat(1)
                    let width = size.width / divisor
                    let height = size.height / 3
                    
                    HStack(spacing: 0) {
                        if viewModel.showPoisonCounter  {
                            poisonView
                                .frame(width: width,
                                       height: height)
                                .background(
                                    poisonRectangleView
                                        .fill(viewModel.color)
                                )
                                .overlay {
                                    poisonRectangleView
                                        .stroke(.gray, lineWidth: 1)
                                }
                        }
                        if viewModel.showEnergyCounter {
                            energyView
                                .frame(width: width,
                                       height: height)
                                .background(
                                    energyRectangleView
                                        .fill(viewModel.color)
                                        
                                )
                                .overlay {
                                    energyRectangleView
                                        .stroke(.gray, lineWidth: 1)
                                }
                        }
                    }
                }
            }
        }
    }

    var lifeView: some View {
        Text("\(viewModel.get(stat: .life))")
            .monospacedDigit()
            .contentTransition(.numericText())
            .foregroundStyle(viewModel.color)
            .colorInvert()
            .opacity(!viewModel.isEnabled ? 0 : 1)
    }
    
    var poisonView: some View {
        LifeTrackerCounterView(player: $viewModel,
                               stat: .poison)
    }
    
    var energyView: some View {
        LifeTrackerCounterView(player: $viewModel,
                               stat: .energy)
    }
    
    var poisonRectangleView: UnevenRoundedRectangle {
        let bottomLeading = CGFloat(20)
        var bottomTrailing = CGFloat(20)
        
        if viewModel.showPoisonCounter && viewModel.showEnergyCounter {
            bottomTrailing = CGFloat(0)
        }
        
        return UnevenRoundedRectangle(cornerRadii: .init(
            topLeading: 0,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            topTrailing: 0),
                                      style: .continuous)
    }
    
    var energyRectangleView: UnevenRoundedRectangle {
        var bottomLeading = CGFloat(20)
        let bottomTrailing = CGFloat(20)
        
        if viewModel.showPoisonCounter && viewModel.showEnergyCounter {
            bottomLeading = CGFloat(0)
        }
        
        return UnevenRoundedRectangle(cornerRadii: .init(
            topLeading: 0,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            topTrailing: 0),
                                      style: .continuous)
    }
}

extension LifeTrackerPlayerView {
    func computeSize(by proxy: GeometryProxy) -> CGSize {
        var width = CGFloat(0)
        var height = CGFloat(0)
        
        switch rotation {
        case .none, .upsideDown:
            width = proxy.size.width
            height = proxy.size.height >= proxy.size.width
                ? proxy.size.width
                : proxy.size.height
        case .left, .right:
            width = proxy.size.width
            height = proxy.size.height
        }
        
        return CGSize(width: width, height: height)
    }

    func decreaseStat() {
        withAnimation(.easeInOut(duration: 1.0)) {
            viewModel.life -= 1
        }
    }
    
    func increaseStat() {
        withAnimation(.easeInOut(duration: 1.0)) {
            viewModel.life += 1
        }
    }
}

#Preview {
    let model1 = LifeTrackerPlayerModel(name: "Player 1",
                                        life: 40,
                                        color: Color(hex: "01BEFE"))
    let model2 = LifeTrackerPlayerModel(name: "Player 2",
                                        life: 40,
                                        color: Color(hex: "FFDDOO"))
    let model3 = LifeTrackerPlayerModel(name: "Player 3",
                                        life: 40,
                                        color: Color(hex: "FF7DOO"))
    
    VStack(spacing: 2) {
        HStack(spacing: 2) {
            LifeTrackerPlayerView(viewModel: model1,
                                  rotation: .left)
            LifeTrackerPlayerView(viewModel: model2,
                                  rotation: .right)
                .onAppear {
                    model2.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                    model2.isEnabled = false
                }
        }
        LifeTrackerPlayerView(viewModel: model3,
                              rotation: .none)
            .onAppear {
                model3.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
//                model3.isEnabled = false
            }
    }
    .background(Color.black)
}

