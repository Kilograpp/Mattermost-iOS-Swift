//
//  PageWrapper.swift
//  Mattermost
//
//  Created by Maxim Gubin on 23/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


private protocol PathPatterns: class {
    static func teamIdPath() -> String
    static func channelIdPath() -> String
    static func pagePath() -> String
    static func sizePath() -> String
    static func lastPostIdPath() -> String
}

enum PageWrapperAttributes: String {
    case channel = "channel"
    case page = "page"
    case size = "size"
    case lastPostId = "lastPostId"
}

final class PageWrapper: NSObject {
    let page: Int
    let size: Int
    let channel: Channel
    let lastPostId: String?
    
    init(page: Int = 0, size: Int = 60, channel: Channel, lastPostId: String? = nil) {
        self.page = page
        self.size = size
        self.channel = channel
        self.lastPostId = lastPostId
    }
}

extension PageWrapper: PathPatterns {
    static func teamIdPath() -> String {
        return "\(PageWrapperAttributes.channel).\(ChannelRelationships.team).\(TeamAttributes.identifier)"
    }
    static func channelIdPath() -> String {
        return "\(PageWrapperAttributes.channel).\(ChannelAttributes.identifier)"
    }
    static func pagePath() -> String {
        return PageWrapperAttributes.page.rawValue
    }
    static func sizePath() -> String {
        return PageWrapperAttributes.size.rawValue
    }
    static func lastPostIdPath() -> String {
        return PageWrapperAttributes.lastPostId.rawValue
    }
}