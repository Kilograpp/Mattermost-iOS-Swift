//
//  WTMSettingsCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 08.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Inteface: class {
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell
    func switchCellState(indexPath: IndexPath)
    func firstNameState() -> String
    func mentionKeysState() -> String
    func channelState() -> String
}


final class WTMSettingsCellBuilder {
    
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
extension WTMSettingsCellBuilder: Inteface {
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        switch indexPath.section {
        case 0:
            configure(cell: (cell as! CheckSettingsTableViewCell), indexPath: indexPath)
        case 1:
            configure(cell: cell as! TextSettingsTableViewCell)
        default:
            break
        }
        
        return cell!
    }
    
    func switchCellState(indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell
        cell.checkBoxButton?.isSelected = !(cell.checkBoxButton?.isSelected)!
    }
    
    func firstNameState() -> String {
        let indexPath = IndexPath(row: 0, section: 0)
        return ((self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell).checkBoxButton?.isSelected)! ? "true" : "false"
    }
    
    func mentionKeysState() -> String {
        let user = DataManager.sharedInstance.currentUser
        var indexPath = IndexPath(row: 1, section: 0)
        var mentionKeys: String = ((self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell).checkBoxButton?.isSelected)! ? (user?.username)! : ""
        indexPath = IndexPath(row: 2, section: 0)
        if ((self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell).checkBoxButton?.isSelected)! {
            mentionKeys += StringUtils.commaTailedString(mentionKeys) + "@" + (user?.username)!
        }
        indexPath = IndexPath(row: 0, section: 1)
        let otherWords = (self.tableView.cellForRow(at: indexPath) as! TextSettingsTableViewCell).wordsTextView?.text
        if (otherWords?.characters.count)! > 0 {
            mentionKeys += StringUtils.commaTailedString(mentionKeys) + otherWords!
        }
        
        return mentionKeys
    }
    
    func channelState() -> String {
        let indexPath = IndexPath(row: 3, section: 0)
        return ((self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell).checkBoxButton?.isSelected)! ? "true" : "false"
    }
}


//MARK: Configuration
fileprivate protocol Configuration: class {
    func configure(cell:CheckSettingsTableViewCell, indexPath: IndexPath)
    func configure(cell: TextSettingsTableViewCell)
}

extension WTMSettingsCellBuilder: Configuration {
    func configure(cell:CheckSettingsTableViewCell, indexPath: IndexPath) {
        let user = DataManager.sharedInstance.currentUser
        let notifyProps = user?.notificationProperies()
        
        let text = cell.descriptionLabel?.text
        switch indexPath.row {
        case 0:
            cell.descriptionLabel?.text = text! + StringUtils.quotedString(user?.firstName)
            cell.checkBoxButton?.isSelected = (notifyProps?.isSensitiveFirstName())!
        case 1:
            cell.descriptionLabel?.text = text! + StringUtils.quotedString(user?.username)
            cell.checkBoxButton?.isSelected = (notifyProps?.isNonCaseSensitiveUsername())!
        case 2:
            cell.descriptionLabel?.text = text! + StringUtils.quotedString("@" + (user?.username)!)
            cell.checkBoxButton?.isSelected = (notifyProps?.isUsernameMentioned())!
        case 3:
            cell.checkBoxButton?.isSelected = (notifyProps?.isChannelWide())!
        default:
            break
        }
    }
    
    func configure(cell: TextSettingsTableViewCell) {
        let user = DataManager.sharedInstance.currentUser
        let notifyProps = user?.notificationProperies()
            
        cell.wordsTextView?.text = notifyProps?.otherNonCaseSensitive()
        cell.placeholderLabel?.isHidden = ((cell.wordsTextView?.text.characters.count)! > 0)
    }
}

