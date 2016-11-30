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
    static func createChannelResponseDescriptor() -> RKResponseDescriptor
    static func createDirectChannelResponseDescriptor() -> RKResponseDescriptor
    static func leaveChannelResponseDescriptor() -> RKResponseDescriptor
    static func joinChannelResponseDescriptor() -> RKResponseDescriptor
    static func addUserResponseDescriptor() -> RKResponseDescriptor
    static func updateHeaderResponseDescriptor() -> RKResponseDescriptor
    static func updatePurposeResponseDescriptor() -> RKResponseDescriptor
    static func updateResponseDescriptor() -> RKResponseDescriptor
}

final class ChannelResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}


//MARK: ChannelResponseDescriptors
extension ChannelResponseDescriptorsContainer: ChannelResponseDescriptors {
    static func channelsListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.listPathPattern(),
                                    keyPath: "channels",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func channelsListMembersResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.attendantInfoMapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.listPathPattern(),
                                    keyPath: "members",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func extraInfoResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.loadOnePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateLastViewDataResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.emptyMapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.updateLastViewDatePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func channelsMoreListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: ChannelPathPatternsContainer.moreListPathPattern(),
                                    keyPath: "channels",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
     static func createChannelResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.createChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func createDirectChannelResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.createDirrectChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func leaveChannelResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.leaveChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func joinChannelResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.joinChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func addUserResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.addUserPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateHeaderResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.updateHeader(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updatePurposeResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.updatePurpose(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: ChannelMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: ChannelPathPatternsContainer.update(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}

