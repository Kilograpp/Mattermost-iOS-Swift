//
//  Dictionary+Json.swift
//  Mattermost
//
//  Created by Maxim Gubin on 28/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension Dictionary {
    func toJsonData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self as AnyObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}
