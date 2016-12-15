//
//  NotifyPropsMappingContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol RequestMapping: class {
    static func updateRequestMapping() -> RKObjectMapping
}

final class NotifyPropsMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return NotifyProps.self
    }
    
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "channel"           : NotifyPropsAttributes.channel.rawValue,
            "comments"          : NotifyPropsAttributes.comments.rawValue,
            "desktop"           : NotifyPropsAttributes.desktop.rawValue,
            "desktop_duration"  : NotifyPropsAttributes.desktopDuration.rawValue,
            "desktop_sound"     : NotifyPropsAttributes.desktopSound.rawValue,
            "email"             : NotifyPropsAttributes.email.rawValue,
            "first_name"        : NotifyPropsAttributes.firstName.rawValue,
            "mention_keys"      : NotifyPropsAttributes.mentionKeys.rawValue,
            "push"              : NotifyPropsAttributes.push.rawValue,
            "push_status"       : NotifyPropsAttributes.pushStatus.rawValue
            ])
        return mapping
    }
}

//MARK: RequestMapping
extension NotifyPropsMappingsContainer: RequestMapping {
    static func updateRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.request()
        mapping?.addAttributeMappings(from: [
            NotifyPropsAttributes.userId.rawValue          : "user_id",
            NotifyPropsAttributes.channel.rawValue         : "channel",
            NotifyPropsAttributes.comments.rawValue        : "comments",
            NotifyPropsAttributes.desktop.rawValue         : "desktop",
            NotifyPropsAttributes.desktopDuration.rawValue : "desktop_duration",
            NotifyPropsAttributes.desktopSound.rawValue    : "desktop_sound",
            NotifyPropsAttributes.email.rawValue           : "email",
            NotifyPropsAttributes.firstName.rawValue       : "first_name",
            NotifyPropsAttributes.mentionKeys.rawValue     : "mention_keys",
            NotifyPropsAttributes.push.rawValue            : "push",
            NotifyPropsAttributes.pushStatus.rawValue      : "push_status"
            ])
        return mapping!
    }
}
