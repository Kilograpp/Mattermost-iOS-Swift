//
//  NSAttributedString+Archive.swift
//  Mattermost
//
//  Created by Maxim Gubin on 06/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func archive() -> NSData? {
        return NSKeyedArchiver.archivedDataWithRootObject(self)
    }
}