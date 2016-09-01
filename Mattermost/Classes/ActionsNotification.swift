//
//  ActionsNotification.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ActionsNotification {
    let userIdentifier: String
    let action: ChannelAction
    
    init(userIdentifier: String!, action: ChannelAction) {
        self.userIdentifier = userIdentifier
        self.action = action
    }
    
    static func notificationNameForChannelIdentifier(channelIdentifier: String!) -> String! {
        return "channel.notifications.\(channelIdentifier)"
    }
}