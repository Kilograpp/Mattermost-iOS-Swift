//
//  BaseTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


protocol Reusable: class {
    static var nib: UINib {get}
    static var reuseIdentifier: String {get}
}


extension Reusable {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return "\(String(describing: self))Identifier"
    }
}
