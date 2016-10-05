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
    
    static func isEmpty(_ string: String?) -> Bool{
        if let unwrappedString = string {
            return unwrappedString.isEmpty
        }
        return true
    }
    static func isValidLink(_ string: String?) -> Bool {
        let types: NSTextCheckingResult.CheckingType = .link
        let detector = try? NSDataDetector(types: types.rawValue)
        guard let detect = detector else {
            return false
        }
        guard let text = string else {
            return false
        }
        let matches = detect.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.characters.count))
        return matches.count > 0
    }
    
    static func widthOfString(_ string: NSString!, font: UIFont?) -> Float {
        let attributes = [NSFontAttributeName : font!]
        return ceilf(Float(string.size(attributes: attributes).width))
    }
    
    static func heightOfAttributedString(_ attributedString: NSAttributedString!) -> Float {

//        let textWidth: CGFloat = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings;
        let textWidth: CGFloat = UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize;
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let frame = attributedString.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude), options: options, context: nil)
        return ceilf(Float(frame.size.height))
    }
    
    static func randomUUID() -> String {
        let newUniqueId = CFUUIDCreate(kCFAllocatorDefault)
        let uuidString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId)
        
        return uuidString as! String
    }
}
