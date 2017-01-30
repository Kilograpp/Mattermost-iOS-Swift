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
    func presentWithCachedItems()
}

protocol AttachmentsModuleDelegate: class {
    func uploading(inProgress: Bool, countItems: Int)
    func removedFromUploading(identifier: String)
}

protocol AttachmentsModuleDataSource {
    func tableView(attachmentsModule: AttachmentsModule) -> UITableView
    func scrollButton(attachmentsModule: AttachmentsModule) -> UIButton
    func postAttachmentsView(attachmentsModule: AttachmentsModule) -> PostAttachmentsView
    func channel(attachmentsModule: AttachmentsModule) -> Channel
}

final class AttachmentsModule {
    let delegate: AttachmentsModuleDelegate
    let dataSource: AttachmentsModuleDataSource
    var isPresented: Bool = false
    let cache = AttachedFileCache()
    fileprivate let viewController: UIViewController

    fileprivate var items: [AssignedAttachmentViewItem] = []
    var fileUploadingInProgress: Bool = true {
        didSet {
            //if self.fileUploadingInProgress { print("done"); self.dataSource.tableView(attachmentsModule: self).reloadData() }
            self.delegate.uploading(inProgress: self.fileUploadingInProgress, countItems: self.items.count)
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
    func presentWithCachedItems() {
        let channel = self.dataSource.channel(attachmentsModule: self)
        self.items = cache.cachedFilesForChannel(channel)!
        
        self.showAttachmentsView()
    }
    
    func reset() {
        self.items.removeAll()
        self.hideAttachmentsView()
        let channel = self.dataSource.channel(attachmentsModule: self)
        self.cache.clearFilesForChannel(channel)
    }
    
    func upload(attachments: [AssignedAttachmentViewItem]) {
        showAttachmentsView()
        self.fileUploadingInProgress = false

        items.append(contentsOf: attachments)
        
        let channel = self.dataSource.channel(attachmentsModule: self)
        cache.cacheFilesForChannel(items: attachments, channel: channel)
        PostUtils.sharedInstance.upload(items: attachments, channel: channel, completion: { (finished, error, item) in
            defer {
                let index = self.items.index(of: item)
                if index != nil { self.dataSource.postAttachmentsView(attachmentsModule: self).removeActivityAt(index: index!) }
                self.fileUploadingInProgress = true
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
        let itemId = item.identifier
        PostUtils.sharedInstance.cancelUpload(item: item)
        self.items.removeObject(item)
        self.delegate.removedFromUploading(identifier: itemId)
        
        guard self.items.count == 0 else { return }
        self.fileUploadingInProgress = true
        self.hideAttachmentsView()
    }
    
    func attachmentsViewWillAppear() {
        DispatchQueue.main.async { [unowned self] in
            var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
            //oldInset.bottom = PostAttachmentsView.attachmentsViewHeight
            oldInset.top = PostAttachmentsView.attachmentsViewHeight
            self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
            self.dataSource.tableView(attachmentsModule: self).scrollIndicatorInsets = oldInset
            self.dataSource.scrollButton(attachmentsModule: self).frame = CGRect(x: UIScreen.screenWidth() - 60, y: UIScreen.screenHeight() - 100 - PostAttachmentsView.attachmentsViewHeight, width: 50, height: 50)

        }
    }
    
    func attachmentViewWillDisappear() {
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.top = 0
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
        self.dataSource.tableView(attachmentsModule: self).scrollIndicatorInsets = oldInset
        self.dataSource.scrollButton(attachmentsModule: self).frame = CGRect(x: UIScreen.screenWidth() - 60, y: UIScreen.screenHeight() - 100, width: 50, height: 50)
    }
}

extension AttachmentsModule: AttachmentsViewControls {
    func showAttachmentsView() {
        isPresented = true
        self.dataSource.postAttachmentsView(attachmentsModule: self).showAnimated()
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.top = PostAttachmentsView.attachmentsViewHeight
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
        self.dataSource.postAttachmentsView(attachmentsModule: self).updateAppearance()
    }
    
    func hideAttachmentsView() {
        isPresented = false
        self.dataSource.postAttachmentsView(attachmentsModule: self).hideAnimated()
        var oldInset = self.dataSource.tableView(attachmentsModule: self).contentInset
        oldInset.top = 0
        self.dataSource.tableView(attachmentsModule: self).contentInset = oldInset
    }
}

extension AttachmentsModule: UserInteraction {
    fileprivate func show(error: Error) {
        var message = error.message!
        if error.code == -1011 {
            message = "You can't upload file more than 50 mb"
        }
        AlertManager.sharedManager.showErrorWithMessage(message: message)
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
