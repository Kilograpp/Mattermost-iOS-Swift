//
//  AllMembersStrategy.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class AllMembersStrategy: MembersStrategy {
    func title() -> String {
        return nil
    }
    
    func imageForCellAccessoryViewWithUser(user:User) -> UIImage {
        return nil
    }
    
    func sendAdditionalRequestForChannel(channel:Channel, completion: () -> Void){
        
    }
    
    func didSelectUser(user:User) {
        
    }
    
    func predicateWithChannel(channel:Channel) -> NSPredicate {
        return nil;
    }
    
    func shouldSendAdditionalRequest() -> Bool {
        return false;
    }
    
    func shouldShowRightBarButtonItem() ->Bool {
        return false;
    }
    
    func addUsersToChannel(channel:Channel, completion:() -> Void) {
        
    }
    
    func isAddMembers() -> Bool {
        return false;
    }
    
}