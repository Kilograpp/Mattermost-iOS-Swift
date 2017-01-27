//
//  MillisecondsDateTransformer.swift
//  Mattermost
//
//  Created by Maxim Gubin on 29/06/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension RKValueTransformer {
    class func millisecondsToDateValueTransformer() -> RKValueTransformer {
        return RKBlockValueTransformer(validationBlock: { (sourceClass, destinationClass) -> Bool in
            return (sourceClass is NSNumber.Type) && (destinationClass is Date.Type || destinationClass is NSDate.Type)
        }) { (inputValue, outputValuePointer, outputValueClass, errorPointer) -> Bool in
//            outputValuePointer?.pointee = NSDate(timeIntervalSince1970: (inputValue as? NSNumber)!.doubleValue / 1000)
            outputValuePointer?.pointee = Date(timeIntervalSince1970: (inputValue as? NSNumber)!.doubleValue / 1000) as AnyObject?
            return true;
        }
    }
}
