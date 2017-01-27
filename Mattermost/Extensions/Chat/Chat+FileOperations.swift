//
//  Chat+FileOperations.swift
//  Mattermost
//
//  Created by TaHyKu on 12.01.17.
//  Copyright © 2017 Kilograpp. All rights reserved.
//

import Foundation

//MARK: ChatViewController
extension ChatViewController {
    func presentDocumentInteractionController(notification: NSNotification) {
        let fileId = notification.userInfo?["fileId"]
        let file = RealmUtils.realmForCurrentThread().object(ofType: File.self, forPrimaryKey: fileId)
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + (file?.name)!
        
        if FileManager.default.fileExists(atPath: filePath) {
            self.documentInteractionController = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
            self.documentInteractionController?.delegate = self
            self.documentInteractionController?.presentPreview(animated: true)
        }
    }
}


//MARK: UIDocumentInteractionControllerDelegate
extension ChatViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
    }
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
    }
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
    }
    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}


//MARK: ImagesPreviewViewController
extension ChatViewController {
    func openPreviewWith(postLocalId: String, fileId: String) {
        let last = self.navigationController?.viewControllers.last
        guard last != nil else { return }
        guard !(last?.isKind(of: ImagesPreviewViewController.self))! else { return }
        
        let gallery = self.storyboard?.instantiateViewController(withIdentifier: "ImagesPreviewViewController") as! ImagesPreviewViewController
        
        gallery.configureWith(postLocalId: postLocalId, initalFileId: fileId)
        let transaction = CATransition()
        transaction.duration = 0.5
        transaction.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transaction.type = kCATransitionMoveIn
        transaction.subtype = kCATransitionFromBottom
        self.navigationController!.view.layer.add(transaction, forKey: kCATransition)
        self.navigationController?.pushViewController(gallery, animated: false)
    }
}
