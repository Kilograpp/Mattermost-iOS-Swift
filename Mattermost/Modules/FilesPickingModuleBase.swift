//
//  FilesPickingModuleBase.swift
//  Mattermost
//
//  Created by Maxim Gubin on 18/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate protocol Interface {
    func pick()
}

protocol FilesPickingModuleDataSource {
    func items(filesPickingModule: FilesPickingModuleBase) -> [AssignedAttachmentViewItem]
    func viewController(filesPickingModule: FilesPickingModuleBase) -> UIViewController
}

protocol FilesPickingModuleDelegate {
    func didPick(items: [AssignedAttachmentViewItem])
}

class FilesPickingModuleBase: NSObject, UINavigationControllerDelegate {
    let delegate: FilesPickingModuleDelegate
    let dataSource: FilesPickingModuleDataSource
    
    init(delegate: FilesPickingModuleDelegate,
         dataSource: FilesPickingModuleDataSource) {
        self.delegate = delegate
        self.dataSource = dataSource
    }
}
