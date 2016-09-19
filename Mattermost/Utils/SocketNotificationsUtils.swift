//
//  SocketNotificationsUtils.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 19.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class SocketNotificationState {
    
}


class SocketNotificationProperties {
    let parent_id = JSON("")
}


class SocketNotification {
    let channelIdentifier: String!
    let teamIdentifier: String!
    let action: String!
    let state = SocketNotificationState()
    let properties = SocketNotificationProperties()
    
    init(channelId: String, teamId: String, act: String) {
        channelIdentifier = channelId
        teamIdentifier = teamId
        action = act
    }
    
}