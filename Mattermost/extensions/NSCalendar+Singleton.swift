//
//  NSCalendar+Singleton.swift
//  Mattermost
//
//  Created by Maxim Gubin on 22/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension NSCalendar {
    @nonobjc static let sharedGregorianCalendar = NSCalendar.gregorianCalendar();
    
    private static func gregorianCalendar() -> NSCalendar! {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    }
}