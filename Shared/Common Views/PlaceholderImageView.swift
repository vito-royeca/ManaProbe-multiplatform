//
//  PlaceholderImageView.swift
//  ManaGuide
//
//  Created by Vito Royeca on 4/18/26.
//

import SwiftUI
import ManaKit

struct PlaceholderImageView: View {
    let imageName: ManaKitUtilities.ImageName
    var contentMode: ContentMode = .fill
    
    var body: some View {
        imageView
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .clipped()
    }
    
    private var imageView: Image {
        if let uiImage = ManaKitUtilities.shared.image(name: imageName) {
            Image(uiImage: uiImage)
                .renderingMode(.original)
        } else {
            Image(systemName: "photo.badge.exclamationmark")
        }
    }
}

#Preview {
//    GeometryReader { reader in
        PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBack, contentMode: .fill)
//            .frame(width: reader.size.width)
//    }
}
