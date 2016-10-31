//
//  ChannelPathPatternsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func listPathPattern() -> String
    static func moreListPathPattern() -> String
    static func loadOnePathPattern() -> String
    static func addUserPathPattern() -> String
    static func updateLastViewDatePathPattern() -> String
    static func createDirrectChannelPathPattern() -> String
    static func leaveChannelPathPattern() -> String
    static func joinChannelPathPattern() -> String
}

final class ChannelPathPatternsContainer: PathPatterns {
    static func moreListPathPattern() -> String {
        return "teams/:\(TeamAttributes.identifier.rawValue)/channels/more"
    }
    static func listPathPattern() -> String {
        return "teams/:\(TeamAttributes.identifier.rawValue)/channels/"
    }
    static func loadOnePathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)"
    }
    static func addUserPathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/add"
    }
    static func updateLastViewDatePathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/update_last_viewed_at"
    }
    static func createDirrectChannelPathPattern() -> String {
        return "teams/:\(TeamAttributes.identifier.rawValue)/channels/create_direct"
    }
    static func leaveChannelPathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/leave"
    }
    static func joinChannelPathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/join"
    }
}
