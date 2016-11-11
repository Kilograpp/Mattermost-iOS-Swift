//
//  ChannelRequestDescriptorsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 10.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestDescriptor: class {
    static func createRequestDescriptor() -> RKRequestDescriptor
}

class ChannelRequestDescriptorsContainer: BaseRequestDescriptorsContainer {

}


//MARK: RequestDescriptor
extension ChannelRequestDescriptorsContainer: RequestDescriptor {
    static func createRequestDescriptor() -> RKRequestDescriptor {
        return RKRequestDescriptor(mapping: ChannelMappingsContainer.createRequestMapping(),
                                   objectClass: Channel.self,
                                   rootKeyPath: nil,
                                   method: .POST)
    }
}
