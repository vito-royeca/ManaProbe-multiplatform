//
//  SetHeaderView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 11/1/23.
//

import SwiftUI
import ManaKit
import NukeUI

struct SetHeaderView: View {
    @Bindable
    var viewModel: SetViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            imageView
            detailedInfoView
            languagePickerView
        }
        .onChange(of: viewModel.language) {
            fetchData()
        }
    }

    private var imageView: some View {
        Group {
            if let lastPath = viewModel.set?.bigLogoURL?.split(separator: "/").last,
               let uiImage = ManaKitUtilities.shared.image(fileName: String(lastPath)) {
                Image(uiImage: uiImage)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            } else {
                let url = URL(string: viewModel.set?.bigLogoURL ?? "")
                LazyImage(url: url) { phase in
                    if let _ = phase.error {
                        Image(systemName: "photo.badge.exclamationmark")
                    } else if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .frame(maxHeight: 100)
    }
    
    private var detailedInfoView: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top) {
                Text("Type")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                Text(viewModel.set?.setType.name ?? "")
                    .font(.subheadline)
                
                if viewModel.set?.isOnlineOnly ?? false {
                    Spacer()
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.icloud")
                        Text("Online only")
                            .font(.footnote)
                    }
                    Spacer()
                } else {
                    Spacer()
                }
                Text("Block")
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                Text(viewModel.set?.setBlock?.name ?? String.emdash)
                    .font(.subheadline)
            }

            HStack {
                VStack {
                    Text("Symbol")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    Text(viewModel.set?.keyruneUnicode.keyrune2Unicode() ?? "")
                        .font(Font.custom("Keyrune", size: 20))
                }
                Spacer()
                VStack {
                    Text("Code")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    Text((viewModel.set?.id ?? "").uppercased())
                        .font(.subheadline)
                }
                Spacer()
                VStack {
                    Text("Release Date")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    Text(viewModel.set?.releaseDate ?? "")
                        .font(.subheadline)
                }
                Spacer()
                VStack {
                    Text("Cards")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    Text("\(viewModel.set?.cardCount ?? 0)")
                        .font(.subheadline)
                }
            }
        }
    }
    
    private var languagePickerView: some View {
        HStack {
            let languages = (viewModel.set?.languages ?? []).sorted(by: { $0.name < $1.name })
            Image("language")
                .resizable()
                .frame(width: 20, height: 20)
            Picker("Language",
                   selection: $viewModel.language) {
                ForEach(languages, id: \.id) { language in
                    Text(language.name)
                        .tag(language as SetInfo.Language?)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .disabled((viewModel.set?.languages ?? []).count == 1)
            Spacer()
        }
    }
}

extension SetHeaderView {
    func fetchData() {
        Task {
            await viewModel.reloadData()
        }
    }
}
