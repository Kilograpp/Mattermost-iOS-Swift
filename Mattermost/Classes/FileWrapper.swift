//
//  FileWrapper.swift
//  Mattermost
//
//  Created by TaHyKu on 10.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import UIKit

enum FileWrapperAttributes: String {
    case teamId    = "teamId"
    case channelId = "channelId"
    case postId    = "postId"
}


class FileWrapper: NSObject {
    let teamId: String?
    let channelId: String?
    let postId: String?
    
    init(teamId: String? = nil, channelId: String? = nil, postId: String) {
        self.teamId = (teamId == nil) ? Preferences.sharedInstance.currentTeamId : teamId
        self.channelId = (channelId == nil) ? ChannelObserver.sharedObserver.selectedChannel?.identifier : channelId
        self.postId = postId
    }
}
