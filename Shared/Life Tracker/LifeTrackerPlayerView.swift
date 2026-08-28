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
    let labelHeight = Double(30)
    
    @State
    var viewModel: LifeTrackerPlayerModel
    @State
    var rotation: LifeTrackerPlayerViewRotation
    @State
    var transitionColor: Color = .primary
    
    init(viewModel: LifeTrackerPlayerModel, rotation: LifeTrackerPlayerViewRotation) {
        self.viewModel = viewModel
        self.rotation = rotation
    }

    var body: some View {
        switch rotation {
        case .none, .upsideDown:
            normalView
                .rotationEffect(.degrees(rotation.rawValue))
        case .left, .right:
            GeometryReader { proxy in
                let diff = proxy.size.height - proxy.size.width
                sideView
                    .rotationEffect(.degrees(rotation.rawValue))
                    .offset(x: 0, y: rotation == .left ? -diff/2 : diff/2)
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
                        Image(systemName: "gear")
                    }
                    .padding()
                    .frame(width: size.width,
                           height: labelHeight)
                    .background(Rectangle().fill(Color.indigo))
                    

                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.width / 2,
                                   height: size.height - labelHeight)
                            .background(Rectangle().fill(Color.cyan))
                            .onTapGesture {
                                decreaseStat()
                            }
                        plusButton
                            .frame(width: size.width / 2,
                                   height: size.height - labelHeight)
                            .background(Rectangle().fill(Color.gray))
                            .onTapGesture {
                                increaseStat()
                            }
                    }
                }
    
                lifeView
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
                        Image(systemName: "gear")
                    }
                    .padding()
                    .frame(width: size.height,
                           height: labelHeight)
                    .background(Rectangle().fill(Color.indigo))
                    
                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.height / 2,
                                   height: size.width - labelHeight)
                            .background(Rectangle().fill(Color.cyan))
                            .onTapGesture {
                                decreaseStat()
                            }
                        plusButton
                            .frame(width: size.height / 2,
                                   height: size.width - labelHeight)
                            .background(Rectangle().fill(Color.gray))
                            .onTapGesture {
                                increaseStat()
                            }
                    }
                }
            
                lifeView
                    .frame(height: size.height)
            }
        }
    }
    
    var playerNameView: some View {
        Text(viewModel.name)
            .font(.system(size: 20))
    }
    
    var minusButton: some View {
        HStack() {
            Image(systemName: "minus.circle")
                .imageScale(.large)
                .disabled(viewModel.isDead)
            Spacer()
        }
        .padding()
    }
    
    var plusButton: some View {
        HStack {
            Spacer()
            Image(systemName: "plus.circle")
                .imageScale(.large)
                .disabled(viewModel.isDead)
        }
        .padding()
    }
    
    var lifeView: some View {
        Text("\(viewModel.life)")
            .font(.system(size: 120))
            .foregroundStyle(viewModel.isDead ? Color.gray : Color.white)
            .colorMultiply(transitionColor)
            .transition(.opacity)
    }
    
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
//            width = proxy.size.width
//            height = proxy.size.height >= proxy.size.width
//                ? proxy.size.width
//                : proxy.size.height
        }
        
        return CGSize(width: width, height: height)
    }

    func decreaseStat() {
        withAnimation (.easeInOut(duration: 0.5)) {
            viewModel.life -= 1
            transitionColor = .red
        }
    }
    
    func increaseStat() {
        withAnimation (.easeInOut(duration: 0.5)) {
            viewModel.life += 1
            transitionColor = .green
        }
    }
}

#Preview {
    @Previewable @State
    var count = 2
    
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
                let model = LifeTrackerPlayerModel(name: "Player\(index)",
                                                   life: 40)
                LifeTrackerPlayerView(viewModel: model,
                                      rotation: .none)
                    .border(Color.black, width: 1)
            }
        }
        .padding(1)
    }
}
