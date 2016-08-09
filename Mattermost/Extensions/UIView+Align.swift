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
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)
    }
    
    func alignSubviews() {
        self.subviews.forEach { $0.align() }
    }
}