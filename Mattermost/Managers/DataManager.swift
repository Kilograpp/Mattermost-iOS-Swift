//
//  DataManager.swift
//  Mattermost
//
//  Created by Maxim Gubin on 01/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift


class DataManager {
    
    static let sharedInstance = DataManager();
    
    var currentUser: User? {
        get {return User.objectById(Preferences.sharedInstance.currentUserId!)}
        set {Preferences.sharedInstance.currentUserId = newValue!.identifier}
    }
      

    var currentTeam: Team? {
        get {return Team.objectById(Preferences.sharedInstance.currentTeamId!)}
        set {Preferences.sharedInstance.currentTeamId = newValue!.identifier}
    }
    
    var systemUser: User? { return User.objectById(Constants.Realm.SystemUserIdentifier) }
    
    func instantiateSystemUser() -> User {
        let user = User()
        user.identifier = Constants.Realm.SystemUserIdentifier
        user.nickname = "System"
        user.displayName = user.nickname
        
        return user
    }
    

    @objc func clearCachedResponses() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    fileprivate init() {
        subscribeNotifications()
    }
}

//MARK: - Notification Subscription
extension DataManager {
    func subscribeNotifications() {
        Observer.sharedObserver.subscribeForLogoutNotification(self, selector: #selector(clearCachedResponses))
    }
}
