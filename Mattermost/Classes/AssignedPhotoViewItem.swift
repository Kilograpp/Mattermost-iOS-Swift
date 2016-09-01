//
//  AssignedPhotoViewItem.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class AssignedPhotoViewItem {
    
    init(image: UIImage) {
        self.image = image
        self.identifier = StringUtils.randomUUID()
    }
    
    var image: UIImage
    var uploaded = false
    var uploading = false
//    var needsUploading: Bool {
//        return up
//    }
    var uploadProgress: Float = 0
    var identifier: String
}

extension AssignedPhotoViewItem: Equatable {}

// MARK: Equatable

func ==(lhs: AssignedPhotoViewItem, rhs: AssignedPhotoViewItem) -> Bool {
    return lhs.identifier == rhs.identifier
}