//
//  PageWrapper.swift
//  Mattermost
//
//  Created by Maxim Gubin on 23/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class PageWrapper: NSObject {
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

public enum PageWrapperAttributes: String {
    case channel = "channel"
    case page = "page"
    case size = "size"
    case lastPostId = "lastPostId"
}
