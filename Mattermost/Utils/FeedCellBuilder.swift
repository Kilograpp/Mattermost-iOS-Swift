//
//  PostStrategy.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Inteface: class {
    func heightForPost(_ post: Post) -> CGFloat
    func cellForPost(_ post: Post, errorHandler: @escaping (_ post:Post) -> Void) -> UITableViewCell
}

final class FeedCellBuilder {
    
    fileprivate let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    fileprivate init?(){
        return nil
    }
    
    static func typeForPost(_ post: Post, previous: Post?) -> CellType {
        
        if post.hasAttachments() {
            return .attachment
        }
//        if let _ = previous where post.hasSameAuthor(previous)  {
//            
//            if previous?.day!.date!.compare(post.day!.date!) == .OrderedSame {
//               return .FollowUp
//            }
//            
//        }
        return .common
    }
}


extension FeedCellBuilder: Inteface {
    func cellForPost(_ post: Post, errorHandler: @escaping (_ post:Post) -> Void) -> UITableViewCell {
        
        var reuseIdentifier: String
    
        switch post.cellType {
        case .attachment:
            reuseIdentifier = FeedAttachmentsTableViewCell.reuseIdentifier
            break
        case .followUp:
//            reuseIdentifier =  FeedFollowUpTableViewCell.reuseIdentifier
//            break
            reuseIdentifier = FeedCommonTableViewCell.reuseIdentifier
            break
        case .common:
            reuseIdentifier = FeedCommonTableViewCell.reuseIdentifier
            break
        }
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FeedBaseTableViewCell
        if cell == nil {
            cell = FeedBaseTableViewCell(style: .default, reuseIdentifier: FeedBaseTableViewCell.reuseIdentifier)
        }
        cell!.transform = self.tableView.transform
        cell?.errorHandler = errorHandler
        cell!.configureWithPost(post)
        return cell!
    }
    
    func heightForPost(_ post: Post) -> CGFloat {
        switch post.cellType {
            case .attachment:
                return FeedAttachmentsTableViewCell.heightWithPost(post)
            case .followUp:
//                return FeedFollowUpTableViewCell.heightWithPost(post)
                return FeedCommonTableViewCell.heightWithPost(post)
            case .common:
                return FeedCommonTableViewCell.heightWithPost(post)
        }
    }
    
}

