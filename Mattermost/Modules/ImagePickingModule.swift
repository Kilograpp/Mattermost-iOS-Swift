//
//  ImagePickingModule.swift
//  Mattermost
//
//  Created by Maxim Gubin on 17/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import ImagePickerSheetController
import AVFoundation

fileprivate protocol Interface {
    func pick(max: Int)
}

final class ImagePickingModule: FilesPickingModuleBase {}

extension ImagePickingModule: Interface {
    func pick(max: Int) {
        let presentImagePickerController: (UIImagePickerControllerSourceType, UIImagePickerControllerCameraCaptureMode) -> () = { source, cameraMode in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = source
            
            if cameraMode == .video {
                picker.mediaTypes = [kUTTypeMovie as String]
            }
                
            if source == .camera {
                picker.cameraCaptureMode = cameraMode
            }
                
            self.dataSource.viewController(filesPickingModule: self).present(picker, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
        controller.maximumSelection = max
        let assignImagesHandler = {
            let convertedAssets = AssetsUtils.convertedArrayOfAssets(controller.selectedImageAssets)
            self.delegate.didPick(items: convertedAssets)
        }
        
        let cameraAction = ImagePickerAction(title: "Gallery", secondaryTitle: "Send", style: .default, handler: { _ in
            presentImagePickerController(.photoLibrary, .photo)
        }) { (_, numberOfPhotos) in
            assignImagesHandler()
        }
        controller.addAction(cameraAction)
        
        let videoAction = ImagePickerAction(title: "Take Video", secondaryTitle: "Take Video", style: .default, handler: { _ in
            guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .denied else {
                AlertManager.sharedManager.showWarningWithMessage(message: "Access denied. You can unlock camera in the system settings.")
                return
            }
            presentImagePickerController(.camera, .video)
        }) { (_, numberOfPhotos) in
            presentImagePickerController(.camera, .video)
        }
        controller.addAction(videoAction)
        
        let photoAction = ImagePickerAction(title: "Take Photo", secondaryTitle: "Take Photo", style: .default, handler: { _ in
            guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .denied else {
                AlertManager.sharedManager.showWarningWithMessage(message: "Access denied. You can unlock camera in the system settings.")
                return
            }
            presentImagePickerController(.camera, .photo)
        }) { (_, numberOfPhotos) in
            presentImagePickerController(.camera, .photo)
        }
        controller.addAction(photoAction)
        
        
        controller.addAction(ImagePickerAction(cancelTitle: NSLocalizedString("Cancel", comment: "Action Title")))
        self.dataSource.viewController(filesPickingModule: self).present(controller, animated: true, completion: nil)
    }
}

extension ImagePickingModule: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) != .denied else {
            AlertManager.sharedManager.showWarningWithMessage(message: "Access denied. You can unlock camera in the system settings.")
            picker.dismiss(animated: true) { }
            return
        }
        if (info[UIImagePickerControllerMediaType] as! String != kUTTypeImage as String) {
            let fileItem = AssignedAttachmentViewItem(image: UIImage(named: "attach_file_icon")!)
            let url = info[UIImagePickerControllerMediaURL] as! URL
            fileItem.fileName = FileUtils.fileNameFromUrl(url: url)
            fileItem.isFile = true
            fileItem.url = url
            self.delegate.didPick(items: [ fileItem ])

        } else {
            var image = info[UIImagePickerControllerOriginalImage] as! UIImage
            image = image.fixedOrientation()
            let presentImage = UIImage(data:UIImageJPEGRepresentation(image, 0)!)
            let imageItem = AssignedAttachmentViewItem(image: presentImage!)
            self.delegate.didPick(items: [ imageItem ])
        }
        picker.dismiss(animated: true) { }
    }
}
