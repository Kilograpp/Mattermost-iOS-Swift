//
//  ChannelSettingsCellBuilder.swift
//  Mattermost
//
//  Created by Владислав on 23.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol ChannelSettginsCellBuilderInterface: class {
    func buildHeaderCell(cell: HeaderChannelSettingsCell, channel: Channel) -> HeaderChannelSettingsCell
    func buildInformationCell(cell: InformationChannelSettingsCell, channel: Channel, indexPath: IndexPath) -> InformationChannelSettingsCell
    func buildAllMembersCell(cell: LabelChannelSettingsCell) -> LabelChannelSettingsCell
    func buildLeaveDeleteChannelCell(cell: LabelChannelSettingsCell, channel: Channel) -> LabelChannelSettingsCell
    
    func heightForRow(indexPath: IndexPath) -> CGFloat
    func heightForSectionHeader(section: Int) -> CGFloat
    func numberOfRows(channel: Channel, section: Int) -> Int
    func numberOfSection() -> Int
    func titleForHeader(channel: Channel, section: Int) -> String?
}

final class ChanenlSettingsCellBuilder : ChannelSettginsCellBuilderInterface {
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
                return (channel.members.count <= 5) ? (channel.members.count+1) : 7
            default:
                return 0
        }
    }
    
    func titleForHeader(channel: Channel, section: Int) -> String? {
        if (section == 2) {
            return String(channel.members.count)+" members"
        }
        return nil
    }
    
    func heightForRow(indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section){
            case 0:
                return 91
            case 1,2:
                return 50
            case 3:
                return 56
            default:
                return 0
        }
    }
    
    func heightForSectionHeader(section: Int) -> CGFloat {
        switch (section){
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
    
    func buildHeaderCell(cell: HeaderChannelSettingsCell, channel: Channel) -> HeaderChannelSettingsCell {
        guard channel.displayName != nil else { return cell }
        cell.channelName.text = channel.displayName!
        cell.channelFirstSymbol.text = channel.displayName!.characters.count > 0 ? String(channel.displayName![0]) : " "
        return cell
    }
    
    func buildInformationCell(cell: InformationChannelSettingsCell, channel: Channel, indexPath: IndexPath) -> InformationChannelSettingsCell {
        guard channel.displayName != nil else { return cell }
        switch (indexPath.row){
        case 0:
            cell.infoName.text = "Header".localized
            cell.infoDetail.text = channel.header
        case 1:
            cell.infoName.text = "Purpose".localized
            cell.infoDetail.text = channel.purpose!
        case 2:
            cell.infoName.text = "URL".localized
            cell.infoDetail.text = channel.buildURL()
            cell.accessoryView = UIView()
            cell.isCopyEnabled = true
        case 3:
            cell.infoName.text = "ID".localized
            cell.infoDetail.text = channel.identifier!
            cell.accessoryView = UIView()
            cell.isCopyEnabled = true
        default:
            break
        }
        return cell
    }
    
    func buildAllMembersCell(cell: LabelChannelSettingsCell) -> LabelChannelSettingsCell {
        cell.cellText.text = "See all members"
        cell.cellText.textColor = UIColor.kg_blueColor()
        return cell
    }
    
    func buildLeaveDeleteChannelCell(cell: LabelChannelSettingsCell, channel: Channel) -> LabelChannelSettingsCell {
        let action = (channel.members.count > 1) ? "Leave" : "Delete"
        let type = (channel.privateType == Constants.ChannelType.PrivateTypeChannel) ? "Group" : "Channel"
        cell.cellText.text = action + " " + type
        cell.cellText.textColor = UIColor.red
        return cell
    }
}
