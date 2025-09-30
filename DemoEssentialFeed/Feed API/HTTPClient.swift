//
//  HTTPClient.swift
//  DemoEssentialFeed
//
//  Created by Roshan Bisht on 30/09/25.
//

import Foundation


public enum HTTPClientresponse {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientresponse) -> Void)
}
