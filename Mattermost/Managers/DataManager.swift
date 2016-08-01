//
//  DataManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 01/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift


final class DataManager {
    
    static let sharedInstance = DataManager();
    
    var currentUser: User? {
        get {return User.objectById(Preferences.sharedInstance.currentUserId!)}
        set {Preferences.sharedInstance.currentUserId = newValue!.identifier}
    }
      

    var currentTeam: Team? {
        get {return Team.objectById(Preferences.sharedInstance.currentTeamId!)}
        set {Preferences.sharedInstance.currentTeamId = newValue!.identifier}
    }
    
    private init() {}
}