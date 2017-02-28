//
//  AssignedPhotoViewItem.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class AssignedAttachmentViewItem {
    
    init(image: UIImage) {
        self.image = image
        self.identifier = StringUtils.randomUUID()
    }
    
    var image: UIImage
    var uploaded = false
    var uploading = false
    var uploadProgress: Float = 0
    let identifier: String
    var fileName: String?
    var isFile = false
    var url: URL?
    var backendIdentifier:String?
}

extension AssignedAttachmentViewItem: Equatable {}

// MARK: Equatable

func ==(lhs: AssignedAttachmentViewItem, rhs: AssignedAttachmentViewItem) -> Bool {
    return lhs.identifier == rhs.identifier
}


struct PhotoItem {
    let image: UIImage
    let identifier = StringUtils.randomUUID()
}
