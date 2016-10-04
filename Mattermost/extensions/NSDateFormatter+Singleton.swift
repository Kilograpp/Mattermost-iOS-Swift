//
//  NSDateFormatter+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension DateFormatter {
    @nonobjc static let sharedConversionSectionsDateFormatter = DateFormatter.conversionSectionsDateFormatter()
    
    fileprivate static func conversionSectionsDateFormatter() -> DateFormatter! {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter
    }
    
    func formattedDateForFeedSection(_ date: Date) -> String {
        return (date as NSDate).formattedDate(withFormat: "MMM dd,yyyy", locale: Locale.init(identifier: "en_US_POSIX"))
    }
}
