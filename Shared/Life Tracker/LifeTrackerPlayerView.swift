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
                    LifeTrackerPlayerSettingsView( viewModel: $viewModel)
                }
        case .left, .right:
            GeometryReader { proxy in
                let diff = proxy.size.height - proxy.size.width
                sideView
                    .rotationEffect(.degrees(rotation.rawValue))
                    .offset(x: 0,
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
                
                VStack(spacing: 0) {
                    HStack {
                        playerNameView
                        Spacer()
                        editButton
                            .onTapGesture {
                                if viewModel.dices.isEmpty {
                                    isSettingsPresented.toggle()
                                }
                            }
                    }
                    .padding(1)
                    .frame(width: size.width,
                           height: labelHeight)
                    .background(Rectangle().fill(viewModel.color))
                    
                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.width / 2,
                                   height: max(size.height - labelHeight, 0))
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                if viewModel.dices.isEmpty {
                                    decreaseStat()
                                }
                            }
                        plusButton
                            .frame(width: size.width / 2,
                                   height: max(size.height - labelHeight, 0))
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                if viewModel.dices.isEmpty {
                                    increaseStat()
                                }
                            }
                    }
                }
                
                
                lifeView
                    .font(.system(size: size.height / 2))
                    .frame(height: size.height)
                    .opacity(!viewModel.dices.isEmpty ? 0 : 1)

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
                .opacity(viewModel.dices.isEmpty ? 0 : 1)
            }
        }
    }
    
    var sideView: some View {
        GeometryReader { proxy in
            ZStack() {
                let size = computeSize(by: proxy)
                
                VStack(spacing: 0) {
                    HStack {
                        playerNameView
                        Spacer()
                        editButton
                            .onTapGesture {
                                if viewModel.dices.isEmpty {
                                    isSettingsPresented.toggle()
                                }
                            }
                    }
                    .padding(5)
                    .frame(width: size.height,
                           height: labelHeight)
                    .background(Rectangle().fill(viewModel.color))
                    
                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.height / 2,
                                   height: max(size.width - labelHeight, 0))
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                if viewModel.dices.isEmpty {
                                    decreaseStat()
                                }
                            }
                        plusButton
                            .frame(width: size.height / 2,
                                   height: max(size.width - labelHeight, 0))
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                if viewModel.dices.isEmpty {
                                    increaseStat()
                                }
                            }
                    }
                }
                
                lifeView
                    .font(.system(size: size.height / 2))
                    .frame(height: size.height)
                    .opacity(!viewModel.dices.isEmpty ? 0 : 1)

                
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
                .opacity(viewModel.dices.isEmpty ? 0 : 1)
            }
        }
    }
    
    var playerNameView: some View {
        Text(viewModel.name)
            .font(.default)
            .foregroundStyle(viewModel.color)
            .colorInvert()
    }
    
    var editButton: some View {
        Image(systemName: "pencil.line")
            .frame(width: 30.0, height: 30.0)
            .font(.title)
            .foregroundStyle(Color.gray)
            .opacity(!viewModel.dices.isEmpty
                     ? 0
                     : 1)
    }
    
    var minusButton: some View {
        HStack() {
            Image(systemName: "minus")
                .frame(width: 30.0, height: 30.0)
                .font(.title)
                .foregroundStyle(Color.gray)
                .opacity(!viewModel.dices.isEmpty
                         ? 0
                         : 1)
            Spacer()
        }
        .padding()
    }
    
    var plusButton: some View {
        HStack {
            Spacer()
            Image(systemName: "plus")
                .frame(width: 30.0, height: 30.0)
                .font(.title)
                .foregroundStyle(Color.gray)
                .opacity(!viewModel.dices.isEmpty
                         ? 0
                         : 1)
        }
        .padding()
    }
    
    var lifeView: some View {
        Text("\(viewModel.life)")
            .contentTransition(.numericText())
            .foregroundStyle(viewModel.color)
            .colorInvert()
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
    let model4 = LifeTrackerPlayerModel(name: "Player 4",
                                        life: 40)
    let model5 = LifeTrackerPlayerModel(name: "Player 5",
                                        life: 40)
    let model6 = LifeTrackerPlayerModel(name: "Player 6",
                                        life: 40)
    
    HStack(spacing: 1) {
        VStack(spacing: 1) {
            LifeTrackerPlayerView(viewModel: model1,
                                  rotation: .left)
                .onAppear {
                    model1.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                }
            LifeTrackerPlayerView(viewModel: model2,
                                  rotation: .left)
                .onAppear {
                    model2.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                }
            LifeTrackerPlayerView(viewModel: model3,
                                  rotation: .left)
                .onAppear {
                    model3.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                }
        }
        VStack(spacing: 1) {
            LifeTrackerPlayerView(viewModel: model6,
                                  rotation: .right)
                .onAppear {
                    model6.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                }
            LifeTrackerPlayerView(viewModel: model5,
                                  rotation: .right)
                .onAppear {
                    model5.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                }
            LifeTrackerPlayerView(viewModel: model4,
                                  rotation: .right)
                .onAppear {
                    model4.dices.append(DiceViewModel(dice: LifeTrackerDice.d20))
                }
        }
    }
}

