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
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "connectivity", code: 0, userInfo: nil)
            client.complete(with: clientError)
        }
        
    }
    
    func test_load_deliversHTTPInvalidResponse() {
        let (client, sut) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            client.complete(withStatusCode: 400, data: try! JSONSerialization.data(withJSONObject: []))
        }
    }
    
    func test_load_delivers200ResponseWithINvalidData() {
        let (client, sut) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
        
    }
    
    func test_load_delivers200WithEmptyJSONResponse() {
        let (client, sut) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyJSON = Data("{\"items\" : []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_delivers200JSONResponse() {
        let (client, sut) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://an-image-url")!,
                             description: "some description",
                             location: "Paris")
        
        let item2 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://another-image-url")!,
                             description: "some other description",
                             location: "Not Paris")
    
        let finalJSONData = ["items": [item1.json, item2.json]]
                
        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let jsonData = makeFeedItemJSON(finalJSONData)
            client.complete(withStatusCode: 200, data: jsonData)
        }
    }
    
    
    //MARK: Helper Functions & Factory Methods
    
    private func makeItem(id: UUID, imageURL: URL, description: String, location: String) -> (model: FeedItem, json: [String: String?]) {
        let feedItem = FeedItem(id: id, location: location, description: description, imageURL: imageURL)
        let feedJSON = ["id": id.uuidString, "image": imageURL.absoluteString, "description": description, "location": location]
        
        return (model: feedItem, json: feedJSON)
    }
    
    private func makeFeedItemJSON(_ feedItem: [String: Any] = [:]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: feedItem)
        
        return data
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action:() -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedErrors: [RemoteFeedLoader.Result] = []
        sut.load() { capturedErrors.append($0) }
        
        action()
        
        XCTAssertEqual(capturedErrors, [result], file: file, line: line)
    }

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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            if let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                              headerFields: nil) {
                messages[index].completion(.success(data, response))
            }
        }
    }

}

