//
//  DocumentPickingModule.swift
//  Mattermost
//
//  Created by Maxim Gubin on 17/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate protocol Interface {
    func pick()
}

final class DocumentPickingModule: FilesPickingModuleBase { }

extension DocumentPickingModule: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileItem = AssignedAttachmentViewItem(image: UIImage(named: "attach_file_icon")!)
        fileItem.fileName = FileUtils.fileNameFromUrl(url: url)
        fileItem.isFile = true
        fileItem.url = url
        self.delegate.didPick(items: [ fileItem ])
    }
}

extension DocumentPickingModule: Interface {
    func pick() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.dataSource.viewController(filesPickingModule: self).present(documentPicker, animated:true, completion:nil)
    }
}
