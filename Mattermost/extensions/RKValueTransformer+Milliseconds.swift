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
            return sourceClass.isSubclassOfClass(NSNumber) && destinationClass.isSubclassOfClass(NSDate)
        }) { (inputValue, outputValuePointer, outputValueClass, errorPointer) -> Bool in
            outputValuePointer.memory = NSDate(timeIntervalSince1970: (inputValue as? NSNumber)!.doubleValue / 1000)
            return true;
        }
    }
}