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
    
    internal static func mapTo(_ data: Data, and response: HTTPURLResponse) throws -> [FeedItem]? {
        guard response.statusCode == 200 else { throw RemoteFeedLoader.Error.invalidData }
        
        let rootItem = try? JSONDecoder().decode(RootItem.self, from: data)
        
        let items = rootItem?.items.map { $0.item }
        
        return items
    }
    
    internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard let items = try? FeedItemMapper.mapTo(data, and: response) else { return .failure(.invalidData) }
        return .success(items)
    }
}
