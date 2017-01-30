//
//  String+JsonSerialization.swift
//  Mattermost
//
//  Created by Maxim Gubin on 26/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension String {
    func toDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
//                print(error)
            }
        }
        return nil
    }
}

extension NSString {
    func toDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8.rawValue) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
//                print(error)
            }
        }
        return nil
    }
}
