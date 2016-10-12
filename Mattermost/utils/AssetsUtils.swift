//
//  AssetsUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Photos

class AssetsUtils {
    static func convertedArrayOfAssets(_ assets: Array<PHAsset>) -> Array<AssignedAttachmentViewItem> {
        let assetManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        var array = Array<AssignedAttachmentViewItem>()
        for asset in assets {
            assetManager.requestImage(for: asset,
                                              targetSize: PHImageManagerMaximumSize,
                                              contentMode: .aspectFill,
                                              options: requestOptions,
                  resultHandler: { (image, metadata) in
                    array.append(AssignedAttachmentViewItem(image: image!))
            })
        }
        
        return array
    }
}
