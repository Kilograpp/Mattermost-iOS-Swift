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
        if isDisplayOnly {
            return (section == 0) ? 3 : 1
        } else {
            return (section == 0) ? 4 : 3
        }
    }
    
    func cellFor(user: User, indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as! ProfileTableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier:ProfileTableViewCell.reuseIdentifier) as! ProfileTableViewCell
        }
        
        let dateSource = (indexPath.section == 0) ? Constants.Profile.FirsSectionDataSource : Constants.Profile.SecondSecionDataSource
        let title = dateSource[indexPath.row].title
        let icon = dateSource[indexPath.row].icon
        
        var info: String? = nil
        switch indexPath.row {
        case 0:
            info = (indexPath.section == 0) ? user.firstName : user.email
            break
        case 1:
            info = (indexPath.section == 0) ? user.nickname : nil
            break
        case 2:
            info = (indexPath.section == 0) ? user.username : "On"
            break
        default:
            info = nil
        }
        
        cell.configureWith(title: title, info: info, icon: icon)
        cell.arrowButton?.isHidden = self.isDisplayOnly
        
        return cell
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
