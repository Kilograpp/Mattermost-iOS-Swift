//
//  String+URLLocation.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSAttributedString {
    final func URLAtIndex(_ index: Int, effectiveRange: NSRangePointer? = nil) -> URL? {
        let value = self.attribute(NSLinkAttributeName, at: index, effectiveRange: effectiveRange)
        if let string = value as? String{
            return URL(string: string)!
        }
        return value as? URL
        
    }
    
    final func mentionAtIndex(_ index: Int, effectiveRange: NSRangePointer? = nil) -> String? {
        return self.attribute(Constants.StringAttributes.Mention, at: index, effectiveRange: effectiveRange) as? String
    }
    
    final func hashTagAtIndex(_ index: Int, effectiveRange: NSRangePointer? = nil) -> String? {
        return self.attribute(Constants.StringAttributes.HashTag, at: index, effectiveRange: effectiveRange) as? String
    }
    
    final func emailAtIndex(_ index: Int, effectiveRange: NSRangePointer? = nil) -> String? {
        return self.attribute(Constants.StringAttributes.Email, at: index, effectiveRange: effectiveRange) as? String
    }
    
    final func phoneAtIndex(_ index: Int, effectiveRange: NSRangePointer? = nil) -> String? {
        return self.attribute(Constants.StringAttributes.Phone, at: index, effectiveRange: effectiveRange) as? String
    }
}
