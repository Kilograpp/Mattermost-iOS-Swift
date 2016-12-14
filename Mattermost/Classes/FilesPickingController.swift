//
//  FilesPickingModule.swift
//  Mattermost
//
//  Created by Maxim Gubin on 18/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import Photos

fileprivate protocol Interface {
    func pick()
    func reset()
    var attachmentItems: [AssignedAttachmentViewItem] { get }
    
    init<T: UIViewController>(dataSource: T) where T: FilesPickingControllerDataSource
}

protocol FilesPickingControllerDataSource: class {
    func attachmentsModule(controller: FilesPickingController) -> AttachmentsModule
}

final class FilesPickingController {
    let dataSource: FilesPickingControllerDataSource

    var attachmentItems: [AssignedAttachmentViewItem] = []
    fileprivate var imagePickingModule: ImagePickingModule!
    fileprivate var documentPickingModule: DocumentPickingModule!
    
    init<T: UIViewController>(dataSource: T) where T: FilesPickingControllerDataSource {
        self.dataSource = dataSource
        
        self.documentPickingModule = DocumentPickingModule(delegate: self, dataSource: self)
        self.imagePickingModule = ImagePickingModule(delegate: self, dataSource: self)
    }
}

// MARK: - Constants & Protocols
fileprivate let MaximumFilesToSend = 5

fileprivate protocol Pickers {
    func pickImage()
    func pickDocument()
    func presentPickerSelector()
}

fileprivate protocol Conditions {
    func haveSpaceForMoreItems() -> Bool
}

fileprivate protocol UserInteraction {
    func showMaximumAttachmentsLimitError()
}

fileprivate protocol Helpers {
    func viewController() -> UIViewController
}


// MARK: - Interface
extension FilesPickingController: Interface {
    func pick() {
        guard haveSpaceForMoreItems() else {
            showMaximumAttachmentsLimitError()
            return
        }
        presentPickerSelector()
    }
    
    func reset() {
        self.attachmentItems.removeAll()
    }
}

// MARK: - Pickers
extension FilesPickingController: Pickers {
    fileprivate func pickImage() {
        self.imagePickingModule.pick(max: MaximumFilesToSend - self.attachmentItems.count)
    }
    fileprivate func pickDocument() {
        self.documentPickingModule.pick()
    }
    fileprivate func presentPickerSelector() {
        let controller = UIAlertController(title: "Attachment", message: "Choose what you want to attach", preferredStyle: .actionSheet)
        
        let imagePickAction = UIAlertAction(title: "Photo/Picture", style: .default) { _ in
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.pickImage()
                return
            }
            
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    DispatchQueue.main.sync {
                        self.pickImage()
                    }
                case .denied:
                    DispatchQueue.main.sync {
                        AlertManager.sharedManager.showWarningWithMessage(message: "Application is not allowed to access Photo data.")
                        return
                    }
                default:
                    print("Default")
                }
            })
        }
        let filePickAction = UIAlertAction(title: "File", style: .default) { _ in
            self.pickDocument()
        }
        
        imagePickAction.setValue(UIImage(named:"gallery_icon"), forKey: "image")
        filePickAction.setValue(UIImage(named:"iCloud_icon"), forKey: "image")
        
        controller.addAction(imagePickAction)
        controller.addAction(filePickAction)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController().present(controller, animated: true) {}
    }
}

// MARK: - Conditions
extension FilesPickingController: Conditions {
    fileprivate func haveSpaceForMoreItems() -> Bool {
        return self.attachmentItems.count < MaximumFilesToSend
    }
}

// MARK: - User Interaction
extension FilesPickingController: UserInteraction {
    fileprivate func showMaximumAttachmentsLimitError() {
        AlertManager.sharedManager.showWarningWithMessage(message: "Maximum of attachments reached")
    }
}

// MARK: - Delegate & DataSource
extension FilesPickingController: FilesPickingModuleDelegate {
    func didPick(items: [AssignedAttachmentViewItem]) {
        self.attachmentItems += items
        self.dataSource.attachmentsModule(controller: self).upload(attachments: items)
    }
}

extension FilesPickingController: FilesPickingModuleDataSource {
    func items(filesPickingModule: FilesPickingModuleBase) -> [AssignedAttachmentViewItem] {
        return self.attachmentItems
    }
    func viewController(filesPickingModule: FilesPickingModuleBase) -> UIViewController {
        return viewController()
    }
}

// MARK: - Helpers
extension FilesPickingController: Helpers {
    func viewController() -> UIViewController {
        return self.dataSource as! UIViewController
    }
}
