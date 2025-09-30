//
//  RemoteFeedLoader.swift
//  DemoEssentialFeed
//
//  Created by Roshan Bisht on 26/09/25.
//

import Foundation

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
            case .failure(_):
                completion(.failure(.connectivity))
            case let .success(data, httpResponse):
                completion(FeedItemMapper.map(data, response: httpResponse))
            }
        }
    }
}
