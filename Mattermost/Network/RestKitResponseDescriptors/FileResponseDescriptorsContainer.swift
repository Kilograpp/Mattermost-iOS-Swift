//
//  FileResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by Mariya on 07.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func updateResponseDescriptor() -> RKResponseDescriptor
    static func uploadResponseDescriptor() -> RKResponseDescriptor
}

final class FileResponseDescriptorsContainer: BaseResponseDescriptorsContainer {
    
}

extension FileResponseDescriptorsContainer: ResponseDescriptors {
    static func updateResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: FileMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: FilePathPatternsContainer.updateCommonPathPattern(),
                                    keyPath: nil,
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    
    static func uploadResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: FileMappingsContainer.uploadMapping(),
                                    method: .POST,
                                    pathPattern: FilePathPatternsContainer.uploadPathPattern(),
                                    keyPath: "filenames",
                                    statusCodes:  RKStatusCodeIndexSetForClass(.Successful))
    }
    
}