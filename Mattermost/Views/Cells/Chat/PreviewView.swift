//
//  PreviewView.swift
//  Mattermost
//
//  Created by TaHyKu on 23.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import MRProgress

final class PreviewView: UIView {

//MARK: Properties
    fileprivate let previewImageView = UIImageView()
    fileprivate let downloadinIconImageView = UIImageView()
    fileprivate let progressView = MRCircularProgressView()
    
    fileprivate var file = File()

    init(image: UIImage, fileId: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        initialSetup(image: image, fileId: fileId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension PreviewView {
    func initialSetup(image: UIImage, fileId: String) {
        self.file = RealmUtils.realmForCurrentThread().object(ofType: File.self, forPrimaryKey: fileId)!
        
    }
}
