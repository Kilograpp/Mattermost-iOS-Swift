//
//  AddMembersStrategy.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class AddMembersStrategy: MembersStrategy {
    
    private var usersList = [User]()
    
    func title() -> String {
        return "Add Members"
    }
    
    func imageForCellAccessoryViewWithUser(user:User) -> UIImage {
        return UIImage(named: usersList.contains(user) ? "user_in_channel" : "add_user_to_channel")
    }
    
    func sendAdditionalRequestForChannel(channel:Channel, completion: (error:Error?) -> Void){
        Api.sharedInstance.loadCompleteUsersList(completion)
    }
    
    func didSelectUser(user:User) {
        if (usersList.contains(user)) {
            self.usersList.removeObject(user)
        } else {
            self.usersList.append(user)
        }
    }
    
    func predicateWithChannel(channel:Channel) -> NSPredicate {
        return NSPredicate(format: "NOT (self IN %@", channel.members)
    }
    
    func shouldSendAdditionalRequest() -> Bool {
        return true;
    }
    
    func shouldShowRightBarButtonItem() ->Bool {
        return true;
    }
    
    func addUsersToChannel(channel:Channel, completion:() -> Void) {
        let group = dispatch_group_create()
        // __block error = nil
        for user in self.usersList {
            dispatch_group_enter(group)
            Api.sharedInstance.
        }
    }
    
    func isAddMembers() -> Bool {
        return true;
    }
    
    
    //MARK: - Private functions
    private func dataSourceWithChannel (channel:Channel) -> [User] {
        return Realm().objects(User)
    }
    
}