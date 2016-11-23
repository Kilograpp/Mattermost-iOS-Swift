//
//  FileInfoResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 20.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit


private protocol ResponseDescriptors: class {
    static func getFileInfoResponseDescriptor() -> RKResponseDescriptor
}

class FileInfoResponseDescriptorsContainer: BaseResponseDescriptorsContainer {

}


//MARK: ResponseDescriptors
extension FileInfoResponseDescriptorsContainer: ResponseDescriptors {
    static func getFileInfoResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: FileInfoMappingsContainer.mapping(),
                                    method: .GET,
                                    pathPattern: FileInfoPathPatternsContainer.getInfoPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.successful))
    }
}
