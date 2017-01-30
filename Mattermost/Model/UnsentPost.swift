//
//  UnsentPost.swift
//  Mattermost
//
//  Created by Владислав on 26.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

enum UnsentPostAttributes: String {
    case message      = "message"
    case files       = "files"
}

final class UnsentPost: RealmObject {
    dynamic var message = ""
    var files = List<File>()
}

