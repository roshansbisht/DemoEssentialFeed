//
//  FeedLoader.swift
//  DemoEssentialFeed
//
//  Created by Roshan Bisht on 24/09/25.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping ((LoadFeedResult) -> Void))
}
