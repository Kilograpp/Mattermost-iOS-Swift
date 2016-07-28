//
//  NSDateFormatter+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    @nonobjc static let sharedConversionSectionsDateFormatter = NSDateFormatter.conversionSectionsDateFormatter()
    
    private static func conversionSectionsDateFormatter() -> NSDateFormatter! {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter
    }
    
    func formattedDateForFeedSection(date: NSDate) -> String {
        return date.formattedDateWithFormat("MMM dd,yyyy", locale: NSLocale.init(localeIdentifier: "en_US_POSIX"))
    }
}