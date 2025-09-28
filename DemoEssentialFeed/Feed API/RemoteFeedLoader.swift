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

public final  class RemoteFeedLoader {
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL = URL(string: "https://rss.it/v2/cocoa.rss/api")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure(_): completion(.connectivity)
            case .success(_, _): completion(.invalidData)
            }
        }
    }
}
