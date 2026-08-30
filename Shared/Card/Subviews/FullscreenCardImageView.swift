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
        case .rotate: "rectangle.landscape.rotate"
        case .flip: "rectangle.portrait.rotate"
        case .transform: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right"
        }
    }
}

struct FullscreenCardImageView: View {
    @Environment(\.dismiss)
    var dismiss
    
    @Binding
    var model: CardViewModel
    var navigatorDelegate: CardsNavigatorDelegate?
    var displayDelegate: CardsNavigatorDisplayDelegate?
    
    @State
    private var rotation: CGFloat = .zero
    @State
    private var isCollectionsPresented = false

    var body: some View {
        NavigationStack {
            imageView
                .rotationEffect(.degrees(rotation))
                .background(Color.black)
                .gesture(dragGesture)
                .toolbar {
                    closeToolbarItem
                    
                    if let navigatorDelegate, let displayDelegate {
                        CardsNavigatorToolbar(navigatorDelegate: navigatorDelegate, displayDelegate: displayDelegate)
                    }
                    
                    CardViewActionToolbar(viewModel: $model,
                                          isCollectionsPresented: $isCollectionsPresented,
                                          rotation: $rotation)
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
                PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBack,
                                     contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
            }
        }
    }
    
    var closeToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded { value in
            let horizontalAmount = value.translation.width
            let verticalAmount = value.translation.height
            
            if abs(horizontalAmount) > abs(verticalAmount) {
                if horizontalAmount < 0 {
//                    print("left swipe")
                    goToNext()
                    
                } else {
//                    print("right swipe")
                    goToPrevious()
                }
            } else {
                if verticalAmount < 0 {
//                    print("up swipe")
                    goToNext()
                } else {
//                    print("down swipe")
                    goToPrevious()
                }
            }
        }
    }
}

// MARK: - Swipe actions

extension FullscreenCardImageView {
    func goToPrevious() {
        guard let navigatorDelegate,
            let displayDelegate else {
            return
        }
        
        navigatorDelegate.goToPrevious()
        if let card = navigatorDelegate.selectedCard {
            Task {
                await displayDelegate.display(card: card)
            }
        }
    }
    
    func goToNext() {
        guard let navigatorDelegate,
            let displayDelegate else {
            return
        }

        navigatorDelegate.goToNext()
        if let card = navigatorDelegate.selectedCard {
            Task {
                await displayDelegate.display(card: card)
            }
        }
    }
}

#Preview {
    @Previewable
    @State
    var cardViewModel = CardViewModel(id: "ecl_en_290")
    var navigator: CardsNavigatorDelegate?
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    
    AsyncPreviewView { data in
        NavigationView {
            FullscreenCardImageView(model: $cardViewModel,
                                    navigatorDelegate: navigator,
                                    displayDelegate: cardViewModel)
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "ecl_en_290")
    }
    .environment(authModel)
    .environment(favoritesModel)
}
