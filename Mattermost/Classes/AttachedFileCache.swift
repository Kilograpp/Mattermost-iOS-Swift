//
//  AttachedFileCache.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 19.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

private protocol Public : class {
    func cacheFileForChannel(item: AssignedAttachmentViewItem, channel: Channel)
    func cacheFilesForChannel(items: [AssignedAttachmentViewItem], channel: Channel)
    func clearAll()
    func clearFilesForChannel(_ channel: Channel)
    func cachedFilesForChannel(_ channel : Channel) -> [AssignedAttachmentViewItem]?
    func hasCachedItemsForChannel(_ channel: Channel) -> Bool
}

class AttachedFileCache {
    fileprivate var cacheDict: [String : [AssignedAttachmentViewItem]] = [:]
    
}

extension AttachedFileCache : Public {
    func cacheFileForChannel(item: AssignedAttachmentViewItem, channel: Channel) {
        defer {
            cacheDict[channel.identifier!]?.append(item)
        }
        
        guard let _ = cacheDict[channel.identifier!] else {
            cacheDict[channel.identifier!] = []
            return
        }
    }
    
    func cacheFilesForChannel(items: [AssignedAttachmentViewItem], channel: Channel) {
        defer {
            cacheDict[channel.identifier!]?.append(contentsOf: items)
        }
        
        guard let _ = cacheDict[channel.identifier!] else {
            cacheDict[channel.identifier!] = []
            return
        }
    }
    
    func clearAll() {
        cacheDict.removeAll()
    }
    
    func clearFilesForChannel(_ channel: Channel) {
        cacheDict[channel.identifier!] = []
    }
    
    func cachedFilesForChannel(_ channel : Channel) -> [AssignedAttachmentViewItem]? {
        return cacheDict[channel.identifier!]
    }
    
    func hasCachedItemsForChannel(_ channel: Channel) -> Bool {
        guard let itemsForChannel = cacheDict[channel.identifier!] else {
            return false
        }
        
        return itemsForChannel.count > 0
    }
}
