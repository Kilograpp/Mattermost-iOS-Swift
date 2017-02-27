//
//  ChannelSettingsCellBuilder.swift
//  Mattermost
//
//  Created by Владислав on 23.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol Interface: class {
    func numberOfSection() -> Int
    func numberOfRows(channel: Channel, section: Int) -> Int
    func cellHeightFor(indexPath: IndexPath) -> CGFloat
    func sectionHeaderHeightFor(section: Int) -> CGFloat
    func cellFor(channel: Channel, indexPath: IndexPath) -> UITableViewCell
    func titleForHeader(channel: Channel, section: Int) -> String?
}


final class ChannelSettingsCellBuilder {
    
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
extension ChannelSettingsCellBuilder: Interface {
    func numberOfSection() -> Int {
        return 4
    }
    
    func numberOfRows(channel: Channel, section: Int) -> Int {
        switch (section){
        case 0,3:
            return 1
        case 1:
            return 4
        case 2:
            return (channel.members.count <= 5) ? (channel.members.count + 1) : 7
        default:
            return 0
        }
    }
    
    func cellHeightFor(indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return HeaderChannelSettingsCell.cellHeight()
        case 1:
            return InformationChannelSettingsCell.cellHeight()
        case 2:
            return MemberChannelSettingsCell.cellHeight()
        case 3:
            return LabelChannelSettingsCell.cellHeight()
        default:
            return 0
        }
    }
    
    func sectionHeaderHeightFor(section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1.0
        case 1:
            return 30
        case 2:
            return 60
        case 3:
            return 30
        default:
            return 0
        }
    }
    
    func cellFor(channel: Channel, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return headerSectionCellFor(channel: channel)
        case 1:
            return informationSectionCellFor(row: indexPath.row, channel: channel)
        case 2:
            return membersSectionCellFor(row: indexPath.row, channel: channel)
        case 3:
            return actionSectionCellFor(channel: channel)
        default:
            return UITableViewCell()
        }
    }
    
    func titleForHeader(channel: Channel, section: Int) -> String? {
        guard section == 2 else { return nil }
        
        var title = String(channel.members.count) + " member"
        if channel.members.count > 1 { title.append("s") }
        return title
    }
}


fileprivate protocol CellCreate: class {
    func headerSectionCellFor(channel: Channel) -> UITableViewCell
    func informationSectionCellFor(row: Int, channel: Channel) -> UITableViewCell
    func membersSectionCellFor(row: Int, channel: Channel) -> UITableViewCell
    func actionSectionCellFor(channel: Channel) -> UITableViewCell
}


//MARK: CellCreate
extension ChannelSettingsCellBuilder: CellCreate {
    func headerSectionCellFor(channel: Channel) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: HeaderChannelSettingsCell.reuseIdentifier) as! HeaderChannelSettingsCell
        cell.configureWith(channelName: channel.displayName!)
        return cell
    }
    
    func informationSectionCellFor(row: Int, channel: Channel) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: InformationChannelSettingsCell.reuseIdentifier) as! InformationChannelSettingsCell
        
        switch row {
        case 0:
            cell.configureWith(name: "Header".localized, detail: channel.header!, copyEnabled: false)
        case 1:
            cell.configureWith(name: "Purpose".localized, detail: channel.purpose!, copyEnabled: false)
        case 2:
            cell.configureWith(name: "URL".localized, detail: channel.buildURL(), copyEnabled: true)
        case 3:
            cell.configureWith(name: "ID".localized, detail: channel.identifier!, copyEnabled: true)
        default:
            break
        }
        
        return cell
    }
    
    func membersSectionCellFor(row: Int, channel: Channel) -> UITableViewCell {
        switch row {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: AddMembersChannelSettingsCell.reuseIdentifier) as! AddMembersChannelSettingsCell
            return cell
        case 6:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: LabelChannelSettingsCell.reuseIdentifier) as! LabelChannelSettingsCell
            cell.configureWith(text: "See all members", color: ColorBucket.seeAllMembersColor)
            return cell
        default:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: MemberChannelSettingsCell.reuseIdentifier) as! MemberChannelSettingsCell
            cell.configureWith(user: channel.members[row-1])
            return cell
        }
    }
    
    func actionSectionCellFor(channel: Channel) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: LabelChannelSettingsCell.reuseIdentifier) as! LabelChannelSettingsCell
        
        let type = (channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "Group" : "Channel"
        let action = (channel.members.count > 1) ? "Leave " : "Delete "
        cell.configureWith(text: action + type, color: ColorBucket.actionColor)
        
        return cell
    }
}
