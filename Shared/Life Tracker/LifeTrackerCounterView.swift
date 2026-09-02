//
//  LifeTrackerCounterView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/31/26.
//

import SwiftUI

struct LifeTrackerCounterView: View {
    // MARK: - Constants
    let labelHeight = Double(40)
    let iconColor = Color.accentColor

    @Binding
    var player: LifeTrackerPlayerModel
    @State
    var stat: LifeTrackerPlayerStat
    @Binding
    var isSettingsPresented: Bool
    
    // MARK: - Initializers
    
    init(player: Binding<LifeTrackerPlayerModel>,
         stat: LifeTrackerPlayerStat,
         isSettingsPresented: Binding<Bool>) {
        self._player = player
        self.stat = stat
        self._isSettingsPresented = isSettingsPresented
    }
    
    init(player: Binding<LifeTrackerPlayerModel>,
         stat: LifeTrackerPlayerStat) {
        self._player = player
        self.stat = stat
        self._isSettingsPresented = .constant(false)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                let size = computeSize(by: proxy)
                
                VStack(spacing: 0) {
                    infoView
                        .padding(2)
                        .frame(width: size.width,
                               height: labelHeight)
                    HStack(spacing: 0) {
                        minusButton
                            .frame(width: size.width / 2,
                                   height: size.height - labelHeight)
                            .background(minusRectangleView.fill(player.color))
                            .onTapGesture {
                                if player.isEnabled {
                                    decreaseStat()
                                }
                            }
                        plusButton
                            .frame(width: size.width / 2,
                                   height: size.height - labelHeight)
                            .background(plusRectangleView.fill(player.color))
                            .onTapGesture {
                                if player.isEnabled {
                                    increaseStat()
                                }
                            }
                    }
                }
                
                statView
                    .font(.system(size: size.height * 0.6))
            }
        }
    }
    
    var infoView: some View {
        Group {
            if stat == .life {
                HStack(spacing: 10) {
                    Image(systemName: "pencil.line")
                        .frame(width: 30.0, height: 30.0)
                        .font(.title)
                        .foregroundStyle(iconColor)
                        .opacity(!player.isEnabled ? 0 : 1)
                        .onTapGesture {
                            if player.isEnabled {
                                isSettingsPresented.toggle()
                            }
                        }
                    Text(player.name)
                        .font(.default)
                        .foregroundStyle(player.color)
                        .colorInvert()
                    Spacer()
                }
            } else {
                HStack(spacing: 10) {
                    Image(stat == .poison
                          ? "BP"
                          : "E")
                        .resizable()
                        .frame(width: 30.0, height: 30.0)
                        .font(.title)
                        .foregroundStyle(Color.gray)
                        .opacity(!player.isEnabled ? 0 : 1)
                    Spacer()
                }
                .opacity(!player.isEnabled ? 0 : 1)
            }
        }
    }
    
    var statView: some View {
        Text("\(player.get(stat: stat))")
            .monospacedDigit()
            .contentTransition(.numericText())
            .foregroundStyle(player.color)
            .opacity(!player.isEnabled ? 0 : 1)
            .colorInvert()
    }
    
    var minusButton: some View {
        HStack() {
            Image(systemName: "minus")
                .frame(width: 30.0, height: 30.0)
                .font(.title)
                .foregroundStyle(iconColor)
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
                .foregroundStyle(iconColor)
                .opacity(!player.isEnabled ? 0 : 1)
        }
        .padding()
    }
    
    var minusRectangleView: UnevenRoundedRectangle {
        let bottomLeading = CGFloat(20)
        let bottomTrailing = CGFloat(0)
        
        return UnevenRoundedRectangle(cornerRadii: .init(
            topLeading: 0,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            topTrailing: 0),
                                      style: .continuous)
    }
    
    var plusRectangleView: UnevenRoundedRectangle {
        let bottomLeading = CGFloat(0)
        let bottomTrailing = CGFloat(20)
        
        return UnevenRoundedRectangle(cornerRadii: .init(
            topLeading: 0,
            bottomLeading: bottomLeading,
            bottomTrailing: bottomTrailing,
            topTrailing: 0),
                                      style: .continuous)
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
                           isSettingsPresented: .constant(false))
}
