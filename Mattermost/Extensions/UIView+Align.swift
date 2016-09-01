//
//  UIView+Align.swift
//  Mattermost
//
//  Created by Maxim Gubin on 09/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension UIView {
    func align() {
        self.frame = CGRectMake(ceil(self.frame.origin.x),
                                ceil(self.frame.origin.y),
                                ceil(self.frame.size.width),
                                ceil(self.frame.size.height))
    }
    
    func alignSubviews() {
        self.subviews.forEach { $0.align() }
    }
}