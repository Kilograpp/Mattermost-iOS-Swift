//
// Created by Maxim Gubin on 29/06/16.
// Copyright (c) 2016 Kilograpp. All rights reserved.
//

import Foundation
import ObjectiveC

extension NSObject {
    func enumerateProperties(with block:(name: String) -> Void) {
        var outCount: UInt32 = 0;
        let properties = class_copyPropertyList(object_getClass(self), &outCount);
        for index in 0..<Int(outCount) {
            let property = properties[index];
            if let propertyName = String(CString: property_getName(property), encoding: NSUTF8StringEncoding) {
                block(name: propertyName)
            }
        }
        free(properties)
    }
}
