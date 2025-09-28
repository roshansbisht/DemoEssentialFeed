//
//  DemoEssentialFeedTests.swift
//  DemoEssentialFeedTests
//
//  Created by Roshan Bisht on 24/09/25.
//

import XCTest
//@testable import DemoEssentialFeed
import DemoEssentialFeed

let BASE_URL = "https://rss.it/v2/cocoa.rss/api"

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_NotRequestDatafromURL() {
        let (client, _) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_data_requestDataFromURL() {
        let url = URL(string: BASE_URL)!
        let (client, sut) = makeSUT(url: url)
        sut.load() { _ in
            
        }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestDataFromURLTwice() {
        let url = URL(string: BASE_URL)!
        let (client, sut) = makeSUT(url: url)
        sut.load() { _ in
            
        }
        sut.load() { _ in
            
        }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load() { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "connectivity", code: 0, userInfo: nil)
        
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
        
    }
    
    func test_load_deliversHTTPInvalidResponse() {
        let (client, sut) = makeSUT()
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load() { capturedErrors.append($0) }
        
        client.complete(withStatusCode: 400)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
        
    }
    
    func test_load_delivers200ResponseWithINvalidData() {
        let (client, sut) = makeSUT()
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load() { capturedErrors.append($0) }
        
        let invalidJSON = Data("Invalid JSON".utf8)
        
        client.complete(withStatusCode: 400, data: invalidJSON)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
        
    }
    
    
    
    // MARK:- Factory Methods
    private func makeSUT(url: URL = URL(string: BASE_URL)!) -> (SpyClient, RemoteFeedLoader) {
        let client = SpyClient()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
    
    private class SpyClient: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientresponse) -> Void)]()
        
        public var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientresponse) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            if let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                              headerFields: nil) {
                messages[index].completion(.success(data, response))
            }
        }
    }

}

