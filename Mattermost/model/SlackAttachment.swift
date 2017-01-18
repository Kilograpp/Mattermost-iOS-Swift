//
//  SlackAttachment.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 16.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation
import Realm

final class SlackAttachment : RealmObject {
    dynamic var colorHexString : String?
    dynamic var fallback: String?//to je 4to i text?
    dynamic var text: String?
    dynamic var author_name: String?
    dynamic var barColorHex: String?
    dynamic var preText: String?
    dynamic var authorName: String?
    dynamic var authorLink: String?
    dynamic var id: String?
}
