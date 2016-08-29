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
    }
    
    var image: UIImage
    var uploaded = false
}