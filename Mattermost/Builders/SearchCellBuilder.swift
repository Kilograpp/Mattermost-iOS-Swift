//
//  SearchCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 29.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

private protocol Inteface: class {
    func heightForPost(post: Post) -> CGFloat
    func cellForPost(post: Post, searchingText: String) -> UITableViewCell
}


final class SearchCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {
        return nil
    }
}

//MARK: Interface
extension SearchCellBuilder: Inteface {
    func cellForPost(post: Post, searchingText: String) -> UITableViewCell {
        let reuseIdentifier = /*post.hasAttachments() ?  FeedSearchAttachmentTableViewCell.reuseIdentifier :*/ FeedSearchTableViewCell.reuseIdentifier
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! FeedBaseTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWithPost(post)
        (cell as! FeedSearchTableViewCell).configureSelectionWithText(text: searchingText)
        return cell
    }
    
    func heightForPost(post: Post) -> CGFloat {
        return /* post.hasAttachments() ? FeedSearchAttachmentTableViewCell.heightWithPost(post) :*/ FeedSearchTableViewCell.heightWithPost(post)
    }
}
