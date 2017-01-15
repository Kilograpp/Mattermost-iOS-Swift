//
//  PostStrategy.swift
//  Mattermost
//
//  Created by Maxim Gubin on 10/08/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol FeedCellBuilderInterface: class {
    func heightForPost(_ post: Post, prevPost: Post?) -> CGFloat
    func cellForPost(_ post: Post, prevPost: Post?, errorHandler: @escaping (_ post:Post) -> Void) -> UITableViewCell
}


final class FeedCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    fileprivate init?(){
        return nil
    }
    
    static func typeForPost(_ post: Post, previous: Post?) -> CellType {
        return post.hasAttachments() ? .attachment : .common
    }
}


//MARK: FeedCellBuilderInterface
extension FeedCellBuilder: FeedCellBuilderInterface {
    func cellForPost(_ post: Post, prevPost: Post?, errorHandler: @escaping (_ post:Post) -> Void) -> UITableViewCell {
        
        let reuseIdentifier = (post.cellType == .common) ? FeedCommonTableViewCell.reuseIdentifier : FeedAttachmentsTableViewCell.reuseIdentifier
        
        
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FeedBaseTableViewCell
        if cell == nil {
            cell = FeedBaseTableViewCell(style: .default, reuseIdentifier: FeedBaseTableViewCell.reuseIdentifier)
        }
        cell!.transform = self.tableView.transform
        cell?.errorHandler = errorHandler
        
        if post.renderedText == nil {
            let attrStr = post.attributedMessage!
//            let dateStr = NSAttributedString
            post.renderedText = AttributedTextLayoutData(text: attrStr, maxWidth: UIScreen.screenWidth() - Constants.UI.FeedCellMessageLabelPaddings - Constants.UI.PostStatusViewSize)
        }
        
        cell!.configureWithPost(post)
        
        return cell!
    }
    
    func heightForPost(_ post: Post, prevPost: Post?) -> CGFloat {
        switch post.cellType {
            case .attachment:
                return FeedAttachmentsTableViewCell.heightWithPost(post)
       /*     case .followUp:
//                return FeedFollowUpTableViewCell.heightWithPost(post)
                return FeedCommonTableViewCell.heightWithPost(post)*/
            case .common:
                return FeedCommonTableViewCell.heightWithPost(post)
            /*case .attachmentFollowUp:
                return FeedCommonTableViewCell.heightWithPost(post)*/
        }
    }
}
