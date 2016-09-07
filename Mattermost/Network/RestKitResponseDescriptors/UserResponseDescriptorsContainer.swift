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
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor
    static func completeListResponseDescriptor() -> RKResponseDescriptor
}

final class UserResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}

// MARK: - Response Descriptors
extension UserResponseDescriptorsContainer: ResponseDescriptors {
    static func loginResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.mapping(),
                                    method: .POST,
                                    pathPattern: UserPathPatternsContainer.loginPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func initialLoadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.directProfileMapping(),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.initialLoadPathPattern(),
                                    keyPath: "direct_profiles",
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
    static func completeListResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: UserMappingsContainer.directProfileMapping(),
                                    method: .GET,
                                    pathPattern: UserPathPatternsContainer.completeListPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.Successful))
    }
}