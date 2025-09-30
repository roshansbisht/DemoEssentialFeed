//
//  RemoteFeedLoader.swift
//  DemoEssentialFeed
//
//  Created by Roshan Bisht on 26/09/25.
//

import Foundation

public enum HTTPClientresponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientresponse) -> Void)
}

public final class RemoteFeedLoader {
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL = URL(string: "https://a-http-url/api")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure(_): completion(.failure(.connectivity))
            case let .success(data, httpResponse):
                if let items = try? FeedItemMapper.mapTo(data, and: httpResponse) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
    }
}

final class FeedItemMapper {
    
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
    
    static func mapTo(_ data: Data, and response: HTTPURLResponse) throws -> [FeedItem]? {
        guard response.statusCode == 200 else { throw RemoteFeedLoader.Error.invalidData }
        
        let rootItem = try? JSONDecoder().decode(RootItem.self, from: data)
        
        let items = rootItem?.items.map { $0.item }
        
        return items
    }
}
