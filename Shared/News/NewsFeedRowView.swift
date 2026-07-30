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

    var body: some View {
        VStack(alignment: .leading) {
            switch style {
            case .horizontal:
                horizontalContentView
            case .vertical:
                verticalContentView
            }
            
            Spacer()
            Divider()
                .background(Color.secondary)
            footerView
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary, lineWidth: 1)
        )
    }
    
    var channelView: some View {
        HStack {
            if let _ = item.channelImage {
                channelImageView
            }
            Text(item.channel ?? "")
                .font(.subheadline)
        }
        .padding(5)
    }

    var horizontalContentView: some View {
        VStack(alignment: .leading) {
            channelView
            HStack(alignment: .top, spacing: 10) {
                if let _ = item.image {
                    itemImageView
                        .frame(maxWidth: 80)
                }
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
                    .aspectRatio(contentMode: .fit)
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
            Spacer()
            actionButton
        }
        .padding(5)
    }
    
    var actionButton: some View {
        Button {
            print("button pressed")
        } label: {
            Image(systemName: "ellipsis.circle")
                .renderingMode(.original)
                .foregroundColor(Color(.systemBlue))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let item = FeedItem(channel: "Manaprobe",
                        channelImage: "https://manaprobe.com/images/favicon.ico",
                        title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                        image: "https://manaprobe.com/images/logo.png",
                        datePublished: Date(),
                        author: "Manaprobe")
    let item2 = FeedItem(channel: "Manaprobe",
                        channelImage: "https://manaprobe.com/images/favicon.ico",
                        title: "Lorem ipsum dolor sit amet",
                        image: "https://manaprobe.com/images/logo.png",
                         datePublished: Date(),
                         author: "Manaprobe")
    let item3 = FeedItem(channel: "Manaprobe",
                        channelImage: "https://manaprobe.com/images/favicon.ico",
                         title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                         datePublished: Date(),
                         author: "Manaprobe")
    Group {
        List {
            NewsFeedRowView(item: item, style: .vertical)
                .listRowSeparator(.hidden)
            NewsFeedRowView(item: item2, style: .horizontal)
                .listRowSeparator(.hidden)
            NewsFeedRowView(item: item3, style: .horizontal)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}
