//
//  UserPathPatternsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func loginPathPattern() -> String
    static func loadCurrentUser() -> String
    static func avatarPathPattern() -> String
    static func socketPathPattern() -> String
    static func initialLoadPathPattern() -> String
    static func completeListPathPattern() -> String
    static func usersStatusPathPattern() -> String
}

final class UserPathPatternsContainer: PathPatterns {
    
    static func avatarPathPattern() -> String {
        return "users/:\(UserAttributes.identifier)/image"
    }
    static func loginPathPattern() -> String {
        return "users/login"
    }
    static func logoutPathPattern() -> String {
        return "users/logout"
    }
    static func loadCurrentUser() -> String {
        return "users/me"
    }
    static func initialLoadPathPattern() -> String {
        return TeamPathPatternsContainer.initialLoadPathPattern()
    }
    static func socketPathPattern() -> String {
        return "users/websocket"
    }
    static func completeListPathPattern() -> String {
        return "users/profiles/:\(TeamAttributes.identifier)"
    }
    
    static func usersStatusPathPattern() -> String {
        return "users/status"
    }
}
