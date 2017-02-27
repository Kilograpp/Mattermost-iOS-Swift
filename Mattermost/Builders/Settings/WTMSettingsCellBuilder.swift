//
//  WTMSettingsCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 08.11.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

fileprivate let sectionHeaderTitles: Array = [ "SEND DESKTOP NOTIFICATIONS", "OTHER NON-CASE SENSITIVE WORDS" ]
fileprivate let standardWordsOptions: Array = [ "Your case sensitive first name ", "Your non-case sensitive username ", "Your username mentioned ", "Channel-wide mentions \"@channel\", \"@all\"" ]
fileprivate let otherWordsSectionFooterTitle = "Separate by commas."

private protocol Inteface: class {
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell
    func switchCellState(indexPath: IndexPath)
    
    func updatedNotifyProps() -> NotifyProps
}


final class WTMSettingsCellBuilder {
    
//MARK: Properties
    fileprivate let tableView: UITableView
    fileprivate var notifyProps: NotifyProps?
    
    fileprivate var firstNameEnabled: Bool = false
    fileprivate var userNameEnabled: Bool = false
    fileprivate var mentionedUserNameEnabled: Bool = false
    fileprivate var mentionedChannelNameEnabled: Bool = false
    
    var sensetiveWordsString: String = ""
    
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
        
        self.notifyProps = DataManager.sharedInstance.currentUser?.notificationProperies()
        self.firstNameEnabled = (self.notifyProps?.isSensitiveFirstName())!
        self.userNameEnabled = (self.notifyProps?.isNonCaseSensitiveUsername())!
        self.mentionedUserNameEnabled = (self.notifyProps?.isUsernameMentioned())!
        self.mentionedChannelNameEnabled = (self.notifyProps?.isChannelWide())!
        
        self.sensetiveWordsString = (self.notifyProps?.otherNonCaseSensitive())!
    }
    
    private init?() {
        return nil
    }
}


//MARK: Interface
extension WTMSettingsCellBuilder: Inteface {
    func updatedNotifyProps() -> NotifyProps {
        let firstName = self.firstNameEnabled ? Constants.CommonStrings.True : Constants.CommonStrings.False
        let channel = self.mentionedChannelNameEnabled ? Constants.CommonStrings.True : Constants.CommonStrings.False
        let mentionKeys = self.mentionKeysState()
        
        try! RealmUtils.realmForCurrentThread().write {
            self.notifyProps?.firstName = firstName
            self.notifyProps?.channel = channel
            self.notifyProps?.mentionKeys = mentionKeys
        }
        
        return self.notifyProps!
    }
    
    func numberOfSections() -> Int {
        return sectionHeaderTitles.count
    }
    
    func numberOfRows(section: Int) -> Int {
        return (section == 0) ? standardWordsOptions.count : 1
    }
    
    func cellFor(notifyProps: NotifyProps, indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "CheckSettingsTableViewCell", for: indexPath)
            configure(cell: (cell as! CheckSettingsTableViewCell), indexPath: indexPath)
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "TextSettingsTableViewCell", for: indexPath)
            configure(cell: cell as! TextSettingsTableViewCell)
        default:
            break
        }
        
        return cell
    }
    
    func headerTitle(section: Int) -> String {
        return sectionHeaderTitles[section]
    }
    
    func footerTitle(section: Int) -> String? {
        return (section == 1) ? otherWordsSectionFooterTitle : nil
    }
    
    func cellHeight(section: Int) -> CGFloat {
        return (section == 0) ? 45 : 150
    }
    
    func switchCellState(indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell
        switch indexPath.row {
        case 0:
            self.firstNameEnabled = !self.firstNameEnabled
            cell.checkBoxButton?.isSelected = self.firstNameEnabled
        case 1:
            self.userNameEnabled = !self.userNameEnabled
            cell.checkBoxButton?.isSelected = self.userNameEnabled
        case 2:
            self.mentionedUserNameEnabled = !self.mentionedUserNameEnabled
            cell.checkBoxButton?.isSelected = self.mentionedUserNameEnabled
        case 3:
            self.mentionedChannelNameEnabled = !self.mentionedChannelNameEnabled
            cell.checkBoxButton?.isSelected = self.mentionedChannelNameEnabled
        default:
            break
        }
    }
    
    func firstNameState() -> String {
        let indexPath = IndexPath(row: 0, section: 0)
        return ((self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell).checkBoxButton?.isSelected)! ? /*"true"*/Constants.CommonStrings.True
                                                                                                                       : Constants.CommonStrings.False//"false"
    }
    
    func mentionKeysState() -> String {
        let user = DataManager.sharedInstance.currentUser
        
        var mentionKeys = self.userNameEnabled ? (user?.username)! : ""
        if self.mentionedUserNameEnabled {
            mentionKeys = StringUtils.commaTailedString(mentionKeys) + "@" + (user?.username)!
        }
        
        if self.sensetiveWordsString.characters.count > 0 {
            mentionKeys = StringUtils.commaTailedString(mentionKeys) + self.sensetiveWordsString.replacingOccurrences(of: " ", with: ",")
        }
        
        return mentionKeys
    }
    
    func channelState() -> String {
        let indexPath = IndexPath(row: 3, section: 0)
        return ((self.tableView.cellForRow(at: indexPath) as! CheckSettingsTableViewCell).checkBoxButton?.isSelected)! ? Constants.CommonStrings.True
                                                                                                                       : Constants.CommonStrings.False
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
        let base = standardWordsOptions[indexPath.row]
        switch indexPath.row {
        case 0:
            cell.descriptionLabel?.text = base + StringUtils.quotedString(user?.firstName)
            cell.checkBoxButton?.isSelected = self.firstNameEnabled
        case 1:
            cell.descriptionLabel?.text = base + StringUtils.quotedString(user?.username)
            cell.checkBoxButton?.isSelected = self.userNameEnabled
        case 2:
            cell.descriptionLabel?.text = base + StringUtils.quotedString("@" + (user?.username)!)
            cell.checkBoxButton?.isSelected = self.mentionedUserNameEnabled
        case 3:
            cell.descriptionLabel?.text = base
            cell.checkBoxButton?.isSelected = self.mentionedChannelNameEnabled
        default:
            break
        }
    }
    
    func configure(cell: TextSettingsTableViewCell) {
        cell.wordsTextView?.text = self.sensetiveWordsString.replacingOccurrences(of: ",", with: ", ")
        cell.placeholderLabel?.isHidden = ((cell.wordsTextView?.text.characters.count)! > 0)
        cell.clearButton?.isHidden = !((cell.wordsTextView?.text.characters.count)! > 0)
    }
}

