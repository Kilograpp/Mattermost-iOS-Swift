//
//  String+URLLocation.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSAttributedString {
    final func URLAtIndex(index: Int) -> NSURL? {
        return self.attribute(NSLinkAttributeName, atIndex: index, effectiveRange: nil) as? NSURL

    }
    
    final func mentionAtIndex(index: Int) -> String? {
        return self.attribute(Constants.StringAttributes.Mention, atIndex: index, effectiveRange: nil) as? String
    }
    
    final func hashTagAtIndex(index: Int) -> String? {
        return self.attribute(Constants.StringAttributes.HashTag, atIndex: index, effectiveRange: nil) as? String
    }
    
}