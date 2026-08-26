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
    
    init(viewModel: LifeTrackerPlayerModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack() {
                let width = proxy.size.width
                let height = (proxy.size.height >= proxy.size.width
                    ? proxy.size.width
                    : proxy.size.height)

                HStack(spacing: 0) {
                    minusButton
                        .frame(minWidth: width / 2,
                               minHeight: height)
                        .background(Rectangle().fill(Color.cyan))
                        .onTapGesture {
                            decreaseStat()
                        }
                    
                    plusButton
                        .frame(minWidth: width / 2,
                               minHeight: height)
                        .background(Rectangle().fill(Color.gray))
                        .onTapGesture {
                            increaseStat()
                        }
                }
                
                VStack(alignment: .center) {
                    playerNameView
                        .frame(width: width,
                               height: labelHeight)
                        .background(Rectangle().fill(Color.teal))
    
                    Spacer()
                }
    
                lifeView
                    .frame(height: height)
                
            }
        }
    }
    
    var playerNameView: some View {
        Text(viewModel.name)
            .font(.system(size: 20))
    }
    
    var minusButton: some View {
        Text("-")
            .font(.system(size: 50))
        .multilineTextAlignment(.leading)
        .disabled(viewModel.isDead)
    }
    
    var plusButton: some View {
        Text("+")
            .font(.system(size: 50))
        .multilineTextAlignment(.trailing)
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
    var count = 1
    
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
                LifeTrackerPlayerView(viewModel: model)
                    .border(Color.black, width: 1)
            }
        }
        .padding(1)
    }
}
