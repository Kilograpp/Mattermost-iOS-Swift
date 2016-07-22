//
//  Preferences.swift
//  Mattermost
//
//  Created by Maxim Gubin on 29/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class Preferences: NSObject {
    static let sharedInstance = Preferences()
    var serverUrl: String?
    var currentUserId: String?
    var currentTeamId: String?
    var siteName: String?
    
    
    private override init() {}
    
    private func load() {
        self.enumerateProperties { (name) in
            
        }
    }
    
    private func save() {
    }
}

public enum PreferencesAttributes: String {
    case serverUrl = "serverUrl"
    case siteName = "siteName"
    case currentUserId = "currentUserId"
    case currentTeamId = "currentTeamId"
}