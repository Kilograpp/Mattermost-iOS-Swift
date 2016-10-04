//
//  Array+RemoveObject.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 01.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
}
