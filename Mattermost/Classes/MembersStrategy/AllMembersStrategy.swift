//
//  AllMembersStrategy.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 09.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class AllMembersStrategy: MembersStrategy {
    override func title() -> String {
        return "All Members"
    }
    
     override func imageForCellAccessoryViewWithUser(user:User) -> UIImage {
        return UIImage(named: "send_private_msg_icon")!
    }
    
     override func sendAdditionalRequestForChannel(channel:Channel, completion: (error:Error?) -> Void){
        Api.sharedInstance.loadExtraInfoForChannel(channel, completion: completion)
    }
    
     override func predicateWithChannel(channel:Channel) -> NSPredicate {
        let identifiers = channel.members.mutableArrayValueForKey("identifier")
        return NSPredicate(format: "identifier IN %@", identifiers)
    }
    
    override func shouldSendAdditionalRequest() -> Bool {
        return true;
    }
    
    // todo: implement did select
    
}