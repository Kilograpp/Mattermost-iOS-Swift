//
//  PostRequestDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestDescriptor : class {
    static func creationRequestDescriptor() -> RKRequestDescriptor
}

final class PostRequestDescriptorsContainer : BaseRequestDescriptorsContainer {
    
}

extension PostRequestDescriptorsContainer : RequestDescriptor {
    static func creationRequestDescriptor() -> RKRequestDescriptor {
        return RKRequestDescriptor(mapping: PostMappingsContainer.creationRequestMapping(), objectClass: Post.self, rootKeyPath: nil, method: .POST)
    }
}