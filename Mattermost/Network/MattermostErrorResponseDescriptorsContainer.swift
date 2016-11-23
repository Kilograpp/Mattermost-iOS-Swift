//
//  MattermostErrorResponseDescriptorsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 15.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseDescriptors: class {
    static func mattermostErrorResponseDescriptor() -> RKResponseDescriptor
}

class MattermostErrorResponseDescriptorsContainer: BaseResponseDescriptorsContainer {

}


//MARK: ResponseDescriptors
extension MattermostErrorResponseDescriptorsContainer: ResponseDescriptors {
      static func mattermostErrorResponseDescriptor() -> RKResponseDescriptor {
        return RKResponseDescriptor(mapping: MattermostErrorMappingsContainer.mapping(),
                                    method: .any,
                                    pathPattern: ChannelPathPatternsContainer.createChannelPathPattern(),
                                    keyPath: nil,
                                    statusCodes: RKStatusCodeIndexSetForClass(.serverError))
    }
}
