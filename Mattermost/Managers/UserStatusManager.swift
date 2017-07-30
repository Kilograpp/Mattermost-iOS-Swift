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
        if Api.sharedInstance.isNetworkReachable() {
            Api.sharedInstance.logout { (error) in
                self.resetCookie()
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Constants.NotificationsNames.UserLogoutNotificationName), object: nil))
                RealmUtils.deleteAll()
                Preferences.sharedInstance.currentTeamId = nil
                RouterUtils.loadInitialScreen()
                SocketManager.resetSocket()
            }
        } else {
            resetCookie()
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
    func resetCookie() {
        guard isSignedIn() else { return }
        
        let cookie = self.cookie()
        HTTPCookieStorage.shared.deleteCookie(cookie!)
    }
    func isSignedIn() -> Bool {
        return self.cookie() != nil && Preferences.sharedInstance.currentUserId != nil
    }
}
