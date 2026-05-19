//
//  NewsViewModel.swift
//  ManaGuide
//
//  Created by Vito Royeca on 3/30/22.
//

import Foundation
import FeedKit

import ManaKit

@MainActor
@Observable
class NewsViewModel {
    
    // MARK: - Variables

    var feeds = [String: [FeedItem]]()
    var isBusy = false
    var isFailed = false
    
    @ObservationIgnored
    private var lastUpdated: Foundation.Date?
    private let maxFeeds = 20
    
    func fetchData() async {
        guard !isBusy, feeds.isEmpty/*, willFetchNews()*/ else {
            return
        }
        
        isBusy = true
        isFailed = false
        
        do {
            let feedData = try await ManaKitUtilities.shared.feeds(fetchRemote: false)?
                .feeds ?? []
            
            for feedItem in feedData {
                
                // Read any type of feed
                let feed = try await Feed(urlString: feedItem.url)
                let date = Foundation.Date()
                var newFeeds = [FeedItem]()
                
                switch feed {
                case let .atom(feed):
                    newFeeds = feed.feedItems()
                case let .rss(feed):
                    newFeeds = feed.feedItems()
                case let .json(feed):
                    newFeeds = feed.feedItems()
                }
                
                newFeeds = newFeeds.sorted(by: { ($0.datePublished ?? date) > ($1.datePublished ?? date) })
                newFeeds = newFeeds.count >= self.maxFeeds ? newFeeds.dropLast(newFeeds.count - self.maxFeeds) : newFeeds
                feeds[feedItem.title] = newFeeds
            }
            
            lastUpdated = Date()
            isBusy = false
            isFailed = false
        } catch {
            isFailed = true
            isBusy = false
        }
    }
    
    func willFetchNews() -> Bool {
        var willFetch = true

        if let lastUpdated = lastUpdated {
            // 5 minutes
            if let diff = Calendar.current.dateComponents([.minute],
                                                          from: lastUpdated,
                                                          to: Date()).minute {
                willFetch = diff >= Constants.cacheAge
            }
        } else {
            lastUpdated = Date()
        }
        
        return willFetch
    }
}

