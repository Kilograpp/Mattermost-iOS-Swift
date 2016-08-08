//
//  StringParameter.swift
//  Mattermost
//
//  Created by Maxim Gubin on 07/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

final class StringParameter: Object {
    private dynamic var _rangeLocation: Int = 0
    private dynamic var _rangeLength: Int = 0
    var range: NSRange? {
        get {
            return NSMakeRange(self._rangeLocation, self._rangeLength)
        }
        set {
            self._rangeLocation = newValue?.location ?? 0
            self._rangeLength = newValue?.length ?? 0
        }
       
    }
    let attributes = List<StringAttribute>()
    
    override class func ignoredProperties() -> [String] {
        return ["range"]
    }
}