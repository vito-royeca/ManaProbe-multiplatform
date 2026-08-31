//
//  DiceView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/30/26.
//

import SwiftUI

struct DiceView: View {
    @State
    var model: DiceViewModel
    var isTappable = false
    var color = Color.black
    var colorConvert = false

    var body: some View {
        contentView
            .onTapGesture {
                if isTappable {
                    model.roll()
                }
            }
    }

    var contentView: some View {
        GeometryReader { proxy in
            ZStack {
                let size = computeSize(by: proxy)
                let width = size.width
                let height = size.height
                
                iconView
                    .frame(width: width, height: height)
                    .rotationEffect(.degrees(model.isAnimating
                                             ? Double.random(in: -360...360)
                                             : 0))
                    .scaleEffect(model.isAnimating
                                 ? Double.random(in: 1...1.5)
                                 : 1)
                circleView
                    .frame(width: width * 0.4, height: height * 0.4)
                    
                    .overlay {
                        if model.isAnimating {
                            EmptyView()
                        } else {
                            Text("\(model.value)")
                                .foregroundColor(.white)
                                .font(.system(size: height / 4))
                                .bold()
                        }
                    }
            }
        }
    }
    
    var iconView: some View {
        Group {
            if colorConvert {
                model.dice.iconSolid
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(color)
                    .colorInvert()
            } else {
                model.dice.iconSolid
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(color)
            }
        }
    }
    
    var circleView: some View {
        Group {
            if colorConvert {
                Circle()
                    .foregroundColor(color)
                    .colorInvert()
            } else {
                Circle()
                    .foregroundColor(color)
            }
        }
    }
}

extension DiceView {
    func computeSize(by proxy: GeometryProxy) -> CGSize {
        let width = proxy.size.width
        let height = proxy.size.height >= proxy.size.width
            ? proxy.size.width
            : proxy.size.height
        
        return CGSize(width: width, height: height)
    }
}
