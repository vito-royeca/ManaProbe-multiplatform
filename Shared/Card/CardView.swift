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
    let visibleHeaderRatioReloadThreshold = CGFloat(1.5)
    
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
    
    @State
    private var needsReload = false
    @State
    private var rotation: CGFloat = .zero
    
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
                        .toolbar(.hidden, for: .tabBar)
                } else {
                    normalView
                        .toolbar(.hidden, for: .tabBar)
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
    
    // MARK: - normal view
    
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
        
        if visibleHeaderRatio >= visibleHeaderRatioReloadThreshold {
            needsReload = true
        }
        if needsReload && offset.y == 0 {
            needsReload = false
            reloadData()
        }
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
        .rotationEffect(.degrees(rotation))
    }
    
    var fullscreenView: some View {
        FullscreenCardImageView(model: $viewModel,
                                navigatorDelegate: navigator,
                                displayDelegate: viewModel)
    }

    var actionToolbarView: some ToolbarContent {
        CardViewActionToolbar(viewModel: $viewModel,
                              isCollectionsPresented: $isCollectionsPresented,
                              rotation: $rotation)
    }
}

extension CardView {
    func fetchData() {
        Task {
            await viewModel.fetchData()
        }
    }
    
    func reloadData() {
        Task {
            await viewModel.reloadData()
        }
    }
}

private extension View {
    func previewHeaderContent() -> some View {
        self.foregroundColor(.white)
            .shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
    }
}

// MARK: - Previews

#Preview {
    let authModel = AuthModel()
    let favoritesModel = FavoritesViewModel()
    
    AsyncPreviewView { data in
        NavigationView {
            CardView(card: data.fragments.innerCardInfo, navigator: nil)
        }
    } fetchData: {
        try await ManaKitUtilities.shared.card(fetchRemote: false,
                                               id: "one_en_196")
    }
    .environment(authModel)
    .environment(favoritesModel)
}

