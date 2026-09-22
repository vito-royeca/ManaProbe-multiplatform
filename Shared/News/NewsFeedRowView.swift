//
//  NewsFeedRowView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/24/22.
//

import SwiftUI
import BetterSafariView
import NukeUI

enum NewsFeedRowViewStyle {
    case horizontal
    case vertical
}

struct NewsFeedRowView: View {
    var item: FeedItem
    var style: NewsFeedRowViewStyle
    
    @State
    private var size: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            switch style {
            case .horizontal: horizontalContentView
            case .vertical: verticalContentView
            }
            
            Divider()
                .background(Color.secondary)
            footerView
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary, lineWidth: 1)
        )
        .saveSize(in: $size)
    }
    
    var channelView: some View {
        HStack {
            if let _ = item.channelImage {
                channelImageView
            }
            Text(item.channel ?? "")
                .font(.subheadline)
        }
    }

    var horizontalContentView: some View {
        HStack(alignment: .top) {
            if let _ = item.image {
                itemImageView
                    .frame(width: 120, height: size.height)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 10))
            }
            VStack(alignment: .leading) {
                channelView
                Text(item.title ?? "")
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
        }
    }
    
    var verticalContentView: some View {
        VStack(alignment: .leading) {
            if let _ = item.image {
                itemImageView
            }
            Text(item.title ?? "")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .padding(10)
            Spacer()
            channelView
                .padding(10)
        }
    }

    var itemImageView: some View {
        LazyImage(url: URL(string: item.image ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else if let _ = phase.error {
                EmptyView()
            } else {
                ProgressView()
            }
        }
    }
    
    var channelImageView: some View {
        LazyImage(url: URL(string: item.channelImage ?? "")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .frame(width: 30,
                           height: 30)
            } else if let _ = phase.error {
                EmptyView()
            } else {
                ProgressView()
            }
        }
    }
    
    var footerView: some View {
        HStack {
            let authorString = item.author != nil ? " \u{2022} \(item.author ?? "")" : ""
            Text("\(item.datePublished?.elapsedTime() ?? "")\(authorString)")
                .font(.footnote)
                .foregroundColor(.secondary)
            // TODO: implement the actionButton
//            Spacer()
//            actionButton
        }
        .padding(5)
    }
    
    var actionButton: some View {
        Button {
            print("button pressed")
        } label: {
            Image(systemName: "ellipsis.circle")
                .renderingMode(.original)
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.plain)
        
    }
}

#Preview {
    let channel = "Manaprobe"
    let channelImage = "https://manaprobe.com/images/favicon.ico"
    let title = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    let image = "https://manaprobe.com/images/logo_words-light.png"
    let datePublished = Date()
    let author = "Manaprobe"
    let item = FeedItem(channel: "Manaprobe",
                        channelImage: channelImage,
                        title: title,
                        image: image,
                        datePublished: Date(),
                        author: author)
    
    Group {
        List {
            NewsFeedRowView(item: item, style: .vertical)
                .listRowSeparator(.hidden)
            NewsFeedRowView(item: item, style: .horizontal)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
