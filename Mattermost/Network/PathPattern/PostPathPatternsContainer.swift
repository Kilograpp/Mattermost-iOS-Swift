//
//  PostPathPatternsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func updatePathPattern() -> String
    static func nextPagePathPattern() -> String
    static func creationPathPattern() -> String
    static func firstPagePathPattern() -> String
}

final class PostPathPatternsContainer: PathPatterns {
    
    static func nextPagePathPattern() -> String {
        return "teams/:\(PageWrapper.teamIdPath())/" +
            "channels/:\(PageWrapper.channelIdPath())/" +
            "posts/:\(PageWrapper.lastPostIdPath())/" +
            "before/:\(PageWrapper.pagePath())/:\(PageWrapper.sizePath())"
    }
    static func firstPagePathPattern() -> String {
        return "teams/:\(PageWrapper.teamIdPath())/" +
            "channels/:\(PageWrapper.channelIdPath())/" +
            "posts/page/:\(PageWrapper.pagePath())/:\(PageWrapper.sizePath())"
    }
    static func updatePathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/posts/:\(PostAttributes.identifier)"
    }
    // /teams/on95mnb5h7r73n373brm6eddrr/channels/1d8egstt33nujj49zhaoobiumc/posts/update
    static func creationPathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/channels/:\(Post.channelIdentifierPath())/posts/create"
    }
}