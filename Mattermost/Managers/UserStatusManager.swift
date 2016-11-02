//
//  UserStatusManager.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 20.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class UserStatusManager {
    static let sharedInstance = UserStatusManager()
}

//MARK: - Authorization
extension UserStatusManager {
    func login() {
            //<- from LoginViewController
    }
    func logout() {
        Api.sharedInstance.logout { (error) in
            // cookie deleting automatically? (Api.shared...cookie becomes nil)
//            SocketManager.sharedInstance.disconnect()
//            Preferences.sharedInstance.save()
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName), object: nil))
            RealmUtils.deleteAll()
            Preferences.sharedInstance.currentTeamId = nil
            RouterUtils.loadInitialScreen()
            SocketManager.resetSocket()
        }
    }
}


//MARK: - User state
extension UserStatusManager {
    func cookie() -> HTTPCookie? {
        return HTTPCookieStorage.shared.cookies?.filter { $0.name == Constants.Common.MattermostCookieName }.first
    }
    func isSignedIn() -> Bool {
        return self.cookie() != nil
    }
}
