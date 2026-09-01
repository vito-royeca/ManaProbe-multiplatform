//
//  LifeTrackerCounterView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/31/26.
//

import SwiftUI

struct LifeTrackerCounterView: View {
    @Binding
    var player: LifeTrackerPlayerModel
    @State
    var stat: LifeTrackerPlayerStat
    @State
    var showStat: Bool
    
    // MARK: - Initializers
    
    init(player: Binding<LifeTrackerPlayerModel>,
         stat: LifeTrackerPlayerStat,
         showStat: Bool) {
        self._player = player
        self.stat = stat
        self.showStat = showStat
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                let size = computeSize(by: proxy)
                
                HStack(spacing: 0) {
                    minusButton
                        .frame(width: size.width / 2,
                               height: size.height)
                        .background(Rectangle().fill(player.color))
                        .onTapGesture {
                            if player.isEnabled {
                                decreaseStat()
                            }
                        }
                    plusButton
                        .frame(width: size.width / 2,
                               height: size.height)
                        .background(Rectangle().fill(player.color))
                        .onTapGesture {
                            if player.isEnabled {
                                increaseStat()
                            }
                        }
                }
                
                if showStat {
                    statView
                        .font(.system(size: size.height * 0.6))
                        .fixedSize()
                        .frame(width: size.width,
                               height: size.height)
                }
            }
        }
    }
    
    var minusButton: some View {
        HStack() {
            Image(systemName: "minus")
                .frame(width: 30.0, height: 30.0)
                .font(.title)
                .foregroundStyle(Color.gray)
                .opacity(!player.isEnabled ? 0 : 1)
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
                .opacity(!player.isEnabled ? 0 : 1)
        }
        .padding()
    }
    
    var statView: some View {
        Text("\(player.get(stat: stat))")
            .monospacedDigit()
            .contentTransition(.numericText())
            .foregroundStyle(player.color)
            .colorInvert()
    }
}

extension LifeTrackerCounterView {
    func computeSize(by proxy: GeometryProxy) -> CGSize {
        let width = proxy.size.width
        let height = proxy.size.height >= proxy.size.width
            ? proxy.size.width
            : proxy.size.height
        
        return CGSize(width: width, height: height)
    }

    func decreaseStat() {
        withAnimation(.easeInOut(duration: 1.0)) {
            let value = player.get(stat: stat)
            player.set(stat: stat, with: value - 1)
        }
    }
    
    func increaseStat() {
        withAnimation(.easeInOut(duration: 1.0)) {
            let value = player.get(stat: stat)
            player.set(stat: stat, with: value + 1)
        }
    }
}

#Preview {
    @Previewable @State
    var model = LifeTrackerPlayerModel(name: "Player 1",
                                        life: 99)
    
    LifeTrackerCounterView(player: $model,
                           stat: .life,
                           showStat: true)
}
