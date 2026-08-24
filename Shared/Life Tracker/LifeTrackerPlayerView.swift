//
//  LifeTrackerPlayerView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/24/26.
//

import SwiftUI

struct LifeTrackerPlayerView: View {
    @State
    var viewModel: LifeTrackerPlayerModel
    
    @State
    var transitionColor: Color = .primary
    
    init(startingLife: Int) {
        let model = LifeTrackerPlayerModel()
        model.life = startingLife
        _viewModel = State(wrappedValue: model)
    }

    var body: some View {
        ZStack {
            HStack {
                Button {
                    withAnimation (.easeInOut(duration: 0.5)) {
                        viewModel.life -= 1
                        transitionColor = .red
                    }
                } label: {
                    Text("-")
                        .font(.system(size: 50))
                        .frame(width: 80, height: 80)
                }
                .disabled(viewModel.isDead)
                .buttonStyle(.bordered)
                
                
                Spacer()
                
                Button {
                    withAnimation (.easeInOut(duration: 0.5)) {
                        viewModel.life += 1
                        transitionColor = .green
                    }
                } label: {
                    Text("+")
                        .font(.system(size: 50))
                        .frame(width: 80, height: 80)
                    
                }
                .disabled(viewModel.isDead)
                .buttonStyle(.bordered)
                
            }
            
            VStack(alignment: .center) {
                TextField("Player Name",
                          text: $viewModel.name)
                    .font(.system(size: 20))
                    .padding(5)
                Spacer()
            }
            
            Text("\(viewModel.life)")
                .font(.system(size: 120))
                .foregroundStyle(viewModel.isDead ? Color.gray : Color.white)
                .colorMultiply(transitionColor)
                .transition(.opacity)
        }
    }
}
