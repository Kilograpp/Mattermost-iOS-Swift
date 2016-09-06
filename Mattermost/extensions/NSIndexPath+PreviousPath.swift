//
//  NSIndexPath+PreviousPath.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSIndexPath {
    var previousPath: NSIndexPath {
        return NSIndexPath(forRow: self.row + 1, inSection: self.section)
    }
}