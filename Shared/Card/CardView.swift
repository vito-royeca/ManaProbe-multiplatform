//
//  CardView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 3/21/22.
//

import SwiftUI
import ManaKit
import NukeUI
import ScrollKit

struct CardView: View {
    // MARK: - Variables
    
    @State
    private var viewModel: CardViewModel
    private var navigator: CardsNavigatorDelegate?

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    @State
    private var visibleHeaderRatio: CGFloat = 1
    @State
    private var scrollOffset: CGPoint = .zero
    @State
    private var isFullScreenPresented = false
    @State
    private var isCollectionsPresented = false
    
    private let scrollManager = ScrollManager()
    
    // MARK: - Initializers
    
    init(card: InnerCardInfo, navigator: CardsNavigatorDelegate?) {
        let model = CardViewModel(id: card.id)
        _viewModel = State(wrappedValue: model)
        
        self.navigator = navigator
        self.navigator?.selectedCard = card
        self.navigator?.updateNavigation()
    }

    // MARK: - UI

    var body: some View {
        Group {
            if viewModel.isBusy {
                BusyView()
            } else if viewModel.isFailed {
                ErrorView {
                    fetchData()
                } cancelAction: {
                    viewModel.isBusy = false
                }
            } else {
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    stickyHeaderView
                } else {
                    normalView
                }
                #else
                normalView
                #endif
            }
        }
        .task {
            fetchData()
        }
        .sheet(isPresented: $isCollectionsPresented) {
            if let card = viewModel.card {
                CreateCollectionView(card: card.fragments.innerCardInfo)
            } else {
                EmptyView()
            }
        }
    }
    
    var normalView: some View {
        ScrollView {
            informationView
        }
        .toolbar {
            if let navigator {
                CardsNavigatorToolbar(navigatorDelegate: navigator, displayDelegate: viewModel)
            }
            actionToolbarView
        }
        .navigationTitle(viewModel.face?.displayName ?? viewModel.card?.displayName ?? "")
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            fullscreenView
                .presentationBackground(.black.opacity(0.5))
        }
        
    }
    
    // MARK: - ScrollViewWithStickyHeader

    var stickyHeaderView: some View {
        GeometryReader { reader in
            ScrollViewWithStickyHeader(
                header: stickyHeader,
                headerHeight: reader.size.height * 0.4,
                headerMinHeight: 150,
                headerStretch: true,
                contentCornerRadius: 15,
                scrollManager: scrollManager,
                onScroll: handleScrollOffset
            ) {
                informationView
            }
            .toolbar {
                titleToolbar
                if let navigator {
                    CardsNavigatorToolbar(navigatorDelegate: navigator, displayDelegate: viewModel)
                }
                actionToolbarView
            }
            .toolbarBackground(.hidden)
            .statusBarHidden(scrollOffset.y > -3)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            fullscreenView
                .presentationBackground(.black.opacity(0.5))
        }
    }
    
    @ToolbarContentBuilder
    private var titleToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(viewModel.face?.displayName ?? viewModel.card?.displayName ?? "")
                .font(Font.custom(ManaKitUtilities.Fonts.magic2015.name,
                                  size: 20))
                .previewHeaderContent()
                .opacity(1 - visibleHeaderRatio)
        }
    }
            
    func stickyHeader() -> some View {
        ZStack {
            thumbnailView
            ScrollViewHeaderGradient()
        }
        .onTapGesture {
            isFullScreenPresented.toggle()
        }
    }

    func handleScrollOffset(_ offset: CGPoint, visibleHeaderRatio: CGFloat) {
        self.scrollOffset = offset
        self.visibleHeaderRatio = visibleHeaderRatio
    }

    var informationView: some View {
        LazyVStack(alignment: .leading) {
            if let faces = viewModel.faces,
                !faces.isEmpty {
                FlexibleTabView(selection: $viewModel.face) {
                    ForEach(faces, id:\.self) { face in
                        CardCommonInfoView(card: nil,
                                           face: face,
                                           artists: viewModel.card?.artists,
                                           cmc: viewModel.card?.cmc)
                            .tag(face)
                            .padding(.bottom, 50)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            } else {
                if let card = viewModel.card {
                    CardCommonInfoView(card: card.fragments.cardBasicInfo,
                                       face: nil,
                                       artists: viewModel.card?.artists,
                                       cmc:  viewModel.card?.cmc)
                }
            }
            
            Divider()
            
            if let card = viewModel.card {
                CardSetInfoView(card: card)
                Divider()
                
                CardOtherInfoView(card: card)
                CardExtraInfoView(card: card)
                Divider()
                
                if !card.variations.isEmpty {
                    CardVariationsView(cards: card.variations.map { $0.fragments.innerCardInfo })
                    Divider()
                }
                
                if !card.componentParts.isEmpty {
                    CardComponentPartsView(componentParts: card.componentParts)
                    Divider()
                }
                
                if card.printings.count > 1 {
                    CardPrintingsView(card: card.fragments.innerCardInfo,
                                      cards: card.printings.map { $0.fragments.innerCardInfo})
                    Divider()
                }
                
                if !card.otherLanguages.isEmpty {
                    CardLanguagesView(cards: card.otherLanguages.map { $0.fragments.innerCardInfo})
                }
            }
        }
        .padding()
    }

    var thumbnailView: some View {
        LazyImage(url: URL(string: viewModel.face?.artCropURL ?? viewModel.card?.artCropURL ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                PlaceholderImageView(imageName: ManaKitUtilities.ImageName.cardBack)
            }
        }
    }
    
    var fullscreenView: some View {
        Group {
            if let navigator {
                FullscreenCardImageView(model: $viewModel,
                                        navigatorDelegate: navigator,
                                        displayDelegate: viewModel)
            } else {
                EmptyView()
            }
        }
    }

    var actionToolbarView: some ToolbarContent {
        CardViewActionToolbar(viewModel: $viewModel,
                              isCollectionsPresented: $isCollectionsPresented)
    }
}

extension CardView {
    func fetchData() {
        Task {
            await viewModel.fetchData()
        }
    }
}

private extension View {
    func previewHeaderContent() -> some View {
        self.foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
    }
}

// MARK: - CardViewActionToolbar

struct CardViewActionToolbar: ToolbarContent {
    @Binding
    var viewModel: CardViewModel
    
    @Binding
    var isCollectionsPresented: Bool
    
    @Environment(AuthModel.self)
    private var authModel
    
    @Environment(FavoritesViewModel.self)
    private var favoritesViewModel
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                handleCollections()
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .foregroundColor(.accentColor)

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
}
    
// MARK: - Previews

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    AsyncPreviewView { data in
        NavigationView {
            if let data {
                let card = data.fragments.innerCardInfo
                CardView(card: card, navigator: nil)
            }
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "ecl_en_290")
    }
    .environment(authModel)
    .environment(favoritesModel)
}

