//
//  PreferencesPathPatternsContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 30.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PathPatterns: class {
    static func savePathPattern() -> String
    static func listPreferencesPathPatterns() -> String
}

final class PreferencesPathPatternsContainer: PathPatterns {
    static func savePathPattern() -> String {
        return "preferences/save"
    }
    
    static func listPreferencesPathPatterns() -> String {
        return "preferences/:\(PreferenceAttributes.category)"
    }
}
