//
//  PostResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptor: class {
    static func updateResponseDescriptor() -> RKResponseDescriptor
    static func nextPageResponseDescriptor() -> RKResponseDescriptor
    static func firstPageResponseDescriptor() -> RKResponseDescriptor
    static func creationResponseDescriptor() -> RKResponseDescriptor
    static func updatingResponseDescriptor() -> RKResponseDescriptor
    static func deletingResponseDescriptor() -> RKResponseDescriptor
}

final class PostResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}

extension PostResponseDescriptorsContainer: ResponseDescriptor {
    static func firstPageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.firstPagePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.successful))
    }
    static func updateResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.updatePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.successful))
    }
    static func nextPageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.nextPagePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.successful))
    }
    static func creationResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.creationMapping(),
                                    method: .POST,
                                    pathPattern: PostPathPatternsContainer.creationPathPattern(),
                                    keyPath: nil,
                                    statusCodes:  RKStatusCodeIndexSetForClass(.successful))
    }
    static func gettingResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.gettingPathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.successful))
    }
    static func updatingResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.updatingMapping(),
                                    method: .POST,
                                    pathPattern: PostPathPatternsContainer.updatingPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
    static func deletingResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.deletingMapping(),
                                    method: .POST,
                                    pathPattern: PostPathPatternsContainer.deletingPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
