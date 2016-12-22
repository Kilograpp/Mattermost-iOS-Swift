//
//  UserResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func loginResponseDescriptor() -> RKResponseDescriptor
    static func logoutResponseDescriptor() -> RKResponseDescriptor
    static func loadCurrentUserResponseDescriptor() -> RKResponseDescriptor
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor
    static func initialLoadPreferencesResponseDescriptor() -> RKResponseDescriptor
    static func completeListResponseDescriptor() -> RKResponseDescriptor
    static func usersFromChannelResponseDescriptor() -> RKResponseDescriptor
    static func updateNotifyResponseDescriptor() -> RKResponseDescriptor
    static func updateResponseDescriptor() -> RKResponseDescriptor
    static func updatePasswordResponseDescriptor() -> RKResponseDescriptor
    static func updateImageResponseDescriptor() -> RKResponseDescriptor
    static func attachDeviceResponseDescriptor() -> RKResponseDescriptor
    static func passwordResetResponseDescriptor() -> RKResponseDescriptor
    static func listOfPreferedResponseDescriptor() -> RKResponseDescriptor
}

final class UserResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}


// MARK: Response Descriptors
extension UserResponseDescriptorsContainer: ResponseDescriptors {
    static func loginResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.loginPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func logoutResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.emptyMapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.logoutPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func loadCurrentUserResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.loadCurrentUser(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.directProfileMapping(),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.initialLoadPathPattern(),
                                    keyPath: "direct_profiles",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func initialLoadPreferencesResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PreferenceMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.initialLoadPathPattern(),
                                    keyPath: "preferences",
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func completeListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.directProfileMapping(),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.completeListPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func usersFromChannelResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: RKObjectMapping(with: NSMutableDictionary.self),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.usersFromChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func usersAreNotInChannelResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: RKObjectMapping(with: NSMutableDictionary.self),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.usersNotInChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateNotifyResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.usersUpdateNotifyPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.userUpdatePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updatePasswordResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.emptyMapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.userUpdatePasswordPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateImageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: BaseMappingsContainer.emptyResponseMapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.userUpdateImagePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func attachDeviceResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.emptyMapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.attachDevicePathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func passwordResetResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.emptyMapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.passwordResetPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func listOfPreferedResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: RKObjectMapping(with: NSMutableDictionary.self),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.usersByIdsPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
