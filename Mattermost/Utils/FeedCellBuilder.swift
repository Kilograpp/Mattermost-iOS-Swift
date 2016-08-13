//
//  PostStrategy.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Inteface: class {
    func heightForPost(post: Post, previous: Post?, indexPath: NSIndexPath) -> CGFloat
    func cellForPost(post: Post, previous: Post?, indexPath: NSIndexPath) -> UITableViewCell
}

private enum CellType {
    case Attachment
    case FollowUp
    case Common
}

final class FeedCellBuilder {
    
    var weldIndexPaths = [NSIndexPath]()

    private let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    private init?(){
        return nil
    }
    
    private func typeForPost(post: Post, previous: Post?, indexPath: NSIndexPath) -> CellType {

        var notBetweenPages = true
        
        for loopIndexPath in self.weldIndexPaths {
            guard loopIndexPath != indexPath else {
                notBetweenPages = false
                break
            }
        }
        
        if post.hasAttachments() {
            return .Attachment
        }
        if let _ = previous where post.hasSameAuthor(previous) && notBetweenPages {
            return .FollowUp
        }
        return .Common
    }
}


extension FeedCellBuilder: Inteface {
    func cellForPost(post: Post, previous: Post?, indexPath: NSIndexPath) -> UITableViewCell {
        
        var reuseIdentifier: String
    
        switch self.typeForPost(post, previous: previous, indexPath: indexPath) {
            case .Attachment:
                reuseIdentifier = FeedAttachmentsTableViewCell.reuseIdentifier
                break
            case .FollowUp:
                reuseIdentifier =  FeedFollowUpTableViewCell.reuseIdentifier
                break
            case .Common:
                reuseIdentifier = FeedCommonTableViewCell.reuseIdentifier
                break
        }
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! FeedBaseTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWithPost(post)
        return cell
    }
    
    func heightForPost(post: Post, previous: Post?, indexPath: NSIndexPath) -> CGFloat {
        switch self.typeForPost(post, previous: previous, indexPath: indexPath) {
        case .Attachment:
            return FeedAttachmentsTableViewCell.heightWithPost(post)
        case .FollowUp:
            return FeedFollowUpTableViewCell.heightWithPost(post)
        case .Common:
            return FeedCommonTableViewCell.heightWithPost(post)
        }
    }
    
}

