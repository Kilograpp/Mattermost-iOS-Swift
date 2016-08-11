//
//  PostStrategy.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import SwiftFetchedResultsController


private protocol Inteface: class {
    func heightForPost(post: Post, previous: Post?) -> CGFloat
    func cellForPost(post: Post, previous: Post?) -> UITableViewCell
}

private enum CellType {
    case Attachment
    case FollowUp
    case Common
}

final class FeedCellBuilder {
    
    private let tableView: UITableView
    private var fetchedResultsController: FetchedResultsController<Post>
    
    init(tableView: UITableView, fetchedResultsController: FetchedResultsController<Post>) {
        self.tableView = tableView
        self.fetchedResultsController = fetchedResultsController
    }
    
    func updateWithFRC(fetchedResultsController: FetchedResultsController<Post>) {
        self.fetchedResultsController = fetchedResultsController
    }
    
    private init?(){
        return nil
    }
    
    private func typeForPost(post: Post, previous: Post?) -> CellType {
        let index = self.fetchedResultsController.fetchedObjects.indexOf(post)
        let notBetweenPages = (((index! + 1) % 60 != 0) && ((index! % 60) != 0)) || index! == 0
        
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
    func cellForPost(post: Post, previous: Post?) -> UITableViewCell {
        
        var reuseIdentifier: String
    
        
        
        switch self.typeForPost(post, previous: previous) {
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
    
    func heightForPost(post: Post, previous: Post?) -> CGFloat {
        switch self.typeForPost(post, previous: previous) {
        case .Attachment:
            return FeedAttachmentsTableViewCell.heightWithPost(post)
        case .FollowUp:
            return FeedFollowUpTableViewCell.heightWithPost(post)
        case .Common:
            return FeedCommonTableViewCell.heightWithPost(post)
        }
    }
    
}

