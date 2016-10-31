//
//  PreferencesPathPatterns.swift
//  Mattermost
//
//  Created by TaHyKu on 30.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol PathPatterns: class {
    static func savePathPattern() -> String
}

final class PreferencesPathPatterns: PathPatterns {
    static func savePathPattern() -> String {
        return "preferences/save"
    }
}
