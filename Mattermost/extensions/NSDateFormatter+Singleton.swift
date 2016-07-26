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
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }
}