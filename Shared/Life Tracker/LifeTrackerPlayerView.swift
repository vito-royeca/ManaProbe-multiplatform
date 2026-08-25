//
//  LifeTrackerPlayerView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

struct LifeTrackerPlayerView: View {
    let labelHeight = CGFloat(30)
    
    @State
    var viewModel: LifeTrackerPlayerModel
    @State
    var transitionColor: Color = .primary
    @State
    var bodyViewSize: CGSize = .zero
    
    init(startingLife: Int) {
        let model = LifeTrackerPlayerModel()
        model.life = startingLife
        _viewModel = State(wrappedValue: model)
    }

    var body: some View {
        ZStack {
            let width = (bodyViewSize.width > bodyViewSize.height
                ? bodyViewSize.width
                : bodyViewSize.height) / 2
            let height = (bodyViewSize.height > bodyViewSize.width
                ? bodyViewSize.width
                : bodyViewSize.height) - labelHeight * 2
            
            HStack(spacing: 0) {
                minusButton
                    .frame(minWidth: width,
                           minHeight: height)
                    .background(Rectangle().fill(Color.cyan))
                    .onTapGesture {
                        decreaseStat()
                    }
                
                plusButton
                    .frame(minWidth: width,
                           minHeight: height)
                    .background(Rectangle().fill(Color.gray))
                    .onTapGesture {
                        increaseStat()
                    }
            }
            
            VStack(alignment: .center) {
                playerNameView
                    .frame(minWidth: bodyViewSize.width,
                           minHeight: labelHeight)
                    
                Spacer()
            }
            
            lifeView
                
        }
        .saveSize(in: $bodyViewSize)
    }
    
    var playerNameView: some View {
        Text(viewModel.name)
            .font(.system(size: 20))
    }
    
    var minusButton: some View {
        Text("-")
            .font(.system(size: 50))
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .disabled(viewModel.isDead)
    }
    
    var plusButton: some View {
        Text("+")
            .font(.system(size: 50))
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .disabled(viewModel.isDead)
    }
    
    var lifeView: some View {
        Text("\(viewModel.life)")
            .font(.system(size: 120))
            .foregroundStyle(viewModel.isDead ? Color.gray : Color.white)
            .colorMultiply(transitionColor)
            .transition(.opacity)
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
    @Previewable @State
    var bodyViewSize: CGSize = .zero
    
    VStack(spacing: 0) {
        let width = (bodyViewSize.width > bodyViewSize.height
            ? bodyViewSize.height
            : bodyViewSize.width)
        let height = (bodyViewSize.height > bodyViewSize.width
            ? bodyViewSize.width
            : bodyViewSize.height)
        
        Text("Players")
        Picker("Players", selection: $count) {
            ForEach((1...6), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.segmented)
        .padding(.bottom, 10)

        Group {
            ForEach(1...count, id: \.self) { _ in
                LifeTrackerPlayerView(startingLife: 40)
                    .border(Color.black, width: 1)
                    .frame(minWidth: width, minHeight: height)
            }
        }
        .saveSize(in: $bodyViewSize)
    }
    
    
}
