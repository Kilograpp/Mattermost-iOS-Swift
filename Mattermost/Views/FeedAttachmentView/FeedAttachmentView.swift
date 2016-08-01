//
//  FeedAttachmentView.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 01.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class FeedAttachmentView: UIView {
    var file: File?
    
}

private protocol Configuration {
    func configureWithFile(file: File)
}

protocol Public {
    func heightWithFile(file: File)
}
