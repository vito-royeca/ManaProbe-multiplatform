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

enum LifeTransitionColor {
    case still
    case decreasing
    case increasing
    
    var value: Color {
        switch self {
        case .still:
            Color.primary
        case .decreasing:
            Color.red
        case .increasing:
            Color.green
        }
    }
}

struct LifeTrackerPlayerView: View {
    let labelHeight = Double(60)
    @State
    var viewModel: LifeTrackerPlayerModel
    @State
    var rotation: LifeTrackerPlayerViewRotation
    @State
    private var lifeTransitionColor = LifeTransitionColor.still
    @State
    private var isAnimating = false
    @State
    private var isSettingsPresented = false
        
    init(viewModel: LifeTrackerPlayerModel, rotation: LifeTrackerPlayerViewRotation) {
        self.viewModel = viewModel
        self.rotation = rotation
    }
    
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
            ZStack() {
                let size = computeSize(by: proxy)
                
                VStack(spacing: 0) {
                    HStack {
                        playerNameView
                        Spacer()
                        editButton
                            .onTapGesture {
                                isSettingsPresented.toggle()
                            }
                    }
                    .padding(1)
                    .frame(width: size.width,
                           height: labelHeight)
                    .background(Rectangle().fill(viewModel.color))
                    
                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.width / 2,
                                   height: size.height - labelHeight)
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                decreaseStat()
                            }
                        plusButton
                            .frame(width: size.width / 2,
                                   height: size.height - labelHeight)
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                increaseStat()
                            }
                    }
                }
                
                lifeView
                    .font(.system(size: size.height / 2))
                    .frame(height: size.height)
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
                                isSettingsPresented.toggle()
                            }
                    }
                    .padding(5)
                    .frame(width: size.height,
                           height: labelHeight)
                    .background(Rectangle().fill(viewModel.color))
                    
                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.height / 2,
                                   height: size.width - labelHeight)
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                decreaseStat()
                            }
                        plusButton
                            .frame(width: size.height / 2,
                                   height: size.width - labelHeight)
                            .background(Rectangle().fill(viewModel.color))
                            .onTapGesture {
                                increaseStat()
                            }
                    }
                }
                
                lifeView
                    .font(.system(size: size.height / 2))
                    .frame(height: size.height)
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
        Image(systemName: "pencil")
            .frame(width: 30.0, height: 30.0)
            .font(.title)
            .foregroundStyle(Color.gray)
//            .glassEffect()
    }
    
    var minusButton: some View {
        HStack() {
            Image(systemName: "minus")
                .frame(width: 30.0, height: 30.0)
                .font(.title)
                .foregroundStyle(Color.gray)
//                .glassEffect()
                .disabled(viewModel.isDead)
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
//                .glassEffect()
                .disabled(viewModel.isDead)
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
//            if lifeTransitionColor == .still {
//                lifeTransitionColor = .decreasing
//            } else {
//                lifeTransitionColor = .still
//            }
        }
    }
    
    func increaseStat() {
        withAnimation(.easeInOut(duration: 1.0)) {
            viewModel.life += 1
//            if lifeTransitionColor == .still {
//                lifeTransitionColor = .increasing
//            } else {
//                lifeTransitionColor = .still
//            }
        }
    }
}

#Preview {
    @Previewable @State
    var count = 2
    
    NavigationStack {
        VStack(spacing: 0) {
            Picker("Players", selection: $count) {
                ForEach((1...6), id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 10)
            
            Group {
                ForEach(1...count, id: \.self) { index in
                    let model = LifeTrackerPlayerModel(name: "Player \(index)",
                                                       life: 40)
                    LifeTrackerPlayerView(viewModel: model,
                                          rotation: .none)
                    .border(Color.black, width: 1)
                }
            }
            .padding(1)
        }
    }
}
