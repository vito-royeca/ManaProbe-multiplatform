//
//  FullscreenCardImageView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 5/1/26.
//

import SwiftUI

import ManaKit
import NukeUI

enum FullscreenCardImageViewAction  {
    case rotate
    case flip
    case transform
    
    var iconName : String {
        switch self {
        case .rotate: return "rectangle.landscape.rotate"
        case .flip: return "rectangle.portrait.rotate"
        case .transform: return "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right"
        }
    }
}

struct FullscreenCardImageView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var model: CardViewModel
    
    @State
    private var rotation = 0.0

    var body: some View {
        NavigationStack {
            imageView
                .rotationEffect(.degrees(rotation))
                .background(Color.black)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                        }
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        actionView
                    }
                }
        }
        .background(Color.black)
    }
    
    var imageView: some View {
        var urlString = ""
        
        if let faces = model.faces,
            !faces.isEmpty,
            let normalURL = model.face?.normalURL {
            urlString = normalURL
        } else if let card = model.card,
            let normalURL = card.fragments.innerCardInfo.normalURL {
            urlString = normalURL
        }
        
        return LazyImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBack)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    var actionView: some View {
        Group {
            if let layout = model.card?.layout {
                switch layout.name {
                case "Planar",
                    "Split":
                    Button {
                        rotate(degrees: 90)
                    } label: {
                        Image(systemName: FullscreenCardImageViewAction.rotate.iconName)
                    }
                    .tint(.accentColor)

                case "Flip":
                    Button {
                        switchFace()
                        rotate(degrees: 180)
                    } label: {
                        Image(systemName: FullscreenCardImageViewAction.flip.iconName)
                    }
                    .tint(.accentColor)

                case "Double Faced Token",
                    "Modal Dfc",
                    "Reversible Card",
                    "Transform":
                    Button {
                        switchFace()
                    } label: {
                        Image(systemName: FullscreenCardImageViewAction.transform.iconName)
                    }
                    .tint(.accentColor)
                    
                default:
                    EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }
}

extension FullscreenCardImageView {
    func rotate(degrees: CGFloat) {
        rotation += degrees
        
        if rotation >= 360 {
            rotation = 0
        }
    }

    func switchFace() {
        if model.face == model.faces?.first {
            model.face = model.faces?.last
        } else {
            model.face = model.faces?.first
        }
    }
}

#Preview {
//    AsyncPreviewView { data in
//        NavigationView {
//            if let data = data {
//                FullscreenCardImageView(card: nil,
//                                        face: nil)
//            }
//        }
//    } fetchData: {
//        try await ManaKitUtilities.shared.card(id: "ecl_en_290")
//    }
}
