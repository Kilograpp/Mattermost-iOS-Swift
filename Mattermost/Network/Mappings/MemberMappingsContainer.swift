//
//  MemberMappingsContainer.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 05.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol ResponseMappings: class {
    static func mapping() -> RKObjectMapping
}

final class MemberMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return Member.self
    }
}


//MARK: - ResponseMappings

extension MemberMappingsContainer: ResponseMappings {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "user_id"           : MemberAttributes.userId.rawValue,
            "last_viewed_at"    : MemberAttributes.lastViewedAt.rawValue,
            "msg_count"         : MemberAttributes.msgCount.rawValue,
            "mention_count"     : MemberAttributes.mentionCount.rawValue
            ])
        return mapping
    }
}
