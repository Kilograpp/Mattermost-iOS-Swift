//
//  NSIndexPath+PreviousPath.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension IndexPath {
    var previousPath: IndexPath {
        return IndexPath(row: (self as NSIndexPath).row + 1, section: (self as NSIndexPath).section)
    }
}
