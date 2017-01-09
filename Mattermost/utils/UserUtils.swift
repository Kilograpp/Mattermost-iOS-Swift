//
//  UserUtils.swift
//  Mattermost
//
//  Created by TaHyKu on 28.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

class UserUtils: NSObject {
    static func userFrom(dictionary: Dictionary<String, Any>) -> User {
        let user = User()
        user.identifier  = dictionary["id"] as! String!
        user.createAt    = Date(timeIntervalSince1970: dictionary["create_at"] as! TimeInterval)
        user.updateAt    = Date(timeIntervalSince1970: dictionary["update_at"] as! TimeInterval)
        user.deleteAt    = Date(timeIntervalSince1970: dictionary["delete_at"] as! TimeInterval)
        user.username    = dictionary["username"] as! String?
        user.authData    = dictionary["auth_data"] as! String?
        user.authService = dictionary["auth_service"] as! String?
        user.email       = dictionary["email"] as! String?
        user.nickname    = dictionary["nickname"] as! String?
        user.firstName   = dictionary["first_name"] as! String?
        user.lastName    = dictionary["last_name"] as! String?
        user.roles       = dictionary["roles"] as! String?
        user.locale      = dictionary["locale"] as! String?
        user.computeDisplayName()
        
        return user
    }
    
    static func updateOnTeamAndPreferedStatesFor(user: User) {
        let predicate = NSPredicate(format: "name == %@", user.identifier)
        let preferences = DataManager.sharedInstance.currentUser?.preferences.filter(predicate)
        if preferences?.first != nil {
            user.isOnTeam = ((preferences?.first?.value)! == Constants.CommonStrings.True)
        }
        
        let realm = RealmUtils.realmForCurrentThread()
        let preferedPredicate = NSPredicate(format: "name == %@", user.identifier)
        let isPrefered = Preference.preferedUsersList().filter(preferedPredicate).count > 0
  
        try! realm.write {
            let existUser = realm.object(ofType: User.self, forPrimaryKey: user.identifier)
            if existUser == nil {
                realm.add(user)
                
                guard user.hasChannel() else { return }
                user.directChannel().isDirectPrefered = isPrefered
                user.directChannel().displayName = user.displayName
            } else {
                guard (existUser?.hasChannel())! else { return }
                existUser?.directChannel().isDirectPrefered = isPrefered
                existUser?.directChannel().displayName = user.displayName
            }
        }
    }
    
    static func updateCurrentUserWith(serverUser: User) {
        let currentUser = DataManager.sharedInstance.currentUser
        
        let serverUserNotifyProps = serverUser.notifyProps
        serverUserNotifyProps?.userId = serverUser.identifier
        serverUserNotifyProps?.computeKey()
        
        let realm = RealmUtils.realmForCurrentThread()
        try! realm.write {
            currentUser?.updateAt = serverUser.updateAt
            currentUser?.deleteAt = serverUser.deleteAt
            currentUser?.username = serverUser.username
            currentUser?.email = serverUser.email
            currentUser?.nickname = serverUser.nickname
            currentUser?.firstName = serverUser.firstName
            currentUser?.lastName = serverUser.lastName

            realm.delete((currentUser?.notifyProps)!)
            realm.add(serverUserNotifyProps!)
            currentUser?.notifyProps = serverUserNotifyProps
        }
    }
    
    static func update(existUser: User, serverUser: User) {
        let realm = RealmUtils.realmForCurrentThread()
        
        try! realm.write {
            existUser.updateAt = serverUser.updateAt
            existUser.deleteAt = serverUser.deleteAt
            existUser.username = serverUser.username
            existUser.email = serverUser.email
            existUser.nickname = serverUser.nickname
            existUser.firstName = serverUser.firstName
            existUser.lastName = serverUser.lastName
            }
        
        guard existUser.identifier == DataManager.sharedInstance.currentUser?.identifier else { return }
            let serverUserNotifyProps = serverUser.notifyProps
            serverUserNotifyProps?.userId = serverUser.identifier
            serverUserNotifyProps?.computeKey()

        try! realm.write {
            realm.delete((existUser.notifyProps)!)
            realm.add(serverUserNotifyProps!)
            existUser.notifyProps = serverUserNotifyProps
        }
    }
}
