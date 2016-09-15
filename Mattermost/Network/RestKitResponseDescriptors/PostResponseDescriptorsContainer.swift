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
}

final class PostResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}

extension PostResponseDescriptorsContainer: ResponseDescriptor {
    static func firstPageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.firstPagePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    static func updateResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.updatePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    static func nextPageResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.listMapping(),
                                    method: .GET,
                                    pathPattern: PostPathPatternsContainer.nextPagePathPattern(),
                                    keyPath: "posts",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    static func creationResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: PostMappingsContainer.creationMapping(),
                                    method: .POST,
                                    pathPattern: PostPathPatternsContainer.creationPathPattern(),
                                    keyPath: nil,
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
}