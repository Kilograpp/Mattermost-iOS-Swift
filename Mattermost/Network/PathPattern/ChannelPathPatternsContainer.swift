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
    static func extraInfoPathPattern() -> String
    static func updateLastViewDatePathPattern() -> String
}

final class ChannelPathPatternsContainer: PathPatterns {
    
    
    static func moreListPathPattern() -> String {
        return "teams/:\(TeamAttributes.identifier.rawValue)/channels/more"
    }
    static func listPathPattern() -> String {
        return "teams/:\(TeamAttributes.identifier.rawValue)/channels/"
    }
    static func extraInfoPathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/extra_info"
    }
    static func updateLastViewDatePathPattern() -> String {
        return "teams/:\(Channel.teamIdentifierPath())/channels/:\(ChannelAttributes.identifier)/update_last_viewed_at"
    }
}
