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
    // MARK: - Constants
    let labelHeight = Double(60)
    
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

                lifeView
                    .font(.system(size: size.height * 0.6))
                    .fixedSize()
                    .frame(width: size.width,
                           height: size.height)

                HStack {
                    let dWidth = size.width / 2
                    let dHeight = size.height / 2
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
        }
    }
    
    var sideView: some View {
        GeometryReader { proxy in
            ZStack {
                let size = computeSize(by: proxy)
                
                mainView
                    .frame(width: size.height,
                           height: size.width)

                lifeView
                    .font(.system(size: size.height * 0.6))
                    .fixedSize()
                    .frame(width: size.width / 2,
                           height: size.height / 2)

                HStack {
                    let dWidth = (size.height / 2)
                    let dHeight = size.height / 2
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
        }
    }
    
    var mainView: some View {
        VStack(spacing: 0) {
            playerNameView
            LifeTrackerCounterView(player: $viewModel,
                                   stat: .life,
                                   showStat: false)
        }
    }

    var playerNameView: some View {
        HStack(spacing: 0) {
            Text(viewModel.name)
                .font(.default)
                .foregroundStyle(viewModel.color)
                .colorInvert()
            Spacer()
            
            Image(systemName: "pencil.line")
                .frame(width: 30.0, height: 30.0)
                .font(.title)
                .foregroundStyle(Color.gray)
                .opacity(!viewModel.isEnabled
                         ? 0
                         : 1)
                .onTapGesture {
                    if viewModel.isEnabled {
                        isSettingsPresented.toggle()
                    }
                }
        }
        .background(Rectangle().fill(viewModel.color))
    }
    
    var lifeView: some View {
        Text("\(viewModel.get(stat: .life))")
            .monospacedDigit()
            .contentTransition(.numericText())
            .foregroundStyle(viewModel.color)
            .colorInvert()
            .opacity(!viewModel.isEnabled ? 0 : 1)
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
                                        life: 40)
    let model2 = LifeTrackerPlayerModel(name: "Player 2",
                                        life: 40)
    let model3 = LifeTrackerPlayerModel(name: "Player 3",
                                        life: 40)
    
    VStack(spacing: 1) {
        HStack(spacing: 1) {
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
                model2.isEnabled = false
            }
    }
}

