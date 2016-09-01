//
//  ProfileDataSource.swift
//  Mattermost
//
//  Created by TaHyKu on 31.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ProfileDataSource: NSObject {

//MARK: - Properties
    
    var title: String!
    var iconName: String!
    var info: String!
    var handler: (() -> Void)?
    
    
//MARK: - Life cycle
    
    class func entryWithTitle(title: String, iconName: String, info: String, handler: (() -> Void)) -> ProfileDataSource {
        let object = ProfileDataSource()
        
        object.title = title
        object.iconName = iconName
        object.info = info
        object.handler = handler

        return object
    }
}
