//
//  Dictionary+Json.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension Dictionary {
    func toJsonData() -> NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(self as! AnyObject, options: NSJSONWritingOptions.PrettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}