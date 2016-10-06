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
    static func firstPagePathPattern() -> String
    static func beforePostPathPattern() -> String
    static func afterPostPathPattern() -> String
    static func nextPagePathPattern() -> String
    static func creationPathPattern() -> String
    static func gettingPathPattern() -> String
    static func updatingPathPattern() -> String
    static func deletingPathPattern() -> String
    static func searchingPathPattern() -> String 
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
    static func beforePostPathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/" +
            "channels/:\(Post.channelIdentifierPath())/" +
            "posts/:\(PageWrapper.lastPostIdPath())/" +
        "before/0/:\(PageWrapper.sizePath())"
    }
    static func afterPostPathPattern() -> String {
        return "teams/:\(PageWrapper.teamIdPath())/" +
            "channels/:\(PageWrapper.channelIdPath())/" +
            "posts/:\(PageWrapper.lastPostIdPath())/" +
        "after/0/:\(PageWrapper.sizePath())"
    }
    static func updatePathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/posts/:\(PostAttributes.identifier)"
    }
    static func creationPathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/channels/:\(Post.channelIdentifierPath())/posts/create"
    }
    static func gettingPathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/channels/:\(Post.channelIdentifierPath())/posts/:\(PostAttributes.identifier)/get"
    }
    static func updatingPathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/channels/:\(Post.channelIdentifierPath())/posts/update"
    }
    static func deletingPathPattern() -> String {
        return "teams/:\(Post.teamIdentifierPath())/channels/:\(Post.channelIdentifierPath())/posts/:\(PostAttributes.identifier)/delete"
    }
    static func searchingPathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/posts/search"
    }
}
