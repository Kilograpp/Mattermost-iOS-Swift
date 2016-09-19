//
//  ChannelInfoUtils.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation


class TitleWithImageData: ChannelInfoCellObject {
    let title: String
    let image: UIImage
}

class TitleWithDetailData: ChannelInfoCellObject {
    let title: String
    let detail: String
}