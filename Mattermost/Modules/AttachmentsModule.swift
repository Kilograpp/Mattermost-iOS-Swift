//
//  DialogueAttachmentsService.swift
//  Mattermost
//
//  Created by Maxim Gubin on 17/10/2016.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate protocol Interface {
    func upload(attachments: [AssignedAttachmentViewItem])
    func reset()
}

protocol AttachmentsModuleDelegate: class {
    func uploading(inProgress: Bool)
}

protocol AttachmentsModuleDataSource {
    func tableView(attachmentsModule: AttachmentsModule) -> UITableView
    func postAttachmentsView(attachmentsModule: AttachmentsModule) -> PostAttachmentsView
    func channel(attachmentsModule: AttachmentsModule) -> Channel
}

final class AttachmentsModule {
    let delegate: AttachmentsModuleDelegate
    let dataSource: AttachmentsModuleDataSource
    fileprivate let viewController: UIViewController

    fileprivate var items: [AssignedAttachmentViewItem] = []
    var fileUploadingInProgress: Bool = true {
        didSet {
            //if self.fileUploadingInProgress { print("done"); self.dataSource.tableView(attachmentsModule: self).reloadData() }
            self.delegate.uploading(inProgress: self.fileUploadingInProgress)
        }
    }

    init<T: UIViewController>(delegate: AttachmentsModuleDelegate, dataSource: T) where T: AttachmentsModuleDataSource {
        self.dataSource = dataSource
        self.delegate = delegate
        self.viewController = dataSource
        
        self.dataSource.postAttachmentsView(attachmentsModule: self).delegate = self
        self.dataSource.postAttachmentsView(attachmentsModule: self).dataSource = self
    }
}

fileprivate protocol AttachmentsViewControls {
    func hideAttachmentsView()
    func showAttachmentsView()
}

fileprivate protocol UserInteraction {
    func show(error: Error)
}

extension AttachmentsModule: Interface {
    
    func reset() {
        self.items.removeAll()
        self.hideAttachmentsView()
    }
    
    func upload(attachments: [AssignedAttachmentViewItem]) {
        showAttachmentsView()
        self.fileUploadingInProgress = false

        items.append(contentsOf: attachments)
        
        PostUtils.sharedInstance.upload(items: attachments, channel: self.dataSource.channel(attachmentsModule: self), completion: { (finished, error, item) in
            defer {
                let index = self.items.index(of: item)
                if index != nil { self.dataSource.postAttachmentsView(attachmentsModule: self).removeActivityAt(index: index!) }
                self.fileUploadingInProgress = finished
            }

            guard let error = error else { return }
            self.show(error: error)
            self.items.removeObject(item)
            self.dataSource.postAttachmentsView(attachmentsModule: self).updateAppearance()
            
            guard self.items.count == 0 else { return }
            self.hideAttachmentsView()
            
        }) { (value, index) in
            self.items[index].uploaded = value == 1
            self.items[index].uploading = value < 1
            self.items[index].uploadProgress = value
            self.dataSource.postAttachmentsView(attachmentsModule: self).updateProgressValueAtIndex(index, value: value)
        }
    }
}

extension AttachmentsModule: PostAttachmentViewDelegate {
    func didRemove(item: AssignedAttachmentViewItem) {
        PostUtils.sharedInstance.cancelUpload(item: item)
        self.items.removeObject(item)
        
        guard self.items.count == 0 else { return }
        self.fileUploadingInProgress = false
        self.hideAttachmentsView()

    }
    
    func attachmentsViewWillAppear() {
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.bottom = PostAttachmentsView.attachmentsViewHeight
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
    }
    
    func attachmentViewWillDisappear() {
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.top = 0
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
    }
}

extension AttachmentsModule: AttachmentsViewControls {
    func showAttachmentsView() {
        self.dataSource.postAttachmentsView(attachmentsModule: self).showAnimated()
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.top = PostAttachmentsView.attachmentsViewHeight
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
        self.dataSource.postAttachmentsView(attachmentsModule: self).updateAppearance()
    }
    
    func hideAttachmentsView() {
        self.dataSource.postAttachmentsView(attachmentsModule: self).hideAnimated()
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.top = 0
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
    }
}

extension AttachmentsModule: UserInteraction {
    fileprivate func show(error: Error) {
        AlertManager.sharedManager.showErrorWithMessage(message: error.message!)//, viewController: self.viewController)
    }
}

extension AttachmentsModule: PostAttachmentViewDataSource {
    func item(atIndex index: Int) -> AssignedAttachmentViewItem {
        return self.items[index]
    }
    
    func numberOfItems() -> Int {
        return self.items.count
    }
}
