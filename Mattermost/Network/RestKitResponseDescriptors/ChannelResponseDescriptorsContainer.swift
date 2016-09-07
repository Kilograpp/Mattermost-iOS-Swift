//
//  ChannelResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ChannelResponseDescriptors: class {
    static func extraInfoResponseDescriptor() -> RKResponseDescriptor
    static func channelsListResponseDescriptor() -> RKResponseDescriptor
    static func channelsMoreListResponseDescriptor() -> RKResponseDescriptor
    static func updateLastViewDataResponseDescriptor() -> RKResponseDescriptor
    static func channelsListMembersResponseDescriptor() -> RKResponseDescriptor
}

final class ChannelResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}

extension ChannelResponseDescriptorsContainer: ChannelResponseDescriptors {
    static func channelsListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: Channel.mapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.listPathPattern(),
                                    keyPath: "channels",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func channelsListMembersResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: Channel.attendantInfoMapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.listPathPattern(),
                                    keyPath: "members",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    static func extraInfoResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: Channel.mapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.extraInfoPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    
    static func updateLastViewDataResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: Channel.emptyMapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.updateLastViewDatePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func channelsMoreListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: Channel.mapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.moreListPathPattern(),
                                    keyPath: "channels",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}

