//
//  RKObjectRequestOperation+ImageUploading.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 19.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

class KGObjectRequestOperation: RKObjectRequestOperation {
    var image: UIImage?
    
    override static func canProcessRequest(request: NSURLRequest) -> Bool {
        return true
    }
}