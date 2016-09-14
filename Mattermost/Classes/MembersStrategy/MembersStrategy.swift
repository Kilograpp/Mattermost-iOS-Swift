//
//  File.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class MembersStrategy {
    func title() -> String {
        return ""
    }
    
    func imageForCellAccessoryViewWithUser(user:User) -> UIImage {
        return UIImage()
    }
    
    func sendAdditionalRequestForChannel(channel:Channel, completion: (error:Error?) -> Void){
        
    }
    
    func didSelectUser(user:User) {
    
    }
    
    func predicateWithChannel(channel:Channel) -> NSPredicate {
        return NSPredicate();
    }
    
    func shouldSendAdditionalRequest() -> Bool {
        return false;
    }
    
    func shouldShowRightBarButtonItem() ->Bool {
        return false;
    }
    
    func addUsersToChannel(channel:Channel, completion:(error:Error?) -> Void) {
    
    }
    
    func isAddMembers() -> Bool {
        return false;
    }

}