//
//  StringUtils.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class StringUtils {
    
    static func emptyString() -> String {
        return ""
    }
    
    static func isEmpty(string: String?) -> Bool{
        if let unwrappedString = string {
            return unwrappedString.isEmpty
        }
        return true
    }
    static func isValidLink(string: String?) -> Bool {
        let types: NSTextCheckingType = .Link
        let detector = try? NSDataDetector(types: types.rawValue)
        guard let detect = detector else {
            return false
        }
        guard let text = string else {
            return false
        }
        let matches = detect.matchesInString(text, options: .ReportCompletion, range: NSMakeRange(0, text.characters.count))
        return matches.count > 0
    }
    
    static func widthOfString(string: NSString!, font: UIFont!) -> Float {
        let attributes = [NSFontAttributeName : font]
        return ceilf(Float(string.sizeWithAttributes(attributes).width))
    }
    
    static func heightOfAttributedString(attributedString: NSAttributedString!) -> Float {

        let textWidth: CGFloat = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings;
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        let frame = attributedString.boundingRectWithSize(CGSizeMake(textWidth, CGFloat.max), options: options, context: nil)
        return ceilf(Float(frame.size.height))
    }
}