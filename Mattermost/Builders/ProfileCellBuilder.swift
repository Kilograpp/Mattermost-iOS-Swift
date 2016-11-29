//
//  ProfileCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 09.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate protocol Inteface: class {
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell
    func numberOfRowsFor(section: Int) -> Int
}


final class ProfileCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    fileprivate let isDisplayOnly: Bool
    
//MARK: LifeCycle
    init(tableView: UITableView, displayOnly: Bool) {
        self.tableView = tableView
        self.isDisplayOnly = displayOnly
    }
    
    private init?() {
        return nil
    }
}


//MARK: Interface
extension ProfileCellBuilder: Inteface {
    func numberOfRowsFor(section: Int) -> Int {
        if self.isDisplayOnly {
            return (section == 0) ? 3 : 1
        } else {
            return (section == 0) ? 4 : 3
        }
    }
    
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as! ProfileTableViewCell
        
        if indexPath.section == 0 {
            configureFirstSection(cell: cell, row: indexPath.row, user: user)
        } else {
            configureSecondSection(cell: cell, row: indexPath.row, user: user)
        }
        cell.arrowButton?.isHidden = self.isDisplayOnly
        
        return cell
    }
    
    func configureFirstSection(cell: ProfileTableViewCell, row: Int, user: User) {
        let dateSource = Constants.Profile.FirsSectionDataSource
        let title = dateSource[row].title
        let icon = dateSource[row].icon
        
        switch row {
        case 0:
            cell.configureWith(title: title, info: user.firstName, icon: icon)
        case 1:
            cell.configureWith(title: title, info: user.username, icon: icon)
        case 2:
            cell.configureWith(title: title, info: user.nickname, icon: icon)
        case 3:
            cell.configureWith(title: title, info: "", icon: icon)
        default:
            break
        }
    }
    
    func configureSecondSection(cell: ProfileTableViewCell, row: Int, user: User) {
        let dateSource = Constants.Profile.SecondSecionDataSource
        let title = dateSource[row].title
        let icon = dateSource[row].icon
        
        switch row {
        case 0:
            cell.configureWith(title: title, info: user.email, icon: icon)
        case 1:
            cell.configureWith(title: title, info: StringUtils.emptyString(), icon: icon)
        case 2:
            cell.configureWith(title: title, info: "On", icon: icon)
        default:
            break
        }
    }
    
    func cellForPost(post: Post, searchingText: String) -> UITableViewCell {
        let reuseIdentifier = post.hasAttachments() ?  FeedSearchAttachmentTableViewCell.reuseIdentifier : FeedSearchTableViewCell.reuseIdentifier
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! FeedBaseTableViewCell
        cell.transform = self.tableView.transform
        cell.configureWithPost(post)
        (cell as! FeedSearchTableViewCell).configureSelectionWithText(text: searchingText)
        return cell
    }
}
