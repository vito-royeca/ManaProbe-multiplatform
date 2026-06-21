//
//  CardViewActionToolbar.swift
//  Manaprobe
//
//  Created by Vito Royeca on 6/4/26.
//

import SwiftUI

import ManaKit
import Nuke
import NukeUI

struct CardViewActionToolbar: ToolbarContent {
    @Binding
    var viewModel: CardViewModel
    @Binding
    var isCollectionsPresented: Bool
    @Binding
    var rotation: CGFloat
    
    @Environment(AuthModel.self)
    private var authModel
    
    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel
    
    @State
    private var normalImage: Image?

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            collectionsButton
            favoriteButton
            shareButton
                .onAppear {
                    loadNormalImage()
                }
            
            Spacer()
            
            if let layout = viewModel.card?.layout {
                switch layout.name {
                case "Planar",
                    "Split":
                    rotateButton

                case "Flip":
                    flipButton

                case "Art Series",
                    "Double Faced Token",
                    "Modal Dfc",
                    "Reversible Card",
                    "Transform":
                    switchFaceButton
                    
                default:
                    EmptyView()
                }
            }
        }
    }
    
    var rotateButton: some View {
        Button {
            rotate(degrees: 90)
        } label: {
            Image(systemName: FullscreenCardImageViewAction.rotate.iconName)
        }
        .tint(.accentColor)
    }
    
    var flipButton: some View {
        Button {
            switchFace()
            rotate(degrees: 180)
        } label: {
            Image(systemName: FullscreenCardImageViewAction.flip.iconName)
        }
        .tint(.accentColor)
    }

    var switchFaceButton: some View {
        Button {
            switchFace()
        } label: {
            Image(systemName: FullscreenCardImageViewAction.transform.iconName)
        }
        .tint(.accentColor)
    }

    var collectionsButton: some View {
        Button {
            handleCollections()
        } label: {
            Image(systemName: "folder.badge.plus")
        }
        .foregroundColor(.accentColor)
    }

    var favoriteButton: some View {
        Button {
            handleFavorite()
        } label: {
            if let card = viewModel.card,
               favoritesViewModel.isFavorite(cardID: card.id) {
                Image(systemName: "heart.fill")
            } else {
                Image(systemName: "heart")
            }
        }
        .foregroundColor(.accentColor)
    }
    
    var shareButton: some View {
        Group {
            if let normalImage {
                let card = CardTransferable(image: normalImage,
                                            title: viewModel.card?.displayName ?? "Unknown card",
                                            description: viewModel.card?.oracleText ?? "")
                
                ShareLink(item: card,
                          preview: SharePreview(card.title, image: card.image),
                          label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.accentColor)
                })
            } else {
                Text("")
            }
        }
    }

    func loadNormalImage() {
        if let normalUrl = viewModel.card?.normalURL,
           let url = URL(string: normalUrl) {

            Task {
                do {
                    let imageTask = ImagePipeline.shared.imageTask(with: url)
                    let uiImage = try await imageTask.image
                    normalImage = Image(uiImage: uiImage)
                } catch {
                    print(error)
                }
            }
        }
    }
}

// MARK: - Actions

extension CardViewActionToolbar {
    func rotate(degrees: CGFloat) {
        rotation += degrees
        
        if rotation >= 360 {
            rotation = 0
        }
    }

    func switchFace() {
        if viewModel.face == viewModel.faces?.first {
            viewModel.face = viewModel.faces?.last
        } else {
            viewModel.face = viewModel.faces?.first
        }
    }
    
    func handleCollections() {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            isCollectionsPresented.toggle()
        }
    }

    func handleFavorite() {
        if authModel.user == nil {
            authModel.showAccountView.toggle()
        } else {
            if let card = viewModel.card {
                Task {
                    try await favoritesViewModel.createOrDelete(card: card.fragments.cardBasicInfo)
                }
            }
        }
    }
    
    func handleShare() {
        
    }
}

struct CardTransferable: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    
    public var image: Image
    public var title: String
    public var description: String
}

