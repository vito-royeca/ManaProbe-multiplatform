//
//  AnimatingTextView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 8/28/26.
//

import SwiftUI

struct AnimatingTextTestView: View {
    @State private var offset: CGFloat = 0
    @State private var color: Color = .black

    var body: some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 200, height: 200)
                .offset(x: offset)

            Button("Animate") {
                let baseAnimation = Animation.easeInOut(duration: 1.0)
                let repeated = baseAnimation.repeatCount(1, autoreverses: false)
                withAnimation(repeated) {
                    if color == .black {
                        color = Color.red
                    } else {
                        color = Color.black
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

#Preview {
    AnimatingTextTestView()
}
