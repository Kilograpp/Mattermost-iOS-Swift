//
//  UserStatusObserver.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 12.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Private : class {
    func setupStatusesArray()
    
    func updateStatusesForAllUsers()
    func setupTimer()
}

private protocol Public : class {
    func statusForUserWithIdentifier(identifier: String!) -> UserStatus
    func reloadWithStatusesArray(array: Array<UserStatus>)
    func startUpdating()
}

final class UserStatusObserver {
    private var statuses: Array<UserStatus>?
    private var updateRequestTimer: NSTimer?
    @nonobjc static let sharedObserver = UserStatusObserver.sharedInstanse()
    
    private init() {
        self.setupStatusesArray()
    }
}

extension UserStatusObserver : Public {
    func statusForUserWithIdentifier(identifier: String!) -> UserStatus {
        var status = self.statuses?.filter({ (status: UserStatus) -> Bool in
            return status.identifier == identifier
        }).first
        
        if status == nil {
            status = UserStatus()
            status?.identifier = identifier
            status?.backendStatus = "user_status_unknown"
            self.statuses?.append(status!)
        }
        
        return status!
    }
    
    func reloadWithStatusesArray(array: Array<UserStatus>) {
        for newStatus in array {
            let oldStatus = self.statuses?.filter({ (status: UserStatus) -> Bool in
                return status.identifier == newStatus.identifier
            }).first
            
            if oldStatus?.backendStatus != newStatus.backendStatus {
                oldStatus?.refreshWithBackendStatus(newStatus.backendStatus)
            }
            
            if oldStatus == nil {
                self.statuses?.append(newStatus)
                newStatus.refreshWithBackendStatus(newStatus.backendStatus)
            }
        }
    }
    
    func startUpdating() {
        self.setupTimer()
    }
}


extension UserStatusObserver {
    private static func sharedInstanse() -> UserStatusObserver {
        let sharedInstanse = UserStatusObserver()
        return sharedInstanse
    }
}

extension UserStatusObserver : Private {
    private func setupStatusesArray() {
        self.statuses = Array()
        let users = Array(RealmUtils.realmForCurrentThread().objects(User).filter(NSPredicate(format: "identifier != %@", "SystemUserIdentifier")))
        
        for user in users {
            let status = UserStatus()
            status.identifier = user.identifier
            status.backendStatus = "user_status_unknown"
            self.statuses?.append(status)
        }
    }
    

    @objc private func updateStatusesForAllUsers() {
        let users = Array(RealmUtils.realmForCurrentThread().objects(User).filter(NSPredicate(format: "identifier != %@", "SystemUserIdentifier")))
        Api.sharedInstance.updateStatusForUsers(users) { (error) in
            print("StRAX")
        }
    }
    
    private func setupTimer() {
        self.updateRequestTimer = NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: #selector(updateStatusesForAllUsers), userInfo: nil, repeats: true)
    }
}