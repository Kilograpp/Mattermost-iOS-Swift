//
//  StringUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class StringUtils {
    static func emptyString() -> String {
        return ""
    }
    
    static func isEmpty(string: String?) -> Bool{
        if let unwrappedString = string {
            return unwrappedString.isEmpty
        }
        return true
    }
    static func widthOfString(string: NSString!, font: UIFont!) -> Float {
        let attributes = [NSFontAttributeName : font]
        return ceilf(Float(string.sizeWithAttributes(attributes).width))
    }
    static func heightOfAttributedString(attributedString: NSAttributedString!) -> Float {
        let textWidth: CGFloat = UIScreen.screenWidth() - 88;
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        let frame = attributedString.boundingRectWithSize(CGSizeMake(textWidth, CGFloat.max), options: options, context: nil)
        return ceilf(Float(CGRectGetHeight(frame)))
    }
}