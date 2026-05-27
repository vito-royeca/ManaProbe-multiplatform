//
//  TestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/15/26.
//

import SwiftUI
import ManaKit

struct TestView: View {
    var body: some View {
        if let uiImage = ManaKitUtilities.shared.image(name: ManaKitUtilities.ImageName.cardBack) {
            Image(uiImage: uiImage).renderingMode(.original)
        } else {
            Text("Image not found")
        }
    }
}

#Preview {
    TestView()
}
