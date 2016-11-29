//
//  MattermostErrorMappingsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 15.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
}


class MattermostErrorMappingsContainer: /*BaseMappingsContainer*/RKObjectMapping {

}


//MARK: ResponseMappings
extension MattermostErrorMappingsContainer: ResponseMappings {
     class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: MattermostError.self)
        mapping?.addAttributeMappings(from: [
            "identifier"     : MattermostErrorAttributes.identifier.rawValue,
            "message"        : MattermostErrorAttributes.message.rawValue,
            "detailed_error" : MattermostErrorAttributes.detailedError.rawValue,
            "request_id"     : MattermostErrorAttributes.requestId.rawValue,
            "status_code"    : MattermostErrorAttributes.statusCode.rawValue
            ])
        return mapping!
    }
}
