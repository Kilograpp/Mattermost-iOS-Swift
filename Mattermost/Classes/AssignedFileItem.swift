//
//  AssignedFileItem.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 07.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class AssignedFileItem {
    
    init(data: Data) {
        self.data = data
        self.identifier = StringUtils.randomUUID()
    }
    
    let data: Data
    var uploaded = false
    var uploading = false
    var uploadProgress: Float = 0
    let identifier: String
}

extension AssignedFileItem: Equatable {}

// MARK: Equatable

func ==(lhs: AssignedFileItem, rhs: AssignedFileItem) -> Bool {
    return lhs.identifier == rhs.identifier
}


struct FileItem {
    let data: Data
    let identifier = StringUtils.randomUUID()
}
