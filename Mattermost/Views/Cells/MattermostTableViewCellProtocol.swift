//
//  BaseTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 26.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//


protocol MattermostTableViewCellProtocol : class {
    static func nib() -> UINib
    static func reuseIdentifier() -> String
}

extension MattermostTableViewCellProtocol {
        static func nib() -> UINib {
            return UINib(nibName: String(Self), bundle: nil)
        }
    
        static func reuseIdentifier() -> String {
            return "\(String(Self))Identifier"
        }
}