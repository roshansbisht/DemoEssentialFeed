//
//  FeedItemMapper.swift
//  DemoEssentialFeed
//
//  Created by Roshan Bisht on 30/09/25.
//

import Foundation

internal final class FeedItemMapper {
    
    private struct RootItem: Decodable {
        let items: [Item]
        var feedItems: [FeedItem] {
            return items.map { $0.item }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let location: String?
        let description: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, location: location, description: description, imageURL: image)
        }
    }
    
    internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(RootItem.self, from: data) else { return .failure(.invalidData) }
        return .success(root.feedItems)
    }
}
