//
//  TeamPathPatternsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol TeamPathPattern: class {
    static func initialLoadPathPattern() -> String
    static func teamListingsPathPattern() -> String
}

final class TeamPathPatternsContainer {
    
}

extension TeamPathPatternsContainer: TeamPathPattern {
    static func initialLoadPathPattern() -> String {
        return "users/initial_load"
    }
    static func teamListingsPathPattern() -> String {
        return "teams/all_team_listings"
    }
}