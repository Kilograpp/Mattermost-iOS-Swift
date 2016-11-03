//
//  NotifyPropsPathPatternsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 03.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func updatePathPattern() -> String
}

final class NotifyPropsPathPatternsContainer: PathPatterns {
    static func updatePathPattern() -> String {
        return "users/update_notify"
    }
}
