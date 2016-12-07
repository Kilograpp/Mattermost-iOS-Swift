//
//  UFSettingsCellBuilder.swift
//  Mattermost
//
//  Created by Екатерина on 27.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

fileprivate let fullNameSectionHeaderTitles: Array = [ "NAME", "SURNAME" ]
fileprivate let userNameSectionHeaderTitle = "USERNAME"
fileprivate let nickNameSectionHeaderTitle = "NICKNAME"
fileprivate let emailSectionHeaderTitle = "EMAIL"
fileprivate let passwordSectionHeaderTitles: Array = [ "OLD PASSWORD", "NEW PASSWORD", "NEW PASSWORD AGAIN" ]


private protocol Inteface: class {
    func numberOfSections() -> Int
    func numberOfRows() -> Int
    func cellFor(indexPath: IndexPath) -> UITableViewCell
    func title(section: Int) -> String
    func infoFor(section: Int) -> String
}

final class UFSettingsCellBuilder {
    
//MARK: Properties
    fileprivate let tableView: UITableView
    fileprivate let userFieldType: Int
    
//MARK: LifeCycle
    init(tableView: UITableView, userFieldType: Int) {
        self.tableView = tableView
        self.userFieldType = userFieldType
    }
    
    private init?() {
        return nil
    }
}


//MARK: Interface
extension UFSettingsCellBuilder: Inteface {
    func numberOfSections() -> Int {
        switch self.userFieldType {
        case Constants.UserFieldType.FullName:
            return fullNameSectionHeaderTitles.count
        case Constants.UserFieldType.Password:
            return passwordSectionHeaderTitles.count
        default:
            return 1
        }
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func cellFor(indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TextFieldSettingsTableViewCell", for: indexPath) as! TextFieldSettingsTableViewCell
        let user = DataManager.sharedInstance.currentUser
        
        switch self.userFieldType {
        case Constants.UserFieldType.FullName:
            cell.infoTextField?.text = (indexPath.section == 0) ? user?.firstName : user?.lastName
            cell.infoTextField?.keyboardType = .default
        case Constants.UserFieldType.UserName:
            cell.infoTextField?.text = user?.username
            cell.infoTextField?.keyboardType = .default
        case Constants.UserFieldType.NickName:
            cell.infoTextField?.text = user?.nickname
            cell.infoTextField?.keyboardType = .default
        case Constants.UserFieldType.Email:
            cell.infoTextField?.text = user?.email
            cell.infoTextField?.keyboardType = .emailAddress
        case Constants.UserFieldType.Password:
            cell.infoTextField?.keyboardType = .default
            cell.infoTextField?.text = nil
            cell.infoTextField?.isSecureTextEntry = true
        default:
            break
        }
        
        return cell
    }
    
    func title(section: Int) -> String {
        switch self.userFieldType {
        case Constants.UserFieldType.FullName:
            return fullNameSectionHeaderTitles[section]
        case Constants.UserFieldType.UserName:
            return userNameSectionHeaderTitle
        case Constants.UserFieldType.NickName:
            return nickNameSectionHeaderTitle
        case Constants.UserFieldType.Email:
            return emailSectionHeaderTitle
        case Constants.UserFieldType.Password:
            return passwordSectionHeaderTitles[section]
        default:
            return ""
        }
    }
    
    func infoFor(section: Int) -> String {
        let indexPath = IndexPath(row: 0, section: section)
        let cell = self.tableView.cellForRow(at: indexPath) as! TextFieldSettingsTableViewCell
        return (cell.infoTextField?.text)!
    }
}
