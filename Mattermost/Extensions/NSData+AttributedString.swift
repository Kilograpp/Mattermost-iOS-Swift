//
//  NSData+AttributedString.swift
//  Mattermost
//
//  Created by Maxim Gubin on 06/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSData {
    func unarchiveAsAttributedString() -> NSAttributedString? {
        return NSKeyedUnarchiver.unarchiveObjectWithData(self) as? NSAttributedString
    }
}