//
//  DemoEssentialFeed.swift
//  DemoEssentialFeed
//
//  Created by Roshan Bisht on 24/09/25.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let location: String?
    let description: String?
    let imageURL: URL
}
