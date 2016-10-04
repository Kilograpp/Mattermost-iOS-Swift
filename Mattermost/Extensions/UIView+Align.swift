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
        self.frame = CGRect(x: ceil(self.frame.origin.x),
                                y: ceil(self.frame.origin.y),
                                width: ceil(self.frame.size.width),
                                height: ceil(self.frame.size.height))
    }
    
    func alignSubviews() {
        self.subviews.forEach { $0.align() }
    }
}
