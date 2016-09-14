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
    
    override func title() -> String {
        return "Add Members"
    }
    
    override func imageForCellAccessoryViewWithUser(user:User) -> UIImage {
        return UIImage(named: usersList.contains(user) ? "user_in_channel" : "add_user_to_channel")!
    }
    
    override func sendAdditionalRequestForChannel(channel:Channel, completion: (error:Error?) -> Void){
        Api.sharedInstance.loadCompleteUsersList(completion)
    }
    
    override func didSelectUser(user:User) {
        if (usersList.contains(user)) {
            self.usersList.removeObject(user)
        } else {
            self.usersList.append(user)
        }
    }
    
    override func predicateWithChannel(channel:Channel) -> NSPredicate {
        let identifiers = channel.members.mutableArrayValueForKey("identifier")
        return NSPredicate(format: "!(identifier IN %@)", identifiers)
    }
    
    override func shouldSendAdditionalRequest() -> Bool {
        return true;
    }
    
    override func shouldShowRightBarButtonItem() ->Bool {
        return true;
    }
    
    override func addUsersToChannel(channel:Channel, completion:(error:Error?) -> Void) {
        let group = dispatch_group_create()
        var finalError : Error?
        // __block error = nil
        for user in self.usersList {
            dispatch_group_enter(group)
            Api.sharedInstance.addUserToChannel(user, channel: channel, completion: { (error) in
                finalError = error
                dispatch_group_leave(group)
            })
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) {
                completion(error: finalError)
        }
    }
    
    override func isAddMembers() -> Bool {
        return true;
    }
    
}