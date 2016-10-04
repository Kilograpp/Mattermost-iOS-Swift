//
//  UITableView+PercentOffset.swift
//  Mattermost
//
//  Created by Maxim Gubin on 12/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension UITableView {
    func offsetFromTop() -> Int {
        return Int(self.contentSize.height) - (Int(self.contentOffset.y) + Int(self.bounds.size.height))
    }
    func lastIndexPath() -> IndexPath {
        return IndexPath(row: self.numberOfRows(inSection: self.numberOfSections - 1) - 1, section: self.numberOfSections - 1)
    }
}
