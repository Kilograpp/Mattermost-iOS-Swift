//
//  ChannelCreateField.swift
//  Mattermost
//
//  Created by Владислав on 14.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ChannelCreateField{
    var placeholder = ""
    var key = ""
    var value = ""
    
    init(_ placeholder:String ,_ key:String) {
        self.placeholder = placeholder
        self.key = key
    }
}
